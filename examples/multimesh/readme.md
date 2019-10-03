# Configuring multimesh: a ping-pong demo

This guide demonstrates two common patterns for cross-mesh communication by configuring two services in different meshes to play a game of ping pong.

## Requirements

Before you start you will need:

- Two running meshes. You'll need to be able to hit the edge of both meshes and should note down the ip/ports of each.
- [docker](https://docs.docker.com/v17.09/engine/installation/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) and working understanding of kubernetes
- [greymatter](https://nexus.production.deciphernow.com/#browse/browse:raw-hosted:greymatter%2Fgm-cli%2Fgreymatter-0.5.1.tar.gz)
- knowledge of [how to add a service to the mesh](LINK)

## Deploy A Passthrough Service to Each Mesh

To play our game of ping pong, we're going to deploy a [passthrough service](https://github.com/dgoldstein1/passthough-service) in both meshes which will volley requests back and forth. First, configure the mesh.

[Create main service objects:](LINK)

- domain-passthrough
- listener-passthrough
- proxy-passthrough
- cluster-passthrough
- shared-rules-passthrough
- route-passthrough

[Create edge <-> service objects:](LINK)

- cluster-edge-to-passthrough
- shared-rules-edge-passthrough
- route-edge-passthrough
- route-edge-passthrough-slash

Now you can use our [passthrough deployment](LINK) spec to deploy the service, or write your own.

Once you've added the first passthrough service to mesh 1, verify that it's working by going to the endpoints:

```
# non-tls request
$EDGE_ENDPOINT/services/passthrough/latest/get?url=http://google.com
# tls request back through edge of mesh1
$EDGE_ENDPOINT/services/passthrough/latest/get?url=$EDGE_ENDPOINT/services/passthrough/latest/ping
```

If those requests don't return valid responses, you may want to look at [mesh debugging tips](https://notes.deciphernow.com/t/mesh-debugging-tips/751). Now we need to deploy our our service to our second mesh. In a kubernetes context, open `passthrough.yaml` and change the `MESH_ID` on line 34 to `mesh 2` and `PING_RESPONSE_URL` on line 44 to `https://localhost:8080/mesh1/services/passthrough/latest/ping?pause=1`. Save the file and deploy passthrough into the second mesh, using the same steps as before.

## Part I: Service to Ingress Edge Setup

For part one, our service will talk directly to the ingress edge of the second mesh:

![image|690x233](https://user-images.githubusercontent.com/5482080/65241124-d8ecaf00-dab0-11e9-97d3-d0159f096091.png)

After creating a passthrough service in both meshes, we are ready to configure the mesh so that our two services can play! To do this, we need to add routing from the passthrough service sidecar to the edge node in mesh 2. This requires a new `cluster`, `route`, and `shared_rules` object. In the folder you downloaded, there is a json folder with all the objects you'll need.

Open `cluster-mesh-2.json` and fill in the instances array with the host/port that you noted from mesh 2. Save the file and run:

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

Check that the passthrough service is able to connect to the other mesh by making the following request:

```
$MESH_1_ENDPOINT/services/passthrough/latest/get?url=https://localhost:8080/mesh2/services/passthrough/latest/ping
...
Pong. mesh=mesh 2
```

You should also see the following in the passthrough logs for mesh 2:

```
Received ping from localhost:8080. Connection type: HTTP/1.1
hitting back to: https://localhost:8080/mesh1/services/passthrough/latest/ping?pause=2
sleeping for 1 s
Response: 404 page not found
```

This means that the passthrough service on mesh 2 is receiving the "serve" but is hitting it back to the wrong endpoint (hence `404`).

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

You can see a video [demo here](https://drive.google.com/file/d/1p6Ww_NfEmyslCvWYJq2DSyW69Zq62G7m/view?usp=sharing).

## Part II: Egress Edge Proxy Setup

The second configuration uses an egress edge proxy. Instead of pointing each service to the ingress edge of the other mesh, only the egress proxy knows about the second mesh and all services route to it instead. This can be beneficial for security and for monitoring cross-mesh traffic:

![image|690x229](https://user-images.githubusercontent.com/5482080/65241040-9e831200-dab0-11e9-9752-851ae951b6c9.png)

Now that we've got a game of ping pong from service to edge, let's look at what it would take to use an egress edge proxy to handle cross-mesh communication. Instead of pointing routes from the service sidecar to the other mesh cluster, we're going to point them to the egress proxy.

First we'll need to apply the deployment config `egress-edge.yaml` by running `kubectl apply -f egress-edge.yaml`. Just like with passthrough, you'll also need to create the necessary Grey Matter objects to hook `egress-edge` into the mesh. You should have the following:

- domain-egress-edge
- listener-egress-edge
- proxy-egress-edge
- cluster-egress-edge
- shared-rules-egress-edge

Don't worry about creating any routes, we'll be setting those up next.

Run `greymatter edit route route-passthrough-to-mesh-2-slash` and update the shared_rules_key to `shared-rules-egress-edge`. Do the same for `route-passthrough-to-mesh-2`.

Create a route for the egress cluster <-> mesh #2:

```
greymatter create route < route-egress-to-mesh-2.json
```

Repeat this section for the second mesh, substituting any `-mesh-2` objects with their `-mesh-1` counterpart.

That's it! Follow logs for passthrough and egress-edge services in both meshes and hit the endpoint as described [above](#playing-ping-pong). You should see the requests flow from the service a -> egress edge a -> service b -> egress edge b.

## Authors

- Kaitlin Moreno
- David Goldstein
