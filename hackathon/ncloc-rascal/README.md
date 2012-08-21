This is an extremely simple Rascal program that does the NCLOC metric: counts non-empty, non-comment lines of code in a Java file.

This version takes care of:
* empty lines
* seemingly empty lines (comment + whitespace)
* any whitespace obfuscation
* non-empty comment-containing lines

This version does not account for:
* multiline comments
* nested comments
* reporting on multiple files

Contributors:
* [http://github.com/grammarware Vadim Zaytsev]
