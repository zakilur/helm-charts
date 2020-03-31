pwd_name := $(notdir $(PWD))

NAME-DATA:=data
CHART_DATA := .

ifeq ($(pwd_name),helm-charts)
	CHART_DATA=$@
	INSTALLDIR := data/
	override DEPUPDIR-DATA := data
endif
ifeq ($(pwd_name),data)
	CHART_DATA= .
	INSTALLDIR := 
	override DEPUPDIR-DATA := .
endif


wsa-data:
	$(eval WAITERSACHECK-DATA=$(shell kubectl get sa waiter-sa | tail -n +2 | awk '{if ($$1=="waiter-sa") print "--set=global.waiter.service_account.create=false"}'))
	echo $(WAITERSACHECK-DATA)

.PHONY: gm-data
gm-data:
	helm install $(NAME-DATA) $(INSTALLDIR)$(CHART_DATA) --set=global.environment=kubernetes $(WAITERSACHECK-DATA)

.PHONY: jwt
jwt:
	helm install $(NAME-DATA) $(INSTALLDIR)$(CHART_DATA) --set=global.environment=kubernetes $(WAITERSACHECK-DATA)

.PHONY: jwt-gov
jwt-gov:
	helm install $(NAME-DATA) $(INSTALLDIR)$(CHART_DATA) --set=global.environment=kubernetes $(WAITERSACHECK-DATA)

clean-data:
	echo "$(DEPUPDIR-DATA)"
	rm -f $(DEPUPDIR-DATA)/charts/*

package-data: clean-data
	echo "target hit package-data"
	helm dep up $(DEPUPDIR-DATA)

.PHONY: data
data: package-data
	helm install $(NAME-DATA) $(CHART_DATA) --set=global.environment=kubernetes $(WAITERSACHECK-DATA)

.PHONY: remove-data
remove-data:
	helm uninstall $(NAME-DATA)