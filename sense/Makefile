pwd_name := $(notdir $(PWD))

NAME-SENSE:=sense
CHART-SENSE := .

ifeq ($(pwd_name),helm-charts)
	CHART-SENSE=$@
	INSTALLDIR := sense/
	override DEPUPDIR-SENSE := sense
endif
ifeq ($(pwd_name),sense)
	CHART-SENSE= .
	INSTALLDIR := 
	override DEPUPDIR-SENSE := .
endif


wsa-sense:
	$(eval WAITERSACHECK-SENSE=$(shell kubectl get sa waiter-sa | tail -n +2 | awk '{if ($$1=="waiter-sa") print "--set=global.waiter.service_account.create=false"}'))
	echo $(WAITERSACHECK-SENSE)

.PHONY: catalog
catalog:
	helm install $(NAME-SENSE) $(INSTALLDIR)$(CHART-SENSE) --set=global.environment=kubernetes $(WAITERSACHECK-SENSE)

.PHONY: dashboard
dashboard:
	helm install $(NAME-SENSE) $(INSTALLDIR)$(CHART-SENSE) --set=global.environment=kubernetes $(WAITERSACHECK-SENSE)

.PHONY: slo
slo:
	helm install $(NAME-SENSE) $(INSTALLDIR)$(CHART-SENSE) --set=global.environment=kubernetes $(WAITERSACHECK-SENSE)

clean-sense:
	echo "$(DEPUPDIR-SENSE)"
	rm -f $(DEPUPDIR-SENSE)/charts/*

package-sense: clean-sense
	echo "target hit package-sense"
	helm dep up $(DEPUPDIR-SENSE)

.PHONY: sense
sense: package-sense
	helm install $(NAME-SENSE) $(CHART-SENSE) --set=global.environment=kubernetes $(WAITERSACHECK-SENSE)

.PHONY: remove-sense
remove-sense:
	helm uninstall $(NAME-SENSE)