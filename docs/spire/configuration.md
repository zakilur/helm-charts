# Grey Matter Spire Configuration

All of the necessary configurations for spire can be found in `greymatter-spire.yaml`.

## Spire Configuration

To see specifics on Spire configuration, see the [Spire Server](https://github.com/spiffe/spire/blob/master/doc/spire_server.md)
and [Spire Agent](https://github.com/spiffe/spire/blob/master/doc/spire_agent.md) documentation.

Our configurations can be found in the [Spire server.conf](https://github.com/DecipherNow/helm-charts/blob/release-2.1/spire/templates/server-configmap.yaml), and [Spire agent.conf](https://github.com/DecipherNow/helm-charts/blob/release-2.1/spire/templates/agent-configmap.yaml).

The Spire Agent is run in a Daemonset, so a new agent is spun up for each kubernetes node.

## Grey Matter API Objects

Our helm charts are configured to set up the below configurations in `greymatter-spire.yaml` automatically.  When `.Values.global.spire.enabled` is set to true, the Grey Matter core services are configured as follows.

The mesh is configured to use spire through the `secrets` set on the Grey Matter cluster object and listener object.  The cluster object secret sets the spiffe certificate for the sidecar egress, and the listener secret sets the same for the ingress.  The secrets are configured for certificates to be fetched from the spire agent by Envoy's [Secret Discovery Service](https://www.envoyproxy.io/docs/envoy/v1.10.0/configuration/secret.html?highlight=sds).  See the [Cluster]() and [Listerner]() documentation for specific information on configuring the objects and secrets.

1. Every sidecar is configured with an environment variable, `SPIRE_PATH`, set to `/run/spire/sockets/agent.sock`. This is the path to the workload API socket (where the workloads connect to the workload API) as set in the Spire Agent configuration.  Passing this variable to the sidecar will configure Envoy SDS to be served over the same domain socket as the Spire Agent.

2. On startup, every `edge-to-servicex-cluster` will be configured with a secret.  The secret set on these clusters configures edge egress to `servicex` to use a SPIFFE certificate with ID `spiffe://greymatter.io/servicex/mTLS`, the secret looks like:

    ```json
    "secret": {
        "secret_key": "secret-{{.service.serviceName}}-secret",
        "secret_name": "spiffe://{{ .Values.global.spire.trustDomain }}/{{.service.serviceName}}/mTLS",
        "secret_validation_name": "spiffe://{{ .Values.global.spire.trustDomain }}",
        "ecdh_curves": [
            "X25519:P-256:P-521:P-384"
        ]
    }
    ```

3. Every `listener-servicex` listener will be configured with a corresponding secret. This configures `servicex` ingress to look for a SPIFFE certificate with SPIFFE ID `spiffe://greymatter.io/servicex/mTLS`.  Thus allowing edge to sidecar communication for all of the core services in the mesh.

4. When `.Values.global.edge.enableTLS`, the `domain-edge` will be configured with an [`ssl_config`](https://github.com/DecipherNow/gm-control-api/blob/release-1.2/docs/mesh/objects/domain.md#tls-configuration).  This sets a browser cert on edge ingress, allowing the user to access the edge node from the browser. This is the only certificate necessary to mount.

    **NOTE** The above 4 configurations have configured the mesh to accept a non-SPIFFE certificate to access edge from the browser, and to use SPIFFE certificates for all edge-to-sidecar communication.  Each sidecar is configured to speak plaintext to their service, so at this point all services are accessible from edge.  Now, there are some specific configurations necessary to allow a non-edge service to access another service in the mesh, as is necessary for GM Data to speak with the GM JWT Security service, as well as GM Catalog to use GM Data as its config source.  

5. A second domain/listener pair is created for each service in the mesh other than edge.  Since at this point each sidecar is looking for a SPIFFE certificate as its ingress, we need to open another ingress listener to allow only the microservice itself to speak plaintext back to the sidecar.  For each service, `domain-servicex-local` and `listener-servicex-local` are created and configured to open another sidecar listener at `127.0.0.1:8180` that allows the service to access the sidecar with plaintext at that address.  Then, internal routes are created for the above examples, using the local domain key.

### Adding a new Service

Follow the steps below to add a new service to the mesh and configure it to use SPIFFE/SPIRE.  This example is for the fibonacci service without internal routes. To adapt this for your service, replace `fibonacci` with your service name.

1. You will need to add three things to the deployment for your service.  First, add the following volume:

   ```yaml
     - name: spire-agent-socket
     hostPath:
       path: /run/spire/sockets
       type: Directory
   ```

    Then, add the following volume mount to your sidecar container:

    ```yaml
      - name: spire-agent-socket
        mountPath: /run/spire/sockets
        readOnly: true
    ```

    Lastly, add an environment variable to the sidecar container with name `SPIRE_PATH` and value `/run/spire/sockets/agent.sock`.

2. Exec into the spire server pod, `kubectl exec -it spire-server-0 /bin/sh`, and run the following to create SPIFFE certificate entries for your new service:

    ```bash
    /opt/spire/bin/spire-server \
        entry create \
        -parentID spiffe://greymatter.io/nodes \
        -spiffeID spiffe://greymatter.io/fibonacci \
        -selector k8s:pod-label:app:fibonacci \
        -selector k8s:ns:default \
        -dns fibonacci.greymatter.io \
        -registrationUDSPath /tmp/spire/registration/registration.sock
    ```

    ```bash
    /opt/spire/bin/spire-server \
        entry create \
        -parentID spiffe://greymatter.io/fibonacci \
        -spiffeID spiffe://greymatter.io/fibonacci/mTLS \
        -selector k8s:ns:default \
        -dns fibonacci.greymatter.io \
        -registrationUDSPath /tmp/spire/registration/registration.sock
    ```

3. Create your deployment, `kubectl apply fib.yaml`. Now, configure the mesh as usual, (follow the [training material](https://github.com/DecipherNow/workshops/blob/master/training/3.%20Grey%20Matter%20Service%20Deployment/Grey%20Matter%20Service%20Deployment%20Training.md#grey-matter-sidecar-configuration) for a guide on mesh objects), and add the following.

   - In your `edge-fibonacci-cluster`, add a secret configuration, and set `require_tls` to true::
  
    ```json
    "require_tls": true,
    "secret": {
      "secret_key": "secret-fibonacci-secret",
      "secret_name": "spiffe://greymatter.io/fibonacci/mTLS",
      "secret_validation_name": "spiffe://greymatter.io",
      "ecdh_curves": [
        "X25519:P-256:P-521:P-384"
      ]
    }
    ```

    - In your services' listener, in this example `fibonacci-listener`, add:

    ```json
        "secret": {
        "secret_key": "secret-fibonacci-secret",
        "secret_name": "spiffe://greymatter.io/fibonacci/mTLS",
        "secret_validation_name": "spiffe://greymatter.io",
        "ecdh_curves": [
            "X25519:P-256:P-521:P-384"
        ],
        "forward_client_cert_details": "SANITIZE_SET",
        "set_current_client_cert_details": {
            "uri": true
        }
      }
    ```

    After the mesh is configured, you should be able to access your service at `/services/fibonacci/1.0/` (or whatever path specified in the `edge-service-route` path).

4. Register the service with catalog, in this case, you will need to curl with the browser certificate originally configured on the edge node.  The call should look something like: `curl -XPOST https://host:port/services/catalog/latest/clusters --cert /etc/ssl/quickstart/certs/quickstart.crt --key /etc/ssl/quickstart/certs/quickstart.key -k -d "@entry.json"` where `entry.json` is your [catalog entry](https://github.com/DecipherNow/workshops/blob/master/training/3.%20Grey%20Matter%20Service%20Deployment/Grey%20Matter%20Service%20Deployment%20Training.md#catalog-service-configuration).

Now, you should see fibonacci in the dashboard and be able to access its endpoints!
