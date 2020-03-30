WAITERSACHECK=$(shell kubectl get sa waiter-sa | tail -n +2 | awk '{if ($$1=="waiter-sa") print "present"}')
ifeq (${WAITERSACHECK},present)
	FLAG=--set=global.waiter.service_account.create=false
else
	FLAG=--set=global.waiter.service_account.create=true
endif

pwd_name := $(notdir $(PWD))

NAME:=data
CHART := .

ifeq ($(pwd_name),helm-charts)
	CHART=$@
	INSTALLDIR := data/
	override DEPUPDIR := data
endif
ifeq ($(pwd_name),data)
	CHART= .
	INSTALLDIR := 
	override DEPUPDIR := .
endif


.PHONY: gm-data
gm-data:
	helm install $(NAME) $(INSTALLDIR)$(CHART) --set=global.environment=kubernetes $(FLAG)

.PHONY: jwt
jwt:
	helm install $(NAME) $(INSTALLDIR)$(CHART) --set=global.environment=kubernetes $(FLAG)

.PHONY: jwt-gov
jwt-gov:
	helm install $(NAME) $(INSTALLDIR)$(CHART) --set=global.environment=kubernetes $(FLAG)

clean-data:
	echo "$(DEPUPDIR)"
	rm -f $(DEPUPDIR)/charts/*

package-data: clean-data
	echo "target hit package-data"
	helm dep up $(DEPUPDIR)

.PHONY: data
data: package-data
	helm install $(NAME) $(CHART) --set=global.environment=kubernetes $(FLAG)

.PHONY: remove-data
remove-data:
	helm uninstall $(NAME)