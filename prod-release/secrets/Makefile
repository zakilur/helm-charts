SHELL := /bin/bash

mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))
pwd_name := $(notdir $(PWD))
HELM_REPO:=adx


copy-credentials:
	cp ../credentials.yaml .

.PHONY: helm-repo-update
helm-repo-update:
	helm repo update

.PHONY: secrets
secrets: helm-repo-update copy-credentials values-validation
	helm secrets install secrets $(HELM_REPO)/secrets --version 2.2.0 -f custom-secrets.yaml -f credentials.yaml -f ../global.yaml

.PHONY: upgrade-secrets
upgrade-secrets: helm-repo-update copy-credentials values-validation
	helm secrets upgrade secrets $(HELM_REPO)/secrets --version 2.2.0 -f custom-secrets.yaml -f credentials.yaml -f ../global.yaml
	rm credentials.yaml

values-validation:
	# Ensure that the rds.enabled is true in secrets and in fabric values files
	if [ "$(shell cat secrets.custom-secrets-values.yaml | grep -A1 rds | grep enabled: | awk '{print $$2}')" == "$(shell cat ../sense/custom-sense-values.yaml | grep -A1 rds | grep enabled: | awk '{print $$2}')" ]; then \
		echo "rds.enabled in secrets and sense match"; \
	else \
		echo "rds.enabled in secrets and sense DO NOT MATCH.  Secrets will not be created"; \
		exit 2;\
	fi


.PHONY: remove-secrets
remove-secrets:
	helm uninstall secrets