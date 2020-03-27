
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
	DEPUPDIR := sense
endif
ifeq ($(pwd_name),sense)
	CHART= .
	INSTALLDIR := 
	DEPUPDIR := .
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

.PHONY: package-sense
package-sense:
	rm -f $(CHART)/charts/*
	helm dep up $(DEPUPDIR)

.PHONY: sense
sense: package-sense
	helm install $(NAME) $(CHART) --set=global.environment=kubernetes $(FLAG)

.PHONY: remove-sense
remove-sense:
	helm uninstall $(NAME)