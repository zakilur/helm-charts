WAITERSACHECK=$(shell kubectl get sa waiter-sa | tail -n +2 | awk '{if ($$1=="waiter-sa") print "present"}')
ifeq (${WAITERSACHECK},present)
	FLAG-DATA=--set=global.waiter.service_account.create=false
else
	FLAG-DATA=--set=global.waiter.service_account.create=true
endif

pwd_name := $(notdir $(PWD))

NAME-DATA:=data
CHART-DATA := .

ifeq ($(pwd_name),helm-charts)
	CHART-DATA=$@
	INSTALLDIR := data/
	override DEPUPDIR-DATA := data
endif
ifeq ($(pwd_name),data)
	CHART-DATA= .
	INSTALLDIR := 
	override DEPUPDIR-DATA := .
endif


.PHONY: gm-data
gm-data:
	helm install $(NAME-DATA) $(INSTALLDIR)$(CHART-DATA) --set=global.environment=kubernetes $(FLAG-DATA)

.PHONY: jwt
jwt:
	helm install $(NAME-DATA) $(INSTALLDIR)$(CHART-DATA) --set=global.environment=kubernetes $(FLAG-DATA)

.PHONY: jwt-gov
jwt-gov:
	helm install $(NAME-DATA) $(INSTALLDIR)$(CHART-DATA) --set=global.environment=kubernetes $(FLAG-DATA)

clean-data:
	echo "$(DEPUPDIR-DATA)"
	rm -f $(DEPUPDIR-DATA)/charts/*

package-data: clean-data
	echo "target hit package-data"
	helm dep up $(DEPUPDIR-DATA)

.PHONY: data
data: package-data
	helm install $(NAME-DATA) $(CHART-DATA) --set=global.environment=kubernetes $(FLAG-DATA)

.PHONY: remove-data
remove-data:
	helm uninstall $(NAME-DATA)