# Control API

The Grey Matter control plane is configured using `gm-control-api`, a service which serves as the source of truth and the persistence layer for mesh configuration. 

You define all of your service mesh objects + configuration by interacting with `gm-control-api`, either directly through the REST API, or by using the `greymatter` CLI.

## Routing

All routing configuration is defined by the `helm-charts/gm-control-api/json` folder, which specifies all of the mesh objects to create for each service both for its own proxy (service) and for routing from the edge node to its proxy (edge), along with any special mesh objects needed (aka the domain, edge cluster, etc).

Currently, each service is served at `/services/dashboard/latest/`. Previously, we had served each route at a URL containing the version of the service (e.g. `/services/dashboard/3.0.0/`) However, in order to provide better flexibility, the GM 2.0 deployment will only provide the first one for now.

## Details

All gm-control-api configuration is configured in YAML and then templated to JSON.

The current gm-control-api configuration bootstrapping is just to show an example service mesh, but the true power of Grey Matter is the advanced configuration of each sidecar using the Grey Matter Control API + CLI, so be sure to think about customizing routes, etc between services which talk to each other often. 

This deployment includes SPIRE deployed as a statefulset and a daemonset, and interacting with envoy over SDS.

## Overview

The overall structure of the mesh is as follows:

Each service has a 
- domain
- cluster
- listener
- proxy
- shared_rules
- and route

Which link a sidecar proxy to its service

Then, the edge node has the following

- all of the above, PLUS
- A domain (with TLS configured using your static client-facing certs)
- a route for each service (e.g. /services/dashboard/latest/)
- a shared rules, which links to 
- a cluster, which has its instances automatically populated using the GM Control service discovery mechanisms described below

## Service discovery

GM Control periodically queries the Kubernetes API to look for pods with the following two characteristics:

1. The pod's has a label (by default `app`) has a value corresponding to the `name` key of the GM Control API `cluster` object which it should be associated with
2. The pod has a named port (by default `proxy`) which corresponds to the port value which GM Control will add to the `Instance` which it adds to the `cluster` mentioned above.

These two things: both the pod's label and the port name can be configured using two environment variables on GM Control: `GM_CONTROL_KUBERNETES_CLUSTER_LABEL` and `GM_CONTROL_KUBERNETES_PORT_NAME`

In our deployment, we have an architecture which only discovers services with a sidecar proxy (e.g. the `proxy` port). This makes sense for us so that we ensure that the edge and every proxy can talk to every other proxy using the configured TLS and authentication options (static mTLS, SPIFFE/SPIRE certs, etc) which have been set in GM Control API.

Make sure that every service which you want to deploy and to be discovered has these two things.

## YAML structure

All structure for bootstrapping the mesh is defined in `.Values.global.services` (this is the service list for which the services + edge service template is used, along with the list which automatically generates SPIRE registration entries and catalog API configuration calls)

The only requirement for `.Values.global.services` is that it is a list of service objects. A service object is set as the scope for the services template/mesh configuration init objects.

We add a few items to each `$service` object:
- `$top` - represents the top-level Helm values scope, and allows access to global values
- `$svids` - a list of spiffe IDs generated from the `$service.serviceName` field on `.Values.global.services`

