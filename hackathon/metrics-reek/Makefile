
DIR=../../../101repo/contributions/ruby

help:
	@ echo ""
	@ echo " ## Targets:"
	@ echo ""
	@ echo " make setup ...................: bundle install"
	@ echo " make reek ....................: Report code smells"
	@ echo ""

setup:
	bundle install

reek:
	@ echo "################################################################"
	@ echo "Reek code smell detector"
	@ echo "for \"${DIR}\":"
	@ echo "################################################################"
	bundle exec reek ${DIR}
	

.PHONY: setup
.PHONY: reek


# Local Variables:
# mode: unix-shell-script
# End:

