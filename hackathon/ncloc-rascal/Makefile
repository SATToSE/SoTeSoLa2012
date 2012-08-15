all: rascal-0.5.1.jar
	cd src && java -Xmx1G -Xss32m -jar ../rascal-0.5.1.jar NCLOC.rsc ../../../../101repo/contributions/javaParser/org/softlang/recognizer/Lexer.java

rascal-0.5.1.jar:
	curl -k http://www.rascal-mpl.org/releases/rascal-0.5.1.jar > rascal-0.5.1.jar
