#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <clang-c/Index.h>

typedef struct {
    const char *clang_name;
    const char *ffi_name;
} ffi_primitive_name_map;

static ffi_primitive_name_map ffi_primitive_names[] =
{
    {"int", "int"}, 
    {"char", "char"},
    {"float", "float"},
    {"double", "double"},
    {"long double", "long-double"}, 
    {"void", "void"},
    {"long int", "long"}, 
    {"unsigned int", "unsigned"}, 
    {"long unsigned int", "unsigned-long"}, 
    {"long long int", "long-long"}, 
    {"long long unsigned int", "unsigned-long-long"}, 
    {"short int", "short"}, 
    {"short unsigned int", "unsigned-short"}, 
    {"signed char", "signed-char"}, 
    {"unsigned char", "unsigned-char"}, 
    {"complex int", "complex-int"},
    {"complex float", "complex-float"},
    {"complex double", "complex-double"},
    {"complex long double", "complex-long-double"},
    {"__vector unsigned char", "__vector-unsigned-char"},
    {"__vector signed char", "__vector-signed-char"},
    {"__vector bool char", "__vector-bool-char"},
    {"__vector unsigned short", "__vector-unsigned-short"},
    {"__vector signed short", "__vector-signed-short"},
    {"__vector bool short", "__vector-bool-short"},
    {"__vector unsigned long", "__vector-unsigned-long"},
    {"__vector signed long", "__vector-signed-long"},
    {"__vector bool long", "__vector-bool-long"},
    {"__vector float", "__vector-short-float"},
    {"__vector pixel", "__vector-pixel"},
    {"__vector", "__vector"},  
    {"_Bool", "unsigned"},
    {"__int128_t", "long-long-long"}, 
    {"__uint128_t", "unsigned-long-long-long"}, 
    {NULL, NULL}
};

/* Return the Lisp'y name for the type GCC_NAME */
static char *
to_primitive_type_name (const char* clang_name)
{
  ffi_primitive_name_map *map = ffi_primitive_names;
  for (; map->clang_name; ++map)
    if (!strcmp (map->clang_name, clang_name))
      return (char*)map->ffi_name;
  fprintf(stderr, "Bug: couldn't find primitive name for %s\n", clang_name);
  exit(-1);
}

char * ffi_primitive_type_name (CXCursor decl)
{
  CXType type = clang_getCursorType(decl);
  CXString type_str = clang_getTypeSpelling(type);
  char * result = to_primitive_type_name(clang_getCString(type_str));
  clang_disposeString(type_str);
  return result;
}

enum CXChildVisitResult visit_func(CXCursor cursor, CXCursor parent, CXClientData client_data);

char * get_macro_definition(CXCursor cursor, CXString filename)
{
    const char * filename_s = clang_getCString(filename);
    char * definition = NULL;
    if (filename_s) {
        unsigned start, end, length;
        CXSourceRange range = clang_getCursorExtent(cursor);
        clang_getSpellingLocation(clang_getRangeStart(range), NULL, NULL, NULL, &start);
        clang_getSpellingLocation(clang_getRangeEnd(range), NULL, NULL, NULL, &end);
        length = end - start;
        definition = malloc(length+1);
        FILE * header = fopen(filename_s, "r");
        if (header) {
            fseek(header, start, SEEK_SET);
            for(int i = 0; i < length; i++) {
                definition[i] = fgetc(header);
            }
            definition[length] = '\0';
        }
    }
    return definition;
}

#define ffifile stdout

/*
  Emit the macro name (possibly including a parenthesized arglist).
  Surround whatever's emitted here with double quotes.
  Return a pointer to the first character of the (possibly empty) definition.
*/
static char *
emit_macro_name (char *p)
{
  int in_arglist = 0;
  char c;

  putc ('\"', ffifile);
  while ((c = *p) != 0)
    {
      switch (c)
	{
	case '(':
	  in_arglist = 1;
	  /* Fall down */
	case ',':
	  putc (' ', ffifile);
	  putc (c, ffifile);
	  putc (' ', ffifile);
	  break;

	case ')':
	  putc (' ', ffifile);
	  putc (c, ffifile);
	  putc ('\"', ffifile);
	  
	  while (isspace (*++p));
	  return p;
	
	default:
	  if (isspace (c) && !in_arglist)
	    {
	      putc ('\"', ffifile);
	      while (isspace (*++p));
	      return p;
	    }
	  putc (c, ffifile);
	}
      ++p;
    }
  putc ('\"', ffifile);
  return p;
}

static void
emit_macro_expansion (char *p)
{
  char c;
  char *q = p + strlen (p);
  
  while ((q > p) && isspace (q[-1])) q--;
  *q = '\0';

  fprintf (ffifile, " \"");

  while ((c = *p++) != '\0')
    {
      if (c == '\"')
	fputc ('\\', ffifile);
      fputc (c, ffifile);
    }
  fputc ('\"', ffifile);
}

#define PREDEFINED_HEADER_PATH "/tmp/ffigen-predefined-macro.h"
#define DUMP_CMD "clang -dM -E -x c /dev/null"

void process_macro_definition(CXCursor cursor, CXString filename, unsigned line)
{
    const char * filename_s = clang_getCString(filename);
    if (filename_s) {
        char * definition = get_macro_definition(cursor, filename);
        int is_predefined_header = (strcmp(filename_s, PREDEFINED_HEADER_PATH) == 0);
        printf("(macro (\"%s\" %u) ", 
            is_predefined_header ? "" : filename_s,
            is_predefined_header ? 1 : line
        );
        emit_macro_expansion(emit_macro_name(definition));
        printf(")\n");
        free(definition);
    }
}

void process_enum_decl(CXCursor cursor, CXString ident)
{
    int is_inside_enum = 1;
    printf("(enum (\"\" 0)\n");
    printf(" \"%s\" (", clang_getCString(ident));
    clang_visitChildren(cursor, visit_func, &is_inside_enum);
    printf("))\n");
    is_inside_enum = 0;
    clang_visitChildren(cursor, visit_func, &is_inside_enum);
}

void process_enum_constant_decl(CXCursor cursor, CXString ident, int is_inside_enum)
{
    const char * name = clang_getCString(ident);
    long long value = clang_getEnumConstantDeclValue(cursor);
    if (is_inside_enum) {
        printf("(\"%s\" %lld)", name, value);
    } else {
        printf("(enum-ident (\"\" 0)\n (\"%s\" %lld))\n", name, value);
    }
}

void format_storage_kind(CXCursor cursor)
{
    if (clang_Cursor_getStorageClass(cursor) == CX_SC_Extern) {
        fputs("(extern)", ffifile);
    } else {
        fputs("(static)", ffifile);
    }
}

int is_builtin_type(enum CXTypeKind kind)
{
    return (CXType_FirstBuiltin <= kind) && (kind <= CXType_LastBuiltin);
}

int is_primitive_type(enum CXTypeKind kind)
{
    return is_builtin_type(kind) ||
           kind == CXType_Complex ||
           kind == CXType_Vector;
}

int is_c_primitive_type(enum CXTypeKind kind)
{
    return is_primitive_type(kind) &&
           kind != CXType_Char16 &&
           kind != CXType_Char32;
}

void format_c_primitive_type(enum CXTypeKind kind)
{
    static char * map[] = {
        [CXType_Void] = "void",
        [CXType_Bool] = "unsigned",
        [CXType_Char_U] = "unsigned-char",
        [CXType_UChar] = "unsigned-char",
        [CXType_UShort] = "unsigned-short",
        [CXType_UInt] = "unsigned",
        [CXType_ULong] = "unsigned-long",
        [CXType_ULongLong] = "unsigned-long-long",
        [CXType_UInt128] = "unsigned-long-long-long",
        
    };
    fprintf(ffifile, "(%s)", map[CXType_Void]);
}

