#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <clang-c/Index.h>

void print_indent(unsigned int level)
{
    unsigned int i;
    for (i = 0; i < level; i++) {
        putchar(' ');
    }
}

void printCursorKind(enum CXCursorKind cursorKind)
{
    CXString kindName = clang_getCursorKindSpelling(cursorKind);
    printf("%s ", clang_getCString(kindName));
    clang_disposeString(kindName);
}

void printCursorSpelling(CXCursor cursor)
{
    CXString cursorSpelling = clang_getCursorSpelling(cursor);
    printf("(%s) ", clang_getCString(cursorSpelling));
    clang_disposeString(cursorSpelling);
}

void printCursorType(CXCursor cursor)
{
    CXType cursorType = clang_getCursorType(cursor);
    CXString typeSpelling = clang_getTypeSpelling(cursorType);
    printf("[%s]\n", clang_getCString(typeSpelling));
    clang_disposeString(typeSpelling);
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
        printf("(macro (\"%s\" %d) ", 
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

enum CXChildVisitResult visit_func(CXCursor cursor, CXCursor parent, CXClientData client_data)
{
    CXSourceLocation location = clang_getCursorLocation(cursor);
    unsigned line;
    CXFile file;
    clang_getSpellingLocation(location, &file, &line, NULL, NULL);
    CXString filename = clang_getFileName(file);
    enum CXCursorKind cursor_kind = clang_getCursorKind(cursor);
    CXString ident = clang_getCursorSpelling(cursor);
    CXString type = clang_getTypeSpelling(clang_getCursorType(cursor));

    switch(cursor_kind) {
        case CXCursor_MacroDefinition:
            process_macro_definition(cursor, filename, line);
            break;
        case CXCursor_EnumDecl:
            process_enum_decl(cursor, ident);
            break;
        case CXCursor_EnumConstantDecl:
            process_enum_constant_decl(cursor, ident, *(int *)client_data);
            break;
    }
    // clang_visitChildren(cursor, visit_func, NULL);
    clang_disposeString(filename);
    clang_disposeString(ident);
    clang_disposeString(type);
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
