SHELL := /bin/bash
mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))

NAME-EDGE:=edge

HELM_REPO:=decipher

pwd_name := $(notdir $(PWD))

include ../output.mk

.PHONY: edge
edge:
	helm install $(NAME-EDGE) $(HELM_REPO)/edge --version 2.2.1 -f custom-edge-values.yaml -f ../global.yaml

.PHONY: remove-edge
remove-edge:
	helm uninstall $(NAME-EDGE)

.PHONY: upgrade-edge
upgrade-edge:
	helm upgrade $(NAME-EDGE) $(HELM_REPO)/edge --version 2.2.1 -f custom-edge-values.yaml -f ../global.yaml
	
template-edge: $(BUILD_NUMBER_FILE)
	mkdir -p $(OUTPUT_PATH)
	helm template $(NAME-EDGE) $(HELM_REPO)/edge --version 2.2.1 -f custom-edge-values.yaml -f ../global.yaml > $(OUTPUT_PATH)/helm-edge$(BN).yaml

set-imagePullPolicy-always:
	helm upgrade $(NAME-EDGE) $(HELM_REPO)/edge --version 2.2.1 -f custom-edge-values.yaml -f ../global.yaml --set edge.image_pull_policy=Always