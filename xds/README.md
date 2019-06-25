# XDS

## TL;DR;

```console
$ helm install xds
```

## Introduction

This chart bootstraps an xds deployment on a [Kubernetes](http://kubernetes.io) or [OpenShift](https://www.openshift.com/) cluster using the [Helm](https://helm.sh) package manager.

## Installing the Chart

To install the chart with the release name `<my-release>`:

```console
$ helm install xds --name <my-release>
```

The command deploys xds on the cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

## Uninstalling the Chart

To uninstall/delete the `<my-release>` deployment:

```console
$ helm delete <my-release>
```

The command removes all components associated with the chart and deletes the release.

## Configuration

The following tables list the configurable parameters of the xds chart and their default values.

### Global Configuration

| Parameter                        | Description | Default    |
| -------------------------------- | ----------- | ---------- |
| global.environment               |             | kubernetes |
| global.domain                    |             |            |
| global.route_url_name            |             |            |
| global.remove_namespace_from_url |             |            |
| global.exhibitor.replicas        |             | 1          |

### Service Configuration

| Parameter                     | Description | Default                                                      |
| ----------------------------- | ----------- | ------------------------------------------------------------ |
| xds.version                   |             | 0.2.6                                                        |
| xds.image                     |             | 'docker.production.deciphernow.com/deciphernow/gm-xds:0.2.6' |
| xds.imagePullPolicy           |             | Always                                                       |
| xds.cluster                   |             | greymatter                                                   |
| xds.port                      |             | 18000                                                        |
| xds.use_zk                    |             | 'true'                                                       |
| xds.logging_level             |             | 'true'                                                       |
| xds.zk_base_path              |             | '/services'                                                  |
| xds.resources.limits.cpu      |             | 250m                                                         |
| xds.resources.limits.memory   |             | 512Mi                                                        |
| xds.resources.requests.cpu    |             | 100m                                                         |
| xds.resources.requests.memory |             | 128Mi                                                        |

### Sidecar Configuration

| Parameter                         | Description       | Default                                                        |
| --------------------------------- | ----------------- | -------------------------------------------------------------- |
| sidecar.version                   | Proxy Version     | 0.7.1                                                          |
| sidecar.image                     | Proxy Image       | 'docker.production.deciphernow.com/deciphernow/gm-proxy:0.7.1' |
| sidecar.imagePullPolicy           | Image pull policy | Always                                                         |
| sidecar.create_sidecar_secret     | Create Certs      | false                                                          |
| sidecar.certificates              |                   | {name:{ca: ... , cert: ... , key ...}}                         |
| sidecar.resources.limits.cpu      |                   | 200m                                                           |
| sidecar.resources.limits.memory   |                   | 512Mi                                                          |
| sidecar.resources.requests.cpu    |                   | 100m                                                           |
| sidecar.resources.requests.memory |                   | 128Mi                                                          |

Environment variables set in values.yaml:

| Environment variable    | Default                             |
| ----------------------- | ----------------------------------- |
| ingres_use_tls          | 'true'                              |
| ingres_ca_cert_path     | '/etc/proxy/tls/sidecar/ca.crt'     |
| ingress_cert_path       | '/etc/proxy/tls/sidecar/server.crt' |
| ingress_key_path        | '/etc/proxy/tls/sidecar/server.key' |
| metrics_port            | '8080                               |
| port                    | '8443'                              |
| kafka_zk_discover       | 'false'                             |
| kafka-server_connection | 'kafka:9091,kafka2:9091'            |
| kafka_enabled           | 'false'                             |
| kafka_topic             | 'xds'                               |
| metrics_key_function    | 'depth'                             |
| proxy_dynamic           | 'false'                             |
| obs_enabled             | 'false'                             |
| obs_enforce             | 'false'                             |
| obs_full_response       | 'false'                             |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

- All the files listed under this variable will overwrite any existing files by the same name in the xds config directory.
- Files not mentioned under this variable will remain unaffected.

```console
$ helm install xds --name <my-release> \
  --set=jwt.version=v0.2.0, sidecar.ingress_use_tls='false'
```

Alternatively, a YAML file that specifies the values for the above parameters can be provided while installing the chart. For example :

```console
$ helm install xds --name <my-release> -f custom.yaml
```
