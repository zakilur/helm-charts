# Testing Multi Mesh Communication with a Game of Ping Pong

This guide walks through a multi-mesh Minikube deployment and demonstrates two common patterns for cross-mesh communication. The first setup is service sidecar to ingress edge, where the service sidecar is configured to talk directly to the ingress edge of the second mesh:

![image|690x233](https://user-images.githubusercontent.com/5482080/65241040-9e831200-dab0-11e9-9752-851ae951b6c9.png) 

The second configuration uses an egress edge proxy. Instead of pointing each service to the ingress edge of the other mesh, only the egress proxy knows about the mesh #2 cluster and all services route to it instead. This can be beneficial for security and for monitoring cross-mesh traffic:

![image|690x229](https://user-images.githubusercontent.com/5482080/65241040-9e831200-dab0-11e9-9752-851ae951b6c9.png)

## Deploying Minikube Clusters

This tutorial is based off a tag in the helm-charts repo called `multimesh-tutorial`. The first step is to check it out:

`git checkout multimesh-tutorial`

Next we need to install Grey Matter into 2 separate Minikube clusters. [Follow this guide](https://github.com/DecipherNow/helm-charts/blob/release-2.0/docs/Deploy%20with%20Minikube.md) to install Grey Matter into the first cluster, except when starting minikube use the `-p gm-deploy-1` flag (note the suffix) so we can differentiate our 2 clusters. For the second cluster, follow exactly the same steps except when starting minikube, name the profile `-p gm-deploy-2`.

You should be able to see the current minikube cluster by running `minikube profile`, and you can switch between them by running `minikube profile gm-deploy-2` and vice versa. Kubernetes will automatically switch contexts, but if you want to see for yourself you can run `kubectl config current-context`.

By this point, you should have gone through the Grey Matter deployment twice for each minikube cluster, and should be able to hit the edge of both meshes.

## Deploy the test service

To play our game of ping pong, we're going to use the [passthrough service](https://github.com/dgoldstein1/passthough-service) that David Goldstein wrote for
testing requests. Before we deploy it, make sure you're in the first cluster by running `minikube profile gm-deploy-1`. 

In `examples/multimesh/`, you will find `passthrough.yaml`. The passthrough service has been configured with the name of the current mesh and the endpoint of the service in mesh #2 that we want it to hit. Run the following command to deploy the service:

`kubectl apply -f examples/multimesh/passthrough.yaml`

Before deploying it into mesh #2, open `examples/multimesh/passthrough.yaml` and change the `MESH_ID` on line 34 to `mesh 2` and `PING_RESPONSE_URL` on line 44 to `https://localhost:8080/mesh1/services/passthrough/latest/ping?pause=2`

Save the file, switch minikube profiles, and deploy passthrough into the second mesh:

```
minikube profile gm-deploy-2
kubectl apply -f passthrough.yaml
```

While you're still in the second mesh, run `minikube service --https=true voyager-edge` and note down the ip and ports. We're going to use these values in the next section. Now, switch back to mesh #1: `minikube profile gm-deploy-1`. 

## Create Grey Matter objects

We will use the `greymatter` cli to create the routes, clusters, and shared_rules we need for our 2 meshes to communicate. To do so, expose gm-control-api to your local machine:

```
kubectl port-forward $(kubectl get pods --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' | grep '^gm-control-api-\d') 8088:5555
```

Then in another tab, point the cli to gm-control-api by setting these env vars:

```
export GREYMATTER_CONSOLE_LEVEL=debug
export GREYMATTER_API_HOST=localhost:8088
export GREYMATTER_API_KEY=xxx
export GREYMATTER_API_SSL=false
export GREYMATTER_API_INSECURE=true
export EDITOR=vim
```

Now we are ready to create some objects! We're currently in mesh #1, and want to configure the passthrough service to communicate with the passthrough service in mesh #2. Open `examples/multimesh/json/cluster-mesh-2.json` and fill in the instances array with the host/port that you noted from mesh #2. Save the file and run:

```sh
greymatter create cluster < examples/multimesh/json/cluster-mesh-2.json
```

Next, we'll create a shared_rule that points to the cluster we just made. You can think of shared_rules like traffic management configuration. Take a look at `examples/multimesh/shared-rule-mesh-2.json` and notice how it directs requests to the `cluster-mesh-2` we just created. 

```sh
greymatter create shared_rules < examples/multimesh/json/shared-rule-mesh-2.json
```

Finally we can create the route objects. Look at `route-passthrough-to-mesh-2.json` and `route-passthrough-to-mesh-2-slash.json`. Notice how they both point to the shared_rules object we just created. 

```sh
# It is very important to create routes in this order!
greymatter create route < examples/multimesh/json/route-passthrough-to-mesh-2-slash.json
greymatter create route < examples/multimesh/json/route-passthrough-to-mesh-2.json
```

Now we can test that our setup is working in the first mesh by visiting `https://<VOYAGER_EDGE_MESH_1>/services/passthrough/latest/mesh2/services/passthrough/latest/ping`. (phew) This should hit the passthrough service in mesh #2!

It's not much of a game yet if our second mesh can't respond with a pong. For the second passthrough service to communicate back, we need to repeat this whole section again, but for the `gm-deploy-2` cluster. Just like we did earlier note the IP/ports for voyager-edge in mesh #1, and then run the following commands:

```sh
# Switch to mesh 2
minikube profile gm-deploy-2
# Fill in cluster-mesh-1.json with IP ports and save
greymatter create cluster < examples/multimesh/json/cluster-mesh-1.json
# Create shared_rule and routes
greymatter create shared_rules < examples/multimesh/json/shared-rule-mesh-1.json
greymatter create route < examples/multimesh/json/route-passthrough-to-mesh-1-slash.json
greymatter create route < examples/multimesh/json/route-passthrough-to-mesh-1.json
```

## Playing ping pong

We're ready to play some multi mesh ping pong! Follow logs for the passthrough service in both meshes, and then initiate the game by hitting:

`https://<VOYAGER_EDGE_MESH_1>/services/passthrough/latest/serve`

You can see a video demo here: https://drive.google.com/file/d/1p6Ww_NfEmyslCvWYJq2DSyW69Zq62G7m/view?usp=sharing

## Deploying with an egress edge proxy

Now that we've got a game of ping pong from service to edge, let's look at the same setup using an egress edge proxy to handle cross-mesh communication.

