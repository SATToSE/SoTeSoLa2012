
DIR=../../../101repo

help:
	@ echo ""
	@ echo " ## Targets:"
	@ echo ""
	@ echo " make metrics .................: code complexity"
	@ echo " make git-metrics .............: Git code complexity (slow)"
	@ echo ""

metrics:
	@ echo "################################################################"
	@ echo "Code complexity metrics"
	@ echo "for \"${DIR}\":"
	@ echo "################################################################"
	./cc.py ${DIR}

git-metrics:
	@ echo "################################################################"
	@ echo "Code complexity metrics"
	@ echo "for \"${DIR}\":"
	@ echo "################################################################"
	./git-cc.py ${DIR}


.PHONY: metrics
.PHONY: git-metrics


# Local Variables:
# mode: unix-shell-script
# End:

