WAITERSACHECK=$(shell kubectl get sa waiter-sa | tail -n +2 | awk '{if ($$1=="waiter-sa") print "present"}')
ifeq (${WAITERSACHECK},present)
	FLAG=--set=global.waiter.service_account.create=false
else
	FLAG=--set=global.waiter.service_account.create=true
endif

pwd_name := $(notdir $(PWD))

NAME:=fabric
CHART := .
DEPUPDIR-FABRIC:=fabric

ifeq ($(pwd_name),helm-charts)
	CHART=$@
	INSTALLDIR := fabric/
	override DEPUPDIR-FABRIC:=fabric
endif
ifeq ($(pwd_name),fabric)
	CHART= .
	INSTALLDIR := 
	override DEPUPDIR-FABRIC := .
endif

.PHONY: control
control:
	helm install $(NAME) $(INSTALLDIR)$(CHART) --set=global.environment=kubernetes $(FLAG)

.PHONY: control-api
control-api:
	helm install $(NAME) $(INSTALLDIR)$(CHART)  --set=global.environment=kubernetes $(FLAG)

clean-fabric:
	echo "DEPDIR: $(DEPUPDIR-FABRIC)"
	rm -f $(DEPUPDIR-FABRIC)/charts/*

package-fabric: clean-fabric
	echo "target hit package-fabric"
	helm dep up $(DEPUPDIR-FABRIC)

.PHONY: fabric
fabric: package-fabric
	helm install $(NAME) $(CHART) --set=global.environment=kubernetes $(FLAG)

.PHONY: remove-fabric
remove-fabric:
	helm uninstall $(NAME)

.PHONY: name
name:
	echo $(pwd_name)
	echo $(DEPUPDIR-FABRIC)