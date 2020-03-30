
WAITERSACHECK=$(shell kubectl get sa waiter-sa | tail -n +2 | awk '{if ($$1=="waiter-sa") print "present"}')
ifeq (${WAITERSACHECK},present)
	FLAG=--set=global.waiter.service_account.create=false
else
	FLAG=--set=global.waiter.service_account.create=true
endif

pwd_name := $(notdir $(PWD))

NAME:=sense
CHART := .

ifeq ($(pwd_name),helm-charts)
	CHART=$@
	INSTALLDIR := sense/
	override DEPUPDIR := sense
endif
ifeq ($(pwd_name),sense)
	CHART= .
	INSTALLDIR := 
	override DEPUPDIR := .
endif


.PHONY: catalog
catalog:
	helm install $(NAME) $(INSTALLDIR)$(CHART) --set=global.environment=kubernetes $(FLAG)

.PHONY: dashboard
dashboard:
	helm install $(NAME) $(INSTALLDIR)$(CHART) --set=global.environment=kubernetes $(FLAG)

.PHONY: slo
slo:
	helm install $(NAME) $(INSTALLDIR)$(CHART) --set=global.environment=kubernetes $(FLAG)

clean-sense:
	echo "$(DEPUPDIR)"
	rm -f $(DEPUPDIR)/charts/*

package-sense: clean-sense
	echo "target hit package-sense"
	helm dep up $(DEPUPDIR)

.PHONY: sense
sense: package-sense
	helm install $(NAME) $(CHART) --set=global.environment=kubernetes $(FLAG)

.PHONY: remove-sense
remove-sense:
	helm uninstall $(NAME)