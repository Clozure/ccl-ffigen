#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <clang-c/Index.h>

#define FFIGEN_DEBUG

#ifdef FFIGEN_DEBUG
#define debug_print(...) fprintf(stderr, __VA_ARGS__)
#else
#define debug_print(...)
#endif

#define ffifile stdout

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
    while ((c = *p) != 0) {
        switch (c) {
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

    while ((c = *p++) != '\0') {
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
        fprintf(ffifile, "(macro (\"%s\" %u) ",
                is_predefined_header ? "" : filename_s,
                is_predefined_header ? 1 : line
            );
        emit_macro_expansion(emit_macro_name(definition));
        fprintf(ffifile, ")\n");
        free(definition);
    }
}

/* print ident name if it's not anonymous, otherwise print it as linenum_filename */
void format_ident_name(CXCursor cursor)
{
    CXSourceLocation location;
    unsigned line;
    CXFile file;
    CXString filename;
    CXString name;

    name = clang_getCursorSpelling(cursor);

    /* It's strange that clang_Cursor_isAnonymous always return 0,
       so check name instead */
    if (strlen(clang_getCString(name)) == 0) {
        location = clang_getCursorLocation(cursor);
        clang_getSpellingLocation(location, &file, &line, NULL, NULL);
        filename = clang_getFileName(file);
        fprintf(ffifile, "%u_%s", line, clang_getCString(filename));
        clang_disposeString(filename);
    } else {
        fprintf(ffifile, "%s", clang_getCString(name));
    }
    clang_disposeString(name);
}

void process_enum_decl(CXCursor cursor)
{
    int is_inside_enum = 1;
    fprintf(ffifile, "(enum (\"\" 0)\n");
    fprintf(ffifile, " \"");
    format_ident_name(cursor);
    fprintf(ffifile, "\" (");
    clang_visitChildren(cursor, visit_func, &is_inside_enum);
    fprintf(ffifile, "))\n");
    is_inside_enum = 0;
    clang_visitChildren(cursor, visit_func, &is_inside_enum);
}

void process_enum_constant_decl(CXCursor cursor, CXString ident, int is_inside_enum)
{
    const char * name = clang_getCString(ident);
    long long value = clang_getEnumConstantDeclValue(cursor);
    if (is_inside_enum) {
        fprintf(ffifile, "(\"%s\" %lld)", name, value);
    } else {
        fprintf(ffifile, "(enum-ident (\"\" 0)\n (\"%s\" %lld))\n", name, value);
    }
}

void format_storage_kind(CXCursor cursor)
{
    if (clang_Cursor_getStorageClass(cursor) == CX_SC_Extern) {
        fprintf(ffifile, "(extern)");
    } else {
        fprintf(ffifile, "(static)");
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

int is_cxx_additional_type(enum CXTypeKind kind)
{
    return kind == CXType_Char16 ||
        kind == CXType_Char32 ||
        kind == CXType_WChar ||
        kind == CXType_NullPtr ||
        kind == CXType_Overload ||
        kind == CXType_Dependent;
}

int is_objc_additional_type(enum CXTypeKind kind)
{
    return kind == CXType_ObjCId ||
        kind == CXType_ObjCClass ||
        kind == CXType_ObjCSel;
}

int is_c_primitive_type(enum CXTypeKind kind)
{
    return is_primitive_type(kind) &&
        !is_cxx_additional_type(kind) &&
        !is_objc_additional_type(kind);
}

void format_c_primitive_type(CXType type, enum CXTypeKind kind)
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
        [CXType_Char_S] = "signed-char",
        [CXType_SChar] = "signed-char",
        [CXType_Short] = "short",
        [CXType_Int] = "int",
        [CXType_Long] = "long",
        [CXType_LongLong] = "long-long",
        [CXType_Int128] = "long-long-long",
        [CXType_Float] = "float",
        [CXType_Double] = "double",
        [CXType_LongDouble] = "long-double"
        /* TODO: Machine specific types
         * CXType_Float128: '__float128' in i386, x86_64, IA-64
         * CXType_Half: 'half' in OpenCL, '__fp16' in ARM NEON.
         * CXType_Float16: see https://reviews.llvm.org/D33719
         */
    };
    if (kind == CXType_Complex) {
        fprintf(ffifile, "(complex-%s ())", map[clang_getElementType(type).kind]);
    } else if (kind == CXType_Vector) {
        fprintf(ffifile, "(__vector-%s ())", map[clang_getElementType(type).kind]);
    } else {
        fprintf(ffifile, "(%s ())", map[kind]);
    }
}

CXType getPointeeType(CXType type)
{
    CXType pointee_type = clang_getPointeeType(type);
    if (pointee_type.kind == CXType_Unexposed) {
        debug_print("Debug: libclang unexposed symbol.\n");
        pointee_type.kind = CXType_Void;
    }
    return pointee_type;
}

void format_struct_reference(CXType type)
{
    CXCursor struct_def = clang_getTypeDeclaration(type);
    fprintf(ffifile, "(struct-ref \"");
    format_ident_name(struct_def);
    fprintf(ffifile, "\")");
}

void format_enum_reference(CXType type)
{
    CXCursor enum_def = clang_getTypeDeclaration(type);
    fprintf(ffifile, "(enum-ref \"");
    format_ident_name(enum_def);
    fprintf(ffifile, "\")");
}

void format_typedef_reference(CXType type)
{
    CXCursor typedef_def = clang_getTypeDeclaration(type);
    fprintf(ffifile, "(typedef \"");
    format_ident_name(typedef_def);
    fprintf(ffifile, "\")");
}

void format_type_reference(CXType type)
{
    enum CXTypeKind kind = type.kind;
    CXString type_kind_name = clang_getTypeKindSpelling(kind);

    if (is_c_primitive_type(kind)) {
        format_c_primitive_type(type, kind);
        return;
    }

    switch (kind) {
    case CXType_Pointer:
        fprintf(ffifile, "(pointer ");
        format_type_reference(getPointeeType(type));
        fprintf(ffifile, ")");
        break;
    case CXType_Elaborated:
        format_type_reference(clang_Type_getNamedType(type));
        break;
    case CXType_Record:
        format_struct_reference(type);
        break;
    case CXType_Enum:
        format_enum_reference(type);
        break;
    case CXType_Typedef:
        format_typedef_reference(type);
        break;
    case CXType_FunctionProto:
        break;
    case CXType_ConstantArray:
        break;
    default:
        fprintf(stderr, "Error: reference type %s not implemented.\n", clang_getCString(type_kind_name));
    }
    clang_disposeString(type_kind_name);
}

void process_var_decl(CXCursor cursor, CXString filename, unsigned line, CXString ident, CXType type)
{
    fprintf(ffifile, "(var (\"%s\" %u)\n", clang_getCString(filename), line);
    fprintf(ffifile, "  \"%s\"\n", clang_getCString(ident));
    fprintf(ffifile, "  ");
    format_type_reference(type);
    fprintf(ffifile, " ");
    format_storage_kind(cursor);
    fprintf(ffifile, ")\n");
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
        process_enum_decl(cursor);
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
        fprintf(stderr, "Warning: Unable to get clang predefined header\n");
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
        fprintf(stderr, "Unable to parse translation unit. Quitting.\n");
        exit(-1);
    }

    process_predefined_macro_definitions(index);

    CXCursor root = clang_getTranslationUnitCursor(unit);
    clang_visitChildren(root, visit_func, NULL);

    clang_disposeTranslationUnit(unit);
    clang_disposeIndex(index);

    return 0;
}
