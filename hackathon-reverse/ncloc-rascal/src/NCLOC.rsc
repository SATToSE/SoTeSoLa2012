@contributor{Vadim Zaytsev - vadim@grammarware.net - SWAT, CWI}
module NCLOC

import IO;
import ParseTree;
import List;

lexical OneLineComment = "//" ![\n]* >> [\n];
lexical CodeLine = ![/\n]* meat OneLineComment? >> [\n];
start syntax SourceCodeModel = {(OneLineComment | CodeLine) "\n"}+ "\n"?;
layout WS = [\ \t]* !>> [\ \t];

public void main(list[str] args)
 = println(size([l | /CodeLine l := parse(#start[SourceCodeModel],|cwd:///|+args[0]), "<l.meat>" != ""]));
