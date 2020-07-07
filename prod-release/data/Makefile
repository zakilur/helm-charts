SHELL := /bin/bash
NAME-DATA:=data
CHART_DATA := .
HELM_REPO:=decipher

include ../output.mk

wsa-data:
	$(eval WAITERSACHECK-DATA=$(shell kubectl get sa waiter-sa | tail -n +2 | awk '{if ($$1=="waiter-sa") print "--set=global.waiter.service_account.create=false"}'))
	echo $(WAITERSACHECK-DATA)

.PHONY: gm-data
gm-data: wsa-data
	helm install $(NAME-DATA) gm-data $(WAITERSACHECK-DATA) -f ../global.yaml

clean-data:
	rm -f ./charts/*

template-data: $(BUILD_NUMBER_FILE)
	mkdir -p $(OUTPUT_PATH)
	helm template $(NAME-DATA) $(HELM_REPO)/data --version 2.2.0 $(WAITERSACHECK-DATA)  -f custom-data-values.yaml -f ../global.yaml > $(OUTPUT_PATH)/helm-$(NAME-DATA)$(BN).yaml

.PHONY: data
data: wsa-data
	helm install $(NAME-DATA) $(HELM_REPO)/data --version 2.2.0 $(WAITERSACHECK-DATA) -f custom-data-values.yaml -f ../global.yaml

.PHONY: upgrade-data
upgrade-data: wsa-data
	helm upgrade $(NAME-DATA) $(HELM_REPO)/data --version 2.2.0 $(WAITERSACHECK-DATA) -f custom-data-values.yaml -f ../global.yaml

.PHONY: remove-data
remove-data:
	helm uninstall $(NAME-DATA)

set-imagePullPolicy-always:  wsa-data
	helm upgrade $(NAME-DATA) $(HELM_REPO)/data --version 2.2.0 $(WAITERSACHECK-DATA) -f custom-data-values.yaml -f ../global.yaml \
		--set internal-data.data.image_pull_policy=Always --set internal-data.sidecar.image_pull_policy=Always --set internal-data.mongo.image_pull_policy=Always