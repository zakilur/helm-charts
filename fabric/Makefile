pwd_name := $(notdir $(PWD))

NAME-FABRIC:=fabric
CHART-FABRIC := .
DEPUPDIR-FABRIC:=fabric

ifeq ($(pwd_name),helm-charts)
	CHART-FABRIC=$@
	INSTALLDIR := fabric/
	override DEPUPDIR-FABRIC:=fabric
endif
ifeq ($(pwd_name),fabric)
	CHART-FABRIC= .
	INSTALLDIR := 
	override DEPUPDIR-FABRIC := .
endif

wsa-fabric:
	$(eval WAITERSACHECK-FABRIC=$(shell kubectl get sa waiter-sa | tail -n +2 | awk '{if ($$1=="waiter-sa") print "--set=global.waiter.service_account.create=false"}'))
	echo $(WAITERSACHECK-FABRIC)

.PHONY: control
control: wsa-fabric
	$(eval CHART-FABRIC=control)
	helm install $(NAME-FABRIC) $(INSTALLDIR)$(CHART-FABRIC) --set=global.environment=kubernetes $(WAITERSACHECK-FABRIC)

.PHONY: control-api
control-api: wsa-fabric
	$(eval CHART-FABRIC=control-api)
	helm install $(NAME-FABRIC) $(INSTALLDIR)$(CHART-FABRIC)  --set=global.environment=kubernetes $(WAITERSACHECK-FABRIC)

clean-fabric:
	echo "DEPDIR: $(DEPUPDIR-FABRIC)"
	rm -f $(DEPUPDIR-FABRIC)/charts/*

package-fabric: clean-fabric
	echo "target hit package-fabric"
	helm dep up $(DEPUPDIR-FABRIC)

.PHONY: fabric
fabric: package-fabric
	helm install $(NAME-FABRIC) $(CHART-FABRIC) --set=global.environment=kubernetes $(WAITERSACHECK-FABRIC)

.PHONY: remove-fabric
remove-fabric:
	helm uninstall $(NAME-FABRIC)

.PHONY: name
name:
	echo $(pwd_name)
	echo $(DEPUPDIR-FABRIC)