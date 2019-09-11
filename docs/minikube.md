# minikube 

Minikube allows us to set up and test a Kubernetes cluster locally, which is useful for applying and testing out configurations before deployment.

## Tools

You will need the following tools, tested for both mac and linux for the following versions:

- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)@1.15.3
- [minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/)@1.3.1
- [virtualbox](https://www.virtualbox.org/wiki/Downloads)@6.0.12
- [helm](https://github.com/helm/helm/releases)@2.14.3

## Setup Minikube

To launch a minikube cluster, run:
```console
minikube start -p gm-deploy  --memory 4096 --cpus 4
```
We specify 4gb of memory and 4 processors because the 10+ containers needed for greymatter and helm will throw memory exceptions with the default 2gb and 2 processors. Specifying `-p gm-deploy` will create a new kubernetes cluster and set the namespace to `gm-deploy`.

You should see the following output:

```console
😄  [gm-deploy] minikube v1.3.1 on Ubuntu 18.04
🔥  Creating virtualbox VM (CPUs=4, Memory=4096MB, Disk=20000MB) ...
🐳  Preparing Kubernetes v1.15.2 on Docker 18.09.8 ...
🚜  Pulling images ...
🚀  Launching Kubernetes ... 
⌛  Waiting for: apiserver proxy etcd scheduler controller dns
🏄  Done! kubectl is now configured to use "gm-deploy
```

## Setup Helm

Before running helm commands, we need to configure our helm tiller. This is the server which runs on our kubernetes cluster and acts as a endpoint for our command line `helm` commands.

```console
$ helm init
$HELM_HOME has been configured at /home/$USER/.helm.

Tiller (the Helm server-side component) has been installed into your Kubernetes Cluster.

Please note: by default, Tiller is deployed with an insecure 'allow unauthenticated users' policy.
To prevent this, run `helm init` with the --tiller-tls-verify flag.
For more information on securing your installation see: https://docs.helm.sh/using_helm/#securing-your-helm-installation
```

Then add the decipher repo to Helm using your LDAP credentials:

```sh
helm repo add decipher https://nexus.production.deciphernow.com/repository/helm-hosted --username <ldap username> --password <ldap password>
```

Now we need to load our charts into our helm server. This is done with `helm dep up`, which loads our charts and the dependencies of our charts into the helm server. We specify the folder `greymatter` to load all the needed charts in the `greymatter/requirements.yaml` file.

```console
$ helm dep up greymatter
Hang tight while we grab the latest from your chart repositories...
...Unable to get an update from the "local" chart repository (http://127.0.0.1:8879/charts):
	Get http://127.0.0.1:8879/charts/index.yaml: dial tcp 127.0.0.1:8879: connect: connection refused
...Successfully got an update from the "decipher" chart repository
...Successfully got an update from the "appscode" chart repository
...Successfully got an update from the "stable" chart repository
Update Complete.
Saving 11 charts
Downloading voyager from repo https://charts.appscode.com/stable/
Deleting outdated charts
```
Notice that helm has added the directory `greymatter/charts` which is untracked by git. After installing dependencies it should have a bunch of tarballs.

*note: if you make any changes to files other than `working-custom.yaml` you will need to run `helm dep up greymatter` again to update these charts in the cluster.*

## Configure Voyager Ingress

At this writing there is [an issue](https://github.com/appscode/voyager/issues/1415) specifying voyager ingress as a dependency, so we need to manually configure voyager ingress locally before launching our greymatter cluster. This can be done with following commands:

```sh
export PROVIDER=minikube
helm repo add appscode https://charts.appscode.com/stable/
helm repo update
helm install appscode/voyager --name voyager-operator --version 10.0.0 \
  --namespace kube-system \
  --set cloudProvider=$PROVIDER \
  --set enableAnalytics=false
```

See `docs/Ingress.md` for more information.

## Configure Docker Secrets

Helm needs valid docker credentials to pull and run decipher docker containers. Enter in your docker creds into the secret `dockerCredentials` in `working-custom.yaml`.

## Install Greymatter

With our dependencies loaded, we're now ready to install greymatter. The following command writes out all templated files with values from `working-custom.yaml` and the default `values.yaml` in each chart directory. `working-custom.yaml` takes precedence. Specifying --name will give our helm deployment the name `gm`.

```console
$ helm install greymatter -f working-custom.yaml --name gm
...
NOTES:
Grey Matter 2.0.0-dev has been installed.

gm deployed to namespace "default" at 06:56:56 on 09/11/06


NOTE: It may take a few minutes for the installation to become stable.
    You can watch the status of the pods by running 'kubectl get pods -w -n default'
Once the environment has spun up you will be able to view Grey Matter's Dashboard at:
    https://.*/services/dashboard/latest/       
```

We also have the option to specify:
  - "--replace" will replace an existing deployment
  - "--dry-run" will print all kubernetes configs to stdout

We can run `helm ls` to see all our current deployments and `helm delete --purge $DEPLOYMENT` to delete deployments. If you need to make changes, you can run `helm upgrade gm greymatter -f working-custom.yaml` to update your release in place.

## Ingress

There are two pods which control our ingress:
  - `edge` validates client-facing certificates, gets routing rules from gm-control-api
	- `voyager-edge` our ingress controller. Edge isn't exposed to the outside world, and in a real deployment we need to tie our cluster ingress to an IP address. This points to `edge`.
	
Voyager operator also creates a service:
  - `voyager-gm-deploy` exposes the above HAProxy pods to the internet
 
To hit our cluster, we can access voyager-edge:

```console
$ minikube service --https=true voyager-edge
|-----------|--------------|--------------------------------|
| NAMESPACE |     NAME     |              URL               |
|-----------|--------------|--------------------------------|
| default   | voyager-edge | http://192.168.99.102:31581    |
|           |              | http://192.168.99.102:31975    |
|-----------|--------------|--------------------------------|
🎉  Opening kubernetes service  default/voyager-edge in default browser...
🎉  Opening kubernetes service  default/voyager-edge in default browser...
```

Then open up https://192.168.99.102:31581 in your browser (notice the http**s**). You should be prompted for your Decipher localuser certificate and be taken to the dashboard. Once there, make sure all services are "green" and then pat yourself on the back -- you deployed Greymatter to minikube!!

## Debugging

To see the status of kubernetes configs, you can access the kubernetes dashboard running within the minikube cluster with `minikube dashboard`

To debug the mesh, you can access the envoy admin ui for the edge proxy by running:

```console
kubectl port-forward $(kubectl get pods --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' | grep ^edge) 8088:8001
```

Then open http://localhost:8088

## Authors

- David Goldstein
- Kait Moreno