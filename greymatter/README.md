# Greymatter

## TL;DR;

```console
$ helm install greymatter
```

## Introduction

This chart bootstraps an greymatter deployment on a [Kubernetes](http://kubernetes.io) or [OpenShift](https://www.openshift.com/) cluster using the [Helm](https://helm.sh) package manager.

## Installing the Chart

To install the chart with the release name `<my-release>`:

```console
$ helm install greymatter --name <my-release>
```

The command deploys greymatter on the cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

## Making the cluster accessible from the internet

Take a look at the `edge` chart documentation for details on how Grey Matter is exposed to the internet in both OpenShift and Kubernetes environments.
For Kubernetes, you need to take some additional steps to install Voyager, the ingress controller we use.

## Configuration

The following table lists the configurable parameters of the edge chart and their default values.

### Global Configuration

| Parameter                        | Description       | Default    |
| -------------------------------- | ----------------- | ---------- |
| global.environment               |                   | kubernetes |
| global.domain                    | edge-ingress.yaml |            |
| global.route_url_name            | edge-ingress.yaml |            |
| global.remove_namespace_from_url | edge-ingress.yaml | false      |
| global.catalog.version           |                   | 0.3.6      |
| global.dashboard.version         |                   | latest     |
| global.data.version              |                   | 0.2.3      |
| global.documentation.version     |                   | 3.0.0      |
| global.edge.version              |                   | 0.7.1      |
| global.exhibitor.replicas        |                   | 1          |
| global.exhibitor.version         |                   |            |
| global.jwt.version               |                   | 0.2.0      |
| global.slo.version               |                   | 0.4.0      |
| global.xds.cluster               |                   | greymatter |
| global.xds.port                  |                   | 18000      |
| global.xds.version               |                   | 0.2.6      |

## Testing the Chart

To run a test, wait for dashboard to startup and you can hit the url displayed in the release notes, then use:

```console
$ helm test <deployment_name>
```

ex:

```console
$ helm test greymatter_test_deploy

#Result

RUNNING: greymatter_test_deploy-connection-test
PASSED: greymatter_test_deploy-connection-test
```

Running this command will spin up a new pod named `<service>-<deployment_name>-connection-test` which will run the tests defined in `greymatter/templates/tests`. These test pods do not automatically delete so if they need to be run multiple times then they will need to be deleted manually in the ui or with `oc delete pod <name>`.

### Tests

| Test Name               | Description            | Desired Result |
| ----------------------- | ---------------------- | -------------- |
| documentation-test.yaml | curl documentation url | 200            |
| catalog-test.yaml       | curl catalog url       | 200            |

## Uninstalling the Chart

To uninstall/delete the `<my-release>` deployment:

```console
$ helm delete <my-release>
```

The command removes all components associated with the chart and deletes the release.

## Configuration

The following table lists the configurable parameters of the greymatter chart and their default values.

| Parameter                     | Description  | Default                               |
| ----------------------------- | ------------ | ------------------------------------- |
|                               |              |                                       |
| sidecar.create_sidecar_secret | Create Certs | false                                 |
| sidecar.certificates          |              | {name:{ca: ... , cert: ..., key ...}} |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

- All the files listed under this variable will overwrite any existing files by the same name in the greymatter config directory.
- Files not mentioned under this variable will remain unaffected.

```console
$ helm install greymatter --name <my-release> \
  --set=jwt.version=v0.2.0, sidecar.ingress_use_tls='false'
```

Alternatively, a YAML file that specifies the values for the above parameters can be provided while installing the chart. For example :

```console
$ helm install greymatter --name <my-release> -f custom.yaml
```