void format_type_reference(CXCursor cursor, CXType type)
{
    enum CXTypeKind kind = type.kind;
    CXString type_name = clang_getTypeKindSpelling(kind);

    if (is_c_primitive_type(kind)) {
        format_c_primitive_type(kind);
        return;
    }
    
    switch (kind) {
        case CXType_Complex:
            break;
        case CXType_Pointer:
            break;
        case CXType_Record:
            break;
        case CXType_Enum:
            break;
        case CXType_Typedef:
            break;
        CXType_FunctionProto:
            break;
        case CXType_ConstantArray:
            break;
        case CXType_Vector:
            break;
        default:
            fprintf(stderr, "Error: reference type %s not implemented.\n", clang_getCString(type_name));
    }
    clang_disposeString(type_name);
}

void process_var_decl(CXCursor cursor, CXString filename, unsigned line, CXString ident, CXType type)
{
    printf("(var (\"%s\" %u)\n", clang_getCString(filename), line);
    printf("  \"%s\"\n", clang_getCString(ident));
    printf("  ");
    format_type_reference(cursor, type);
    printf(" ");
    format_storage_kind(cursor);
    printf(")\n");
}

enum CXChildVisitResult visit_func(CXCursor cursor, CXCursor parent, CXClientData client_data)
{
    CXSourceLocation location = clang_getCursorLocation(cursor);
    unsigned line;
    CXFile file;
    clang_getSpellingLocation(location, &file, &line, NULL, NULL);
    CXString filename = clang_getFileName(file);
    enum CXCursorKind cursor_kind = clang_getCursorKind(cursor);
    CXString ident = clang_getCursorSpelling(cursor);
    CXType type = clang_getCursorType(cursor);

    switch(cursor_kind) {
        /* currently libclang has no way to access #undef,
         * fortunately it's also ignored in parse-ffi.lisp */
        case CXCursor_MacroDefinition:
            process_macro_definition(cursor, filename, line);
            break;
        case CXCursor_EnumDecl:
            process_enum_decl(cursor, ident);
            break;
        case CXCursor_EnumConstantDecl:
            process_enum_constant_decl(cursor, ident, *(int *)client_data);
            break;
        case CXCursor_StructDecl:
            break;
        case CXCursor_UnionDecl:
            break;
        case CXCursor_FunctionDecl:
            break;
        case CXCursor_VarDecl:
            process_var_decl(cursor, filename, line, ident, type);
            break;
        case CXCursor_TypedefDecl:
            break;
        default:
            break;
    }
    // clang_visitChildren(cursor, visit_func, NULL);
    clang_disposeString(filename);
    clang_disposeString(ident);
    return CXChildVisit_Continue;
}

void process_predefined_macro_definitions(CXIndex index)
{
    system(DUMP_CMD " > " PREDEFINED_HEADER_PATH);
    CXTranslationUnit unit = clang_parseTranslationUnit(
        index,
        PREDEFINED_HEADER_PATH, NULL, 0,
        NULL, 0,
        CXTranslationUnit_DetailedPreprocessingRecord
    );
    if (unit == NULL) {
        printf("Warning: Unable to get clang predefined header\n");
        return;
    }
    CXCursor root = clang_getTranslationUnitCursor(unit);
    clang_visitChildren(root, visit_func, NULL);
    
    clang_disposeTranslationUnit(unit);
}

int main(int argc, char *argv[])
{
    CXIndex index = clang_createIndex(0, 0);
    CXTranslationUnit unit = clang_parseTranslationUnit(
        index,
        "test.h", NULL, 0,
        NULL, 0,
        CXTranslationUnit_DetailedPreprocessingRecord |
        CXTranslationUnit_SkipFunctionBodies
    );
  
    if (unit == NULL) {
        printf("Unable to parse translation unit. Quitting.\n");
        exit(-1);
    }
    
    process_predefined_macro_definitions(index);

    CXCursor root = clang_getTranslationUnitCursor(unit);
    clang_visitChildren(root, visit_func, NULL);
    
    clang_disposeTranslationUnit(unit);
    clang_disposeIndex(index);
    
    return 0;
}
