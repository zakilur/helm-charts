# GM-data

## TL;DR;

```console
$ helm install data
```

## Introduction

This chart bootstraps a data deployment on a [Kubernetes](http://kubernetes.io) or [OpenShift](https://www.openshift.com/) cluster using the [Helm](https://helm.sh) package manager.

## Installing the Chart

To install the chart with the release name `<my-release>`:

```console
$ helm install data --name <my-release>
```

The command deploys data on the cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

## Uninstalling the Chart

To uninstall/delete the `<my-release>` deployment:

```console
$ helm delete <my-release>
```

The command removes all components associated with the chart and deletes the release.

## Configuration

The following table lists the configurable parameters of the data chart and their default values.

| Parameter                          | Description        | Default                                                        |
| ---------------------------------- | ------------------ | -------------------------------------------------------------- |
| data.version                       |                    | 0.2.3                                                          |
| data.client_jwt_endpoint_address   |                    | localhost                                                      |
| data.client_jwt_endpoint_use_tls   |                    | 'true'                                                         |
| data.base_path                     |                    | /services/data/0.2.3                                           |
| data.image                         |                    | docker.production.deciphernow.com/deciphernow/gm-data:0.2.3    |
| data.certs_mount_point             |                    | /certs                                                         |
| data.imagePullPolicy               |                    | Always                                                         |
| data.use_tls                       |                    | true                                                           |
| data.master_key                    |                    | ac8923[lkn43589vi23kl4rfgv0ws                                  |
| data.aws.access_key                |                    |                                                                |
| data.aws.secret_key                |                    |                                                                |
| data.aws.region                    |                    |                                                                |
| data.aws.bucket                    |                    |                                                                |
| data.resources.limits.cpu          |                    | 250m                                                           |
| data.resources.limits.memory       |                    | 512Mi                                                          |
| data.resources.requests.cpu        |                    | 100m                                                           |
| data.rsources.requests.memory      |                    | 128Mi                                                          |
| data.mongo.replicas                |                    | 1                                                              |
| data.mongo.image                   |                    | 'deciphernow/mongo:4.0.3'                                      |
| data.mongo.imagePullPolicy         |                    | Always                                                         |
| data.mongo.pvc_size                |                    | 40                                                             |
| data.mongo.resources.limits.cpu    |                    | 200m                                                           |
| data.mongo.resources.limits.memory |                    | 512Mi                                                          |
| data.mongo.resources.requests      |                    | 100m                                                           |
| data.mongo.resources.memory        |                    | 128Mi                                                          |
| data.credentials.secret_name       |                    | 'mongo-credentials'                                            |
| data.credentials.root_username     |                    | 'mongo'                                                        |
| data.credentials.root_password     |                    | 'mongo'                                                        |
| data.credentials.database          |                    | 'gmdata'                                                       |
| data.admin_password                |                    | 'mongopassword'                                                |
| data.ssl.enabled                   |                    | false                                                          |
| data.ssl.name                      |                    | mongo-ssl-certs                                                |
| data.ssl.mount_path                |                    | /secret/cert                                                   |
| data.certificates.ca               |                    | {...}                                                          |
| data.certificates.cert             |                    | {...}                                                          |
| data.certificates.key              |                    | {...}                                                          |
| data.certificates.cert_key         |                    | {...}                                                          |
|                                    |                    |                                                                |
| sidecar.version                    | Proxy Version      | 0.7.1                                                          |
| sidecar.image                      | Proxy Image        | 'docker.production.deciphernow.com/deciphernow/gm-proxy:0.7.1' |
| sidecar.proxy_dynamic              |                    | 'true'                                                         |
| sidecar.metrics_key_function       |                    | depth                                                          |
| sidecar.ingress_use_tls            | Enable TLS         | 'true'                                                         |
| sidecar.imagePullPolicy            | Image pull policy  | Always                                                         |
| sidecar.create_sidecar_secret      | Create Certs       | false                                                          |
| sidecar.certificates               |                    | {name:{ca: ... , cert: ... , key ...}}                         |
| sidecar.resources.limits.cpu       |                    | 200m                                                           |
| sidecar.resources.limits.memory    |                    | 512Mi                                                          |
| sidecar.resources.requests.cpu     |                    | 100m                                                           |
| sidecar.resources.requests.memory  |                    | 128Mi                                                          |
|                                    |                    |                                                                |
| xds.port                           | Xds Port           | 18000                                                          |
| xds.cluster                        | XDS Cluster        | greymatter                                                     |
|                                    |                    |                                                                |
| exhibitor.replicas                 | Exhibitor Replicas | 1                                                              |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

- All the files listed under this variable will overwrite any existing files by the same name in the data config directory.
- Files not mentioned under this variable will remain unaffected.

```console
$ helm install data --name <my-release> \
  --set=jwt.version=v0.2.0, sidecar.ingress_use_tls='false'
```

Alternatively, a YAML file that specifies the values for the above parameters can be provided while installing the chart. For example :

```console
$ helm install data --name <my-release> -f custom.yaml
```
