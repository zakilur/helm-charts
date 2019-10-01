# Configuring multimesh: a ping-pong demo

This guide demonstrates two common patterns for cross-mesh communication by configuring two services in different meshes to play a game of ping pong. The first setup is service sidecar to ingress edge, where the service sidecar is configured to talk directly to the ingress edge of the second mesh:

![image|690x233](https://user-images.githubusercontent.com/5482080/65241040-9e831200-dab0-11e9-9752-851ae951b6c9.png)

The second configuration uses an egress edge proxy. Instead of pointing each service to the ingress edge of the other mesh, only the egress proxy knows about the second mesh and all services route to it instead. This can be beneficial for security and for monitoring cross-mesh traffic:

![image|690x229](https://user-images.githubusercontent.com/5482080/65241040-9e831200-dab0-11e9-9752-851ae951b6c9.png)

## Setup

This tutorial assumes you have two Grey Matter meshes running concurrently and know how to deploy a service. For more information on deploying a mesh, see [Deploy with Minikube](https://github.com/DecipherNow/helm-charts/blob/release-2.0/docs/Deploy%20with%20Minikube.md). You'll need to be able to hit the edge of both meshes and should note down the ip/ports of each.

## Deploy the test services

To play our game of ping pong, we're going to deploy a [passthrough service](https://github.com/dgoldstein1/passthough-service) in both meshes which will volley requests back and forth.

We've created a basic deployment configuration for the ping pong service called `passthrough.yaml` which you can download here. The passthrough service has been configured with the name of the current mesh and the endpoint of the service in mesh #2 that we want it to hit. Run the following command to deploy:

`kubectl apply -f passthrough.yaml`

Next, create the necessary Grey Matter objects to add the new passthrough service to the mesh. [You can see an example here.](https://github.com/DecipherNow/openshift-development/tree/master/deployments/control/json/ascii) You'll also need to set up clusters, routes, and shared_rules from edge <-> passthrough service which you can [find an example of here.](https://github.com/DecipherNow/openshift-development/tree/master/deployments/control/json/edge)

Before deploying it into mesh #2, open `passthrough.yaml` and change the `MESH_ID` on line 34 to `mesh 2` and `PING_RESPONSE_URL` on line 44 to `https://localhost:8080/mesh1/services/passthrough/latest/ping?pause=2`

Save the file and deploy passthrough into the second mesh, as well as the necessary grey matter objects.

## Part I: Service to Ingress Edge Setup

Now we are ready to configure the mesh so that our two services can play. In the folder you downloaded, there is a json folder with all the objects you'll need.

Open `cluster-mesh-2.json` and fill in the instances array with the host/port that you noted from mesh #2. Save the file and run:

```sh
greymatter create cluster < cluster-mesh-2.json
```

Next, we'll create a shared_rule that points to the cluster we just made. You can think of shared_rules like traffic management configuration. Take a look at `shared-rule-mesh-2.json` and notice how it directs requests to the `cluster-mesh-2` we just created.

```sh
greymatter create shared_rules < shared-rule-mesh-2.json
```

Finally we can create the route objects. Look at `route-passthrough-to-mesh-2.json` and `route-passthrough-to-mesh-2-slash.json`. Notice how they both point to the shared_rules object we just created.

```sh
# It is very important to create routes in this order!
greymatter create route < route-passthrough-to-mesh-2-slash.json
greymatter create route < route-passthrough-to-mesh-2.json
```

It's not much of a game yet if our second mesh can't respond. For the second passthrough service to communicate back, we need to repeat these steps in the second mesh, using `-mesh-1` versions of the json objects. Just like we did earlier note the IP/ports for the ingress edge of mesh #1, and then run the following commands:

```sh
# Fill in cluster-mesh-1.json with IP ports and save
greymatter create cluster < cluster-mesh-1.json
# Create shared_rule and routes
greymatter create shared_rules < shared-rule-mesh-1.json
greymatter create route < route-passthrough-to-mesh-1-slash.json
greymatter create route < route-passthrough-to-mesh-1.json
```

## Playing ping pong

We're ready to play some multimesh ping pong! Follow logs for the passthrough service in both meshes, and then initiate the game by hitting:

`https://<VOYAGER_EDGE_MESH_1>/services/passthrough/latest/serve`

You can see a video demo here: https://drive.google.com/file/d/1p6Ww_NfEmyslCvWYJq2DSyW69Zq62G7m/view?usp=sharing

## Part II: Egress Edge Proxy Setup

Now that we've got a game of ping pong from service to edge, let's look at what it would take to use an egress edge proxy to handle cross-mesh communication. Instead of pointing routes from the service sidecar to the other mesh cluster, we're going to point them to the egress proxy.

First we'll need to apply the deployment config found in `egress-edge.yaml` by running `kubectl apply -f egress-edge.yaml` and then create the necessary Grey Matter objects (domain, proxy, listener, cluster, shared_rules) to hook it into the mesh. Don't worry about creating any routes yet, we'll be setting those up next.

Run `greymatter edit route route-passthrough-to-mesh-1-slash` and update the shared_rules_key to `shared-rules-egress-edge`. Do the same for `route-passthrough-to-mesh-1`.

Create a route for the egress cluster <-> mesh #2:

```
greymatter create route < route-egress-to-mesh-2.json
```

Repeat this section for the second mesh, substituting any `-mesh-2` objects with their `-mesh-1` counterpart.

That's it! Follow logs for passthrough and egress-edge services in both meshes and hit the endpoint as described in [Playing ping pong](#playing-ping-pong). You should see the requests flow from the service a -> egress edge a -> service b -> egress edge b.
