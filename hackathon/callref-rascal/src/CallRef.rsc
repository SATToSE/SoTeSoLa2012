@contributor{Anastasia Izmaylova - SWAT, CWI}
@contributor{Jan Kurš}
@contributor{Vadim Zaytsev - vadim@grammarware.net - SWAT, CWI}
module CallRef

import lang::java::jdt::Java;
import lang::java::jdt::JavaADT;
import lang::java::jdt::JDT;

import Set;
import IO;

import PP;

public list[loc] projects = [|project://javaInheritance/|];

public void main()
{
	iprintln(processProjects(projects));
}

public rel[str, str, int, bool, bool] processProjects (list[loc] projects) 
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

public rel[str, str, int, bool, bool] processProjectForCallRefs(loc project) {
	rel[str, str, int, bool, bool] nameRel = {};
	visit(createAstsFromProject(project)) {
		case m:methodDeclaration(list[Modifier] modifiers, list[AstNode] genericTypes, Option[AstNode] returnType, str name, list[AstNode] parameters, list[AstNode] possibleExceptions, some(AstNode implementation)): 
			nameRel += { <toStr(m@bindings["methodBinding"]), n, c, lower, upper> |  <str n, int c, bool lower, bool upper> <- processNode(implementation, {}, false, false) };
	}
	return nameRel;
}


public rel[str, int, bool, bool] processNode(AstNode body, rel[str, int, bool, bool] names, bool lower, bool upper) {
	top-down-break visit (body) {
		case forStatement(_, Option[AstNode] optionalBooleanExpression, list[AstNode] updaters, AstNode body): {   
				upper = true;
				names += (some(AstNode e) := optionalBooleanExpression) ? processNode(e, names, lower, upper) : {}; 
				for(updater <- updaters) names += processNode(updater, names, lower, upper);
				names += processNode(body, names, lower, upper);
		}
		case ifStatement(AstNode booleanExpression, AstNode thenStatement, Option[AstNode] elseStatement): { 
			  names += processNode(booleanExpression, names, lower, upper);
			  lower = true; 
			  names += processNode(thenStatement, names, lower, upper);
			  names += (some(AstNode e) := elseStatement) ? processNode(e, names, lower, upper) : {}; 
		}
		case switchStatement(AstNode expression, list[AstNode] statements): { 
			  names += processNode(expression, names, lower, upper);
			  lower = true; 
			  for(statement <- statements) names += processNode(statement, names, lower, upper); 
		}
		case doStatement(AstNode body, AstNode whileExpression): { 
			  upper = true; 
			  names += processNode(body, names, lower, upper);
			  names += processNode(whileExpression, names, lower, upper);
		}
		case whileStatement(AstNode expression, AstNode body): { 
			  upper = true; 
			  names += processNode(expression, names, lower, upper); 
			  names += processNode(body, names, lower, upper); 
		}
		case m:methodInvocation(Option[AstNode] optionalExpression, list[AstNode] genericTypes, str name, list[AstNode] typedArguments): {
			n = toStr(m@bindings["methodBinding"]);
			if(isEmpty(names[n])) names += <n, ( !lower && !upper ) ? 1 : 0, lower, upper>;
			else {
				tuple[int,bool,bool] c = getOneFrom(names[n]);
				names = names - { <n, c[0], c[1], c[2]> } 
							  + { <n, ( !(c[1]||lower) &&!(c[2]||upper) ) ? c[0] + 1 : c[0], c[1]||lower, c[2]||upper>};
			}	
			names += (some(AstNode e) := optionalExpression) ? processNode(e, names, lower, upper) : {};
			for(arg <- typedArguments) names += processNode(arg, names, lower, upper);
		}
	}
	return names;
}
