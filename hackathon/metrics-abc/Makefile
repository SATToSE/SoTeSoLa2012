
DIR=../../../101repo/contributions/rubyonrails

help:
	@ echo ""
	@ echo " ## Targets:"
	@ echo ""
	@ echo " make setup ...................: bundle install"
	@ echo " make metrics .................: Calculate ABC metrics"
	@ echo ""

setup:
	bundle install

metrics:
	@ echo "################################################################"
	@ echo "ABC metrics (assignments, branches, conditions)"
	@ echo "for \"${DIR}\":"
	@ echo "################################################################"
	bundle exec metric_abc $$( find ${DIR} -iname *.rb )
	

.PHONY: setup
.PHONY: metrics


# Local Variables:
# mode: unix-shell-script
# End:

