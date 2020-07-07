SHELL := /bin/bash
NAME-SENSE:=sense
CHART-SENSE := .

HELM_REPO:=decipher

include ../output.mk

wsa-sense:
	$(eval WAITERSACHECK-SENSE=$(shell oc get sa waiter-sa | tail -n +2 | awk '{if ($$1=="waiter-sa") print "--set=global.waiter.service_account.create=false"}'))
	echo $(WAITERSACHECK-SENSE)

clean-sense:
	rm -f ./charts/*

template-sense: $(BUILD_NUMBER_FILE)
	mkdir -p $(OUTPUT_PATH)
	helm template $(NAME-SENSE) $(HELM_REPO)/sense --version 2.2.1 $(WAITERSACHECK-SENSE) -f custom-sense-values.yaml  -f ../global.yaml > $(OUTPUT_PATH)/helm-$(NAME-SENSE)$(BN).yaml

.PHONY: sense
sense: wsa-sense
	helm install $(NAME-SENSE) $(HELM_REPO)/sense --version 2.2.1 $(WAITERSACHECK-SENSE) -f custom-sense-values.yaml -f ../global.yaml --timeout 10m --wait

.PHONY: upgrade-sense
upgrade-sense: wsa-sense
	helm upgrade $(NAME-SENSE) $(HELM_REPO)/sense --version 2.2.1 $(WAITERSACHECK-SENSE) -f custom-sense-values.yaml -f ../global.yaml --no-hooks --install

.PHONY: sense-install-inline
sense-install-inline: upgrade-sense

.PHONY: remove-sense
remove-sense:
	helm uninstall $(NAME-SENSE)

set-imagePullPolicy-always:  wsa-sense
	helm upgrade $(NAME-SENSE) $(HELM_REPO)/sense --version 2.2.1 $(WAITERSACHECK-SENSE) -f custom-sense-values.yaml -f ../global.yaml --no-hooks --install \
		--set slo.slo.image_pull_policy=Always --set slo.sidecar.image_pull_policy=Always \
		--set dashboard.dashboard.image_pull_policy=Always --set dashboard.sidecar.image_pull_policy=Always \
		--set catalog.catalog.image_pull_policy=Always --set catalog.sidecar.image_pull_policy=Always