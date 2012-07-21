all:
	rm -rf wiki
	git clone git://github.com/SoTeSoLa/SoTeSoLa.wiki.git wiki
	./makeGraph.py wiki | sed 's/Home/SoTeSoLa/' > rel.dot
	dot -Tpdf rel.dot > rel.pdf
	open rel.pdf
