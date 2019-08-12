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
For Kubernetes, you need to take some additional steps to install Voyager, the ingress controller we use. For OpenShift, we use their `Route`s, which are effectively the same as Kubernetes ingresses.

## Configuration

The following table lists the configurable parameters of the edge chart and their default values.

## Routing

All routing configuration is defined by the `helm-charts/gm-control-api/json` folder, which specifies all of the mesh objects to create for each service both for its own proxy (service) and for routing from the edge node to its proxy (edge), along with any special mesh objects needed (aka the domain, edge cluster, etc).

Currently, each service is served at `/services/dashboard/latest/`. Previously, we had served each route at a URL containing the version of the service (e.g. `/services/dashboard/3.0.0/`) However, in order to provide better flexibility, the GM 2.0 deployment will only provide the first one for now.

#### Caveats
This is implemented by a helper template (in  `templates/_helpers.tpl`) which loops over the global envvars and uses local ones if they are available. This means that to use a sidecar environment variable at the local level, its name and type must already be defined at the global level, however, a global default does not need to be set.

If no value is found, either at the local level or in a global default, the template will just ignore that environment variable.

To support deploying the services individually, we copy the `greymatter` `_envvars_.tpl` into each service's `template` folder, which allows Helm to see it even when it is note used as a subchart. The template determines that if the value `.Values.global.sidecar` is not set, then it will only use the local `.Values.sidecar` options.
To copy `_envvars.tpl`, run this command:

```sh
echo **/templates | xargs -n 1 | grep -v greymatter/ | xargs -I{} sh -c 'cp greymatter/templates/_envvars.tpl "$1"' -- {}
```

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
