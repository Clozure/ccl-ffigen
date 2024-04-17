# Clozure CL ffigen

This repository contains code to use libclang to parse C header files
and write semantically equivalent `.ffi` files that use a syntax based
on s-expressions.

CCL has been relying on a modified version of GCC 4.0.0 to do this
job.  However, GCC 4.0.0 is very out-of-date, and doesn’t support
newer constructs in system header files.

By basing the translator on the stable interface of libclang, we hope
to ease maintainability and avoid the tendency to treat the pre-built
interface databases as opaque binary artifacts that get blindly
carried forward with each release.

The most recent FreeBSD release already uses interface databases built
using this translator.

## Background

Clozure CL’s foreign function interface (FFI) uses a set of database
files which contain information derived from the C header files for
the host operating system.

Historically, CCL has used a system based on the FFIGEN system,
as described at <https://www.khoury.northeastern.edu/home/lth/ffigen/>,
in order to generate these database files.

The  idea of the FFIGEN system is to use the C compiler’s parser
and front-end to translate `.h` files into semantically eqivalent
`.ffi` files. These `.ffi` files represent the definitions from
the headers using an s-expression-based syntax.

Lisp code can then operate on the `.ffi` representation, and avoid the
need to concern itself with semantics of header file inclusion or the
details of parsing C.

In CCL’s particular case, Lisp code processes the `.ffi` files and
generates binary `.cdb` files.  (On x86-64 Macs, these `.cdb` files
are found in `#p"ccl:darwin-x86-headers64;"`; other platforms use
other directories). The `#_` and `#$` reader macros consult these
database files.  In addition, references to foreign type,
struct/union, and field names (when used the the `pref` and `rlet`
macros) will cause the database files to be consulted.

### Example

Consider the file `t.h` with the following contents:
```c
struct junkfd {
    int    fd;       /* file descriptor */
    short  events;   /* events to look for */
    short  revents;  /* events returned */
};

int junk(struct junkfd fds[], int nfds, int timeout);
```

Processing this would yield the following `.ffi` file:
```
(struct ("" 0)
 "junkfd"
 (("fd" (field (int ()) 0 4))
("events" (field (short ()) 4 2))
("revents" (field (short ()) 6 2))
))
(function ("t.h" 7)
 "junk"
 (function
  ((array 0 (struct-ref "junkfd")) (int ()) (int ()))
  (int ())) (extern))
```

The original FFIGEN system used a modified version of the `lcc` C
compiler to produce `.ffi` files.  Becasue many operating system
header files contain GCC-specific constructs, Clozure CL’s version of
the translation system has been using a modified version of GCC
(called, confusingly enough, `ffigen`) to do the processing.

The GCC-based translator is a set of patches to GCC 4.0.0. The
procedure to build it is documented at
<https://trac.clozure.com/ccl/wiki/BuildFFIGEN>.

For additional information, please see
<https://ccl.clozure.com/docs/ccl.html#the-interface-database> and
<https://ccl.clozure.com/docs/ccl.html#the-interface-translator>.
