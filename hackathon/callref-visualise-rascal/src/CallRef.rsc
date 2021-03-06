@contributor{Anastasia Izmaylova - ai@cwi.nl - SWAT, CWI}
@contributor{Jan Kurš}
@contributor{Vadim Zaytsev - vadim@grammarware.net - SWAT, CWI}
module CallRef

import lang::java::jdt::Java;
import lang::java::jdt::JavaADT;
import lang::java::jdt::JDT;

import String;
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


public list[loc] projects = [|project://javaInheritance|];

public void main()
{
	d = processProjects(projects);
	int i = 1;
	map[str, str] nodesNames = ();
	list[Figure] nodes = [];
	list[Edge] edges = [];
	for(n <- { *{n1,n2} | <str n1, str n2, int _, _, _, loc f, LineDecoration decor, list[LineDecoration] decors> <- d }) {
		nodesNames[n] = "<substring(n,findLast(n," ")+1,findFirst(n,"("))><i>";
		println("m<i> is <n>");
		i += 1;
		nodes += box(text(nodesNames[n]), id(nodesNames[n]), fillColor("red"));					
	}
	for(<str n1, str n2, int cx, bool low, bool hig, loc f, LineDecoration decor, list[LineDecoration] decors> <- d) {
		if(n1 != n2) {
			edges += edge(nodesNames[n1], nodesNames[n2],lineWidth(1+cx*2),
			(low&&hig)?lineColor("Red"):
			low?lineColor("Blue"):
			hig?lineColor("Purple"):
			lineColor("Green"),
			toArrow(ellipse(size(10+cx)))
			);
		}
	};
	println(nodes);
	println(edges);
	//for(n<-nodes) render(n);
	render(graph(nodes, edges, hint("layered"), gap(30), std(size(50))));
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
