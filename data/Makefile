
setup:
	pwd_name=$(notdir $(PWD))
	$(eval NAME_DATA=data)
	echo "command goals: $(lastword $(MAKECMDGOALS))"

	$(eval CHART_DATA=no)
	$(eval INSTALLDIR=no)
	$(eval DEPUPDIR_DATA=no)


	$(eval e=$(shell echo $(basename $(PWD))))
	echo $(e)
	@if [[ $(e) == *helm-charts ]]; then \
		echo "matches helm-charts"; \
		echo $(eval CHART_DATA=$(MAKECMDGOALS)); \
		echo $(eval INSTALLDIR=data/); \
		echo $(eval DEPUPDIR_DATA=data); \
	elif [[ $(e) == *data ]]; then \
		echo "matches data" && echo $(eval CHART_DATA=$(MAKECMDGOALS)) && echo $(eval INSTALLDIR=) && echo $(eval DEPUPDIR_DATA=.) ;\
		else \
		echo "does not match"; \
	fi
	echo $(INSTALLDIR)
	echo $(DEPUPDIR)

check-setup: setup
	@echo -e "\n\ntime to check"
	@echo "Name_data: $(NAME_DATA)"
	@echo "Chart_data: $(CHART_DATA)"
	@echo "Installdir: $(INSTALLDIR)"
	@echo "Depupdir_data: $(DEPUPDIR_DATA)"

wsa-data:
	$(eval WAITERSACHECK_DATA=$(shell kubectl get sa waiter-sa | tail -n +2 | awk '{if ($$1=="waiter-sa") print "--set=global.waiter.service_account.create=false"}'))
	echo $(WAITERSACHECK_DATA)

.PHONY: gm-data
gm-data: check-setup wsa-data
	helm install $(NAME_DATA) $(INSTALLDIR)$(CHART_DATA) --set=global.environment=kubernetes $(WAITERSACHECK_DATA)

.PHONY: jwt
jwt: check-setup wsa-data
	helm install $(NAME_DATA) $(INSTALLDIR)$(CHART_DATA) --set=global.environment=kubernetes $(WAITERSACHECK_DATA)

.PHONY: jwt-gov
jwt-gov: check-setup wsa-data
	helm install $(NAME_DATA) $(INSTALLDIR)$(CHART_DATA) --set=global.environment=kubernetes $(WAITERSACHECK_DATA)

clean-data: check-setup
	echo "$(DEPUPDIR_DATA)"
	rm -f $(DEPUPDIR_DATA)/charts/*

package-data: check-setup clean-data
	echo "target hit package-data"
	helm dep up $(DEPUPDIR_DATA)

.PHONY: data
data: check-setup package-data wsa-data
	helm install $(NAME_DATA) $(DEPUPDIR_DATA) --set=global.environment=kubernetes $(WAITERSACHECK_DATA)

.PHONY: remove-data
remove-data: check-setup
	helm uninstall $(NAME_DATA)