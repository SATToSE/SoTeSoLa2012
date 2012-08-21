@contributor{Anastasia Izmaylova - SWAT, CWI}
module PP

import lang::java::jdt::Java;

import List;

public str toStr(entity(list[Id] ids)) = "<if(!isEmpty(ids)){><for(int i <- [0..size(ids)-1]){><if(i != size(ids)-1){><if(toStr(ids[i]) != "") {><toStr(ids[i])>.<}><}else{><toStr(ids[i])><}><}><}else{>_<}>";
public str toStr(package(str name)) = name;
public str toStr(class(str name)) = name;
public str toStr(class(str name, list[Entity] params)) = "<name>\<<for(int i <- [0..size(params)-1]){><if(i != size(params)-1){><toStr(params[i])>,<}else{><toStr(params[i])><}><}>\>";
public str toStr(interface(str name)) = name;
public str toStr(interface(str name, list[Entity] params)) = "<name>\<<for(int i <- [0..size(params)-1]){><if(i != size(params)-1){><toStr(params[i])>,<}else{><toStr(params[i])><}><}>\>"; 
public str toStr(enum(str name)) = name;
public str toStr(method(str name, list[Entity] params, Entity returnType)) = "<toStr(returnType)> <name>(<if(size(params) != 0){><for(int i <- [0..size(params)-1]){><if(i != size(params)-1){><toStr(params[i])>,<}else{><toStr(params[i])><}><}><}else{><}>)";
public str toStr(constr(list[Entity] params)) = "(<if(size(params) != 0){><for(int i <- [0..size(params)-1]){><if(i != size(params)-1){><toStr(params[i])>,<}else{><toStr(params[i])><}><}><}else{><}>)";
public str toStr(primitive(PrimitiveType primType)) = "<toStr(primType)>";
public str toStr(array(Entity elementType)) = "<toStr(elementType)>[]";
public str toStr(wildcard()) = "!";
public str toStr(wildcard(super(Entity b))) = "! super <toStr(b)>";
public str toStr(wildcard(extends(Entity b))) = "! extends <toStr(b)>";
public str toStr(captureof(Entity wildCard)) = "captureof <toStr(wildCard)>";

public default str toStr(Id id) {
	switch(id) {
		case initializer(): return "initializer";
		case initializer(int nr): return "initializer(<nr>)";
		case typeParameter(str name): return "<name> (type parameter)";
	}
	throw "ups, unknown id <id>";
}


public str toStr(byte()) = "byte";
public str toStr(short()) = "short";
public str toStr(\int()) = "int";
public str toStr(long()) = "long";
public str toStr(float()) = "float";
public str toStr(double()) = "double";
public str toStr(char()) = "char";
public str toStr(boolean()) = "boolean";
public str toStr(\void()) = "void";
public str toStr(null()) = "null";