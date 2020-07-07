SHELL := /bin/bash
NAME-FABRIC:=fabric
HELM_REPO:=adx

include ../output.mk

wsa-fabric:
	$(eval WAITERSACHECK-FABRIC=$(shell oc get sa waiter-sa | tail -n +2 | awk '{if ($$1=="waiter-sa") print "--set=global.waiter.service_account.create=false"}'))

clean-fabric:
	rm -f ./charts/*

template-fabric: $(BUILD_NUMBER_FILE)
	mkdir -p $(OUTPUT_PATH)
	helm template $(NAME-FABRIC) $(HELM_REPO)/fabric --version 2.2.1 $(WAITERSACHECK-FABRIC) -f custom-fabric-values.yaml -f ../global.yaml > $(OUTPUT_PATH)/helm-$(NAME-FABRIC)$(BN).yaml

.PHONY: fabric
fabric: wsa-fabric
	helm install $(NAME-FABRIC) $(HELM_REPO)/fabric --version 2.2.1 $(WAITERSACHECK-FABRIC) -f custom-fabric-values.yaml -f ../global.yaml

.PHONY: upgrade-fabric
upgrade-fabric: wsa-fabric
	helm upgrade $(NAME-FABRIC) $(HELM_REPO)/fabric --version 2.2.1 $(WAITERSACHECK-FABRIC) -f custom-fabric-values.yaml -f ../global.yaml --no-hooks

.PHONY: remove-fabric
remove-fabric:
	helm uninstall $(NAME-FABRIC)

set-imagePullPolicy-always:  wsa-fabric
	helm upgrade $(NAME-FABRIC) $(HELM_REPO)/fabric --version 2.2.1 $(WAITERSACHECK-FABRIC) -f custom-fabric-values.yaml -f ../global.yaml --no-hooks \
		--set control-api.controlApi.image_pull_policy=Always --set control-api.sidecar.image_pull_policy=Always \
		--set control.control.image_pull_policy=Always \
		--set jwt.jwt.image_pull_policy=Always --set jwt.sidecar.image_pull_policy=Always \
		--set internal-jwt.jwt.image_pull_policy=Always --set internal-jwt.sidecar.image_pull_policy=Always --set internal-jwt.redis.image_pull_policy=Always