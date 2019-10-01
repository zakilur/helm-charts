# Configuring multimesh: a ping-pong demo

This guide demonstrates two common patterns for cross-mesh communication by configuring two services in different meshes to play a game of ping pong. The first setup is service sidecar to ingress edge, where the service sidecar is configured to talk directly to the ingress edge of the second mesh:

![image|690x233](https://user-images.githubusercontent.com/5482080/65241040-9e831200-dab0-11e9-9752-851ae951b6c9.png)

The second configuration uses an egress edge proxy. Instead of pointing each service to the ingress edge of the other mesh, only the egress proxy knows about the second mesh and all services route to it instead. This can be beneficial for security and for monitoring cross-mesh traffic:

![image|690x229](https://user-images.githubusercontent.com/5482080/65241040-9e831200-dab0-11e9-9752-851ae951b6c9.png)

## Setup

This tutorial assumes you have two Grey Matter meshes running concurrently. For more information on deploying a mesh, see [Deploy with Minikube](https://github.com/DecipherNow/helm-charts/blob/release-2.0/docs/Deploy%20with%20Minikube.md). You'll need to be able to hit the edge of both meshes and should note down the ip/ports of each.

## Deploy the test services

To play our game of ping pong, we're going to deploy a [passthrough service](https://github.com/dgoldstein1/passthough-service) in both meshes which will volley requests back and forth.

We've created a basic deployment configuration for the ping pong service called `passthrough.yaml` which you can download here. The passthrough service has been configured with the name of the current mesh and the endpoint of the service in mesh #2 that we want it to hit. Run the following command to deploy:

`kubectl apply -f passthrough.yaml`

Before deploying it into mesh #2, open `passthrough.yaml` and change the `MESH_ID` on line 34 to `mesh 2` and `PING_RESPONSE_URL` on line 44 to `https://localhost:8080/mesh1/services/passthrough/latest/ping?pause=2`

Save the file and deploy passthrough into the second mesh.

## Create Grey Matter objects

Now we are ready to configure the mesh so that our two services can play. Download and open `cluster-mesh-2.json` and fill in the instances array with the host/port that you noted from mesh #2. Save the file and run:

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
greymatter create route < examples/multimesh/json/route-passthrough-to-mesh-2-slash.json
greymatter create route < examples/multimesh/json/route-passthrough-to-mesh-2.json
```

It's not much of a game yet if our second mesh can't respond. For the second passthrough service to communicate back, we need to repeat this whole section again in the second mesh. Just like we did earlier note the IP/ports for the ingress edge in mesh #1, and then run the following commands:

```sh
# Fill in cluster-mesh-1.json with IP ports and save
greymatter create cluster < examples/multimesh/json/cluster-mesh-1.json
# Create shared_rule and routes
greymatter create shared_rules < examples/multimesh/json/shared-rule-mesh-1.json
greymatter create route < examples/multimesh/json/route-passthrough-to-mesh-1-slash.json
greymatter create route < examples/multimesh/json/route-passthrough-to-mesh-1.json
```

## Playing ping pong

We're ready to play some multimesh ping pong! Follow logs for the passthrough service in both meshes, and then initiate the game by hitting:

`https://<VOYAGER_EDGE_MESH_1>/services/passthrough/latest/serve`

You can see a video demo here: https://drive.google.com/file/d/1p6Ww_NfEmyslCvWYJq2DSyW69Zq62G7m/view?usp=sharing

## Deploying with an egress edge proxy

Now that we've got a game of ping pong from service to edge, let's look at the same setup using an egress edge proxy to handle cross-mesh communication.
