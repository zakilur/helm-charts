# Grey Matter Helm-Charts

- [Grey Matter Helm-Charts](#grey-matter-helm-charts)
  - [Prerequisites](#prerequisites)
  - [Set up Helm repo](#set-up-helm-repo)
  - [Install Secrets](#install-secrets)
    - [Global cert](#global-cert)
    - [SLO RDS based Postgres](#slo-rds-based-postgres)
  - [Install GreyMatter Service Mesh](#install-greymatter-service-mesh)
  - [Set all image_pull_policy to always](#set-all-image_pull_policy-to-always)

## Prerequisites

- helm 3.2.0
- greymatter cli

## Set up Helm repo

`helm repo add decipher https://nexus.production.deciphernow.com/repository/helm-hosted  --username <username> --password '<password>'`

## Install Secrets

Populate `credentials-template.yaml` and rename to `credentials.yaml`. *Don't check credentials.yaml in*

To install secrets run `make secrets`

### Global cert

By default this mesh is set up to use a global cert.  To do copy the ca, server cert, and key into the global.yaml file.

### SLO RDS based Postgres

This deployment is configured to use a Postgres that is provisioned using rds.  To make this connection you will need to pass the Postgres endpoint and the ca bundle.  

The endpoint is set in `sense/values.yaml` at `slo.postgres.rds.endpoint`.
The ca bundle is set at `secrets/values.yaml` at `postgres.ssl.certificates.ca`

## Install GreyMatter Service Mesh

1. `(cd fabric && make fabric)`
2. `(cd data && make data)`
3. `(cd edge && make edge)`
4. `(cd sense && make sense)`

## Set all image_pull_policy to always

Each Makefile has a target `set-imagePullPolicy-always` which will run a make upgrade and manually override all `imagePullPolicy` values with `Always`.  To revert these charts to their default run `make upgrade-<chart>`.