module CallRef

import lang::java::jdt::Java;
import lang::java::jdt::JavaADT;
import lang::java::jdt::JDT;

import Set;

public list[loc] projects = [|project://javaInheritance/|];

public rel[str, str, int, bool, bool] function1(list[loc] projects) 
	= { *function2(project) | loc project <- projects };

public list[str] function1(loc project) {
	list[str] names = [];
	
	visit(createAstsFromProject(project)) {
		// case anonymousClassDeclaration(list[AstNode] bodyDeclarations): ;
		case enumDeclaration(_, str name, list[AstNode] implements, list[AstNode] enumConstants, list[AstNode] bodyDeclarations): names += name;
		case typeDeclaration(list[Modifier] modifiers, str objectType, str name, list[AstNode] genericTypes, Option[AstNode] extends, list[AstNode] implements, list[AstNode] bodyDeclarations): names += name;	
	}
	
	return names;
		
}

public rel[str, str, int, bool, bool] function2(loc project) {
	rel[str, str, int, bool, bool] nameRel = {};
	visit(createAstsFromProject(project)) {
		case m:methodDeclaration(list[Modifier] modifiers, list[AstNode] genericTypes, Option[AstNode] returnType, str name, list[AstNode] parameters, list[AstNode] possibleExceptions, some(AstNode implementation)): 
			nameRel += { <"<m@bindings["methodBinding"]>", n, c, lower, upper> |  <str n, int c, bool lower, bool upper> <- function3(implementation) };
	}
	return nameRel;
}

//public rel[str, int, bool, bool] function3(AstNode method) {
//	rel[str, int, bool, bool] names = {};
//	visit(method) {
//		case forStatement(list[AstNode] initializers, Option[AstNode] optionalBooleanExpression, list[AstNode] updaters, AstNode body):
//		{
//			rel[str, int, bool, bool] r = function4(body,1,10);
//			names += {<["<m@bindings["methodBinding"]>"], function4(body,1,10)[0], function4(body,1,10)[0], function4(body,1,10)[0]>};
//		}
//		case ifStatement(AstNode booleanExpression, AstNode thenStatement, Option[AstNode] elseStatement):
//			names["<m@bindings["methodBinding"]>"] = function4(thenStatement,0,1);
//		// for -> function4( _ , 1, 10);
//		// while -> function4( _ , 0, 10);
//		// if -> function4( _ , 0, 1);
//	}
//	return names;
//}

public rel[str, int, bool, bool] function3(AstNode method) {
	rel[str, int, bool, bool] names = {};
	bool lower = false;
	bool upper = false;
	top-down visit (method)
	{
		case forStatement(list[AstNode] initializers, Option[AstNode] optionalBooleanExpression, list[AstNode] updaters, AstNode body):
			upper = true;
		case ifStatement(AstNode booleanExpression, AstNode thenStatement, Option[AstNode] elseStatement):
			lower = true;
		case switchStatement(AstNode expression, list[AstNode] statements):
			lower = true;
		case doStatement(AstNode body, AstNode whileExpression): 
			upper = true;
		case whileStatement(AstNode expression, AstNode body): 
			upper = true;
		case m:methodInvocation(Option[AstNode] optionalExpression, list[AstNode] genericTypes, str name, list[AstNode] typedArguments):
		{
			n = "<m@bindings["methodBinding"]>";
			if(isEmpty(names[n])) names += <n, 1, lower, upper>;
			else
			{
				tuple[int,bool,bool] c = getOneFrom(names[n]);
				names = names - {<n,c[0],c[1],c[2]>} + {<n,c[0],c[1]||lower,c[2]||upper>};
			}
		}
	}
	return names;
}

