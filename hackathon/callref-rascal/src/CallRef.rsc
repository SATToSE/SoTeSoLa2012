@contributor{Anastasia Izmaylova - ai@cwi.nl - SWAT, CWI}
@contributor{Jan Kurš}
@contributor{Vadim Zaytsev - vadim@grammarware.net - SWAT, CWI}
module CallRef

import lang::java::jdt::Java;
import lang::java::jdt::JavaADT;
import lang::java::jdt::JDT;

import Set;
import IO;

import PP;

import vis::Figure;
import vis::KeySym;
import vis::Render;
import util::Resources;
import util::Editors;

public LineDecoration marker(loc f) {
	int begin = f.begin.line;
	int end = f.end.line;
	return lineInfo = highlight(begin, "SoTeSoLa2012");
}


public list[loc] projects = [|project://BLA/src|];

public void brr() {
	nodes = [ box(text("A"), id("A"), fillColor("lightBlue"), layer("A"), onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) {
									println("A");
									//edit(f, [decor] + decors);
									return true;})), 
          box(text("B"), id("B"), fillColor("lightBlue"), layer("B"), onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) {
									println("B");
									//edit(f, [decor] + decors);
									return true;})), 
          box(text("C"), id("C"), fillColor("lightBlue"), layer("C")), 
          box(text("A1"), id("A1"), fillColor("lightGreen"), layer("A1")), 
          box(text("B1"), id("B1"), fillColor("lightGreen"), layer("B1")), 
          box(text("C1"), id("C1"), fillColor("lightGreen"), layer("C1"))
        ];
edges = [ edge("A", "B1"), edge("B1", "C")];
render(graph(nodes, edges, hint("layered"), gap(20), std(size(100))));
}

public void main()
{
	d = processProjects(projects);
	int i = 1;
	map[str, str] nodesNames = ();
	list[Figure] nodes = [];
	list[Edge] edges = [];
	for(n <- { *{n1,n2} | <str n1, str n2, int _, _, _, loc f, LineDecoration decor, list[LineDecoration] decors> <- d }) {
		nodesNames[n] = "m<i>";
		println("m<i> is <n>");
		i += 1;
		nodes += box(text(nodesNames[n]), id(nodesNames[n]), fillColor("red"), layer(nodesNames[n]),
						onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) {
									println(nodesNames[n]);
									//edit(f, [decor] + decors);
									return false;}));
	}
	for(<str n1, str n2, int _, _, _, loc f, LineDecoration decor, list[LineDecoration] decors> <- d) {
		if(n1 != n2) {
			/*
			nodes += box(text("c"), id(nodesNames[n1]+nodesNames[n2]), layer(nodesNames[n1]+nodesNames[n2]), fillColor("red"),
							onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) {
										println("bla");
										edit(f, [decor] + decors);
										return true;}));
			edges += edge(nodesNames[n1], nodesNames[n1]+nodesNames[n2]);
			edges += edge(nodesNames[n1]+nodesNames[n2], nodesNames[n2]);
			*/
			edges += edge(nodesNames[n1], nodesNames[n2]);
		}
	};
	println(nodes);
	println(edges);
	for(n<-nodes) render(n);
	//render(graph(nodes, edges, hint("layered"), gap(50), std(size(30))));
	//iprintln(d);
}

public rel[str, str, int, bool, bool, loc, LineDecoration, list[LineDecoration]] processProjects (list[loc] projects) 
	= { *processProjectForCallRefs(project) | loc project <- projects };

public list[str] processProjectForNames(loc project) {
	list[str] names = [];
	
	visit(createAstsFromProject(project)) {
		// case anonymousClassDeclaration(list[AstNode] bodyDeclarations): ;
		case enumDeclaration(_, str name, list[AstNode] implements, list[AstNode] enumConstants, list[AstNode] bodyDeclarations): names += name;
		case typeDeclaration(list[Modifier] modifiers, str objectType, str name, list[AstNode] genericTypes, Option[AstNode] extends, list[AstNode] implements, list[AstNode] bodyDeclarations): names += name;	
	}
	
	return names;
		
}

public rel[str, str, int, bool, bool, loc, LineDecoration, list[LineDecoration]] processProjectForCallRefs(loc project) {
	rel[str, str, int, bool, bool, loc, LineDecoration, list[LineDecoration]] nameRel = {};
	for(/file(loc f) <- getProject(project), f.extension == "java" && isOnBuildPath(f))
		visit(createAstsFromProject(f)) {
			case m:methodDeclaration(list[Modifier] modifiers, list[AstNode] genericTypes, Option[AstNode] returnType, str name, list[AstNode] parameters, list[AstNode] possibleExceptions, some(AstNode implementation)): 
				nameRel += { <toStr(m@bindings["methodBinding"]), n, c, lower, upper, f, marker(m@location), decors> |  <str n, int c, bool lower, bool upper, list[LineDecoration] decors> <- processNode(implementation, {}, false, false) };
		}
	return nameRel;
}


public rel[str, int, bool, bool, list[LineDecoration]] processNode(AstNode body, rel[str, int, bool, bool, list[LineDecoration]] names, bool lower, bool upper) {
	top-down-break visit (body) {
		case forStatement(_, Option[AstNode] optionalBooleanExpression, list[AstNode] updaters, AstNode body): {   
				upper = true;
				names = (some(AstNode e) := optionalBooleanExpression) ? processNode(e, names, lower, upper) : names; 
				for(updater <- updaters) names = processNode(updater, names, lower, upper);
				names = processNode(body, names, lower, upper);
		}
		case ifStatement(AstNode booleanExpression, AstNode thenStatement, Option[AstNode] elseStatement): { 
			  names = processNode(booleanExpression, names, lower, upper);
			  lower = true; 
			  names = processNode(thenStatement, names, lower, upper);
			  names = (some(AstNode e) := elseStatement) ? processNode(e, names, lower, upper) : names; 
		}
		case switchStatement(AstNode expression, list[AstNode] statements): { 
			  names = processNode(expression, names, lower, upper);
			  lower = true; 
			  for(statement <- statements) names = processNode(statement, names, lower, upper); 
		}
		case doStatement(AstNode body, AstNode whileExpression): { 
			  upper = true; 
			  names = processNode(body, names, lower, upper);
			  names = processNode(whileExpression, names, lower, upper);
		}
		case whileStatement(AstNode expression, AstNode body): { 
			  upper = true; 
			  names = processNode(expression, names, lower, upper); 
			  names = processNode(body, names, lower, upper); 
		}
		case m:methodInvocation(Option[AstNode] optionalExpression, list[AstNode] genericTypes, str name, list[AstNode] typedArguments): {
			n = toStr(m@bindings["methodBinding"]);
			if(isEmpty(names[n])) names += <n, ( !lower && !upper ) ? 1 : 0, lower, upper, [marker(m@location)]>;
			else {
				tuple[int, bool, bool, list[LineDecoration]] c = getOneFrom(names[n]);
				names = names - { <n, c[0], c[1], c[2], c[3]> } 
							  + { <n, ( !lower && !upper ) ? c[0] + 1 : c[0], c[1]||lower, c[2]||upper, c[3] + marker(m@location)>};
			}	
			names = (some(AstNode e) := optionalExpression) ? processNode(e, names, lower, upper) : names;
			for(arg <- typedArguments) names = processNode(arg, names, lower, upper);
		}
	}
	return names;
}
