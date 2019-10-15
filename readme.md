# USCIS Deployment

## Updating placeholder values

The `template.yaml` file contains Kubernetes configurations necessary to deploy Grey Matter. Before applying the file, replace the following placeholder values:

| Placeholder Values         | Description                                                                                                                 | Sample Value                                                     |
| -------------------------- | --------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------- |
| `__NAMESPACE__`              | Namespace of the Openshift cluster where services will be deployed                                                          | "fabric"                                                         |
| `__DOCKER_IMAGE_REPO__`      | Full endpoint of repo where docker images are hosted. See [Docker Images](#docker-images) for a list of required images.                                                                        | https://nexus.production.deciphernow.com/repository/helm-hosted/ |
| `__DOCKER_IMAGE_REPO_AUTH__` | A base64 encoded string of the dockercreds.json file. See [Configuring Docker Credentials](#configuring-docker-credentials) |                                                                  |
| `__AWS_ACCESS_KEY_ID__`      | AWS access key ID                                                                                                           | AKIAIOSFODNN7EXAMPLE                                             |
| `__AWS_SECRET_ACCESS_KEY__`  | AWS secret access key                                                                                                       | wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY                         |
| `__AWS_REGION__`             | AWS region                                                                                                                  | "us-east-1"                                                      |
| `__AWS_S3_BUCKET__`          | Name of the bucket where Grey Matter Data will write config                                                                 | "greymatter"                                                     |
| `__AWS_MASTER_KEY__`         | AWS master key                                                                                                              |                                                                  |
| `__REDIS_PASSWORD__`         | Redis password                                                                                                              | "password"                                                       |
| `__REDIS_PORT__`             | Redis port                                                                                                                  | 6379                                                             |
| `__REDIS_DATABASE__`         | Redis database                                                                                                              | "0"                                                              |
| `__MONGO_ROOT_USERNAME__`    | Mongo root username                                                                                                         | "username"                                                       |
| `__MONGO_ROOT_PASSWORD__`    | Mongo root password                                                                                                         | "password"                                                       |
| `__MONGO_ADMIN_PASSWORD__`   | Mongo admin password                                                                                                        | "password"                                                       |
| `__POSTGRES_USERNAME__`      | Postgres username                                                                                                           | "username"                                                       |
| `__POSTGRES_PASSWORD__`      | Postgres password                                                                                                           | "password"                                                       |
| `__POSTGRES_DATABASE__`      | Postgres database                                                                                                           | "greymatter"                                                     |
| `__INTAKE_PORT__`            | Port for Intake Service                                                                                                     | 1337                                                             |
| `__INTAKE_VERSION__`         | Version of Intake Service                                                                                                   | "1.0.0"                                                          |
| `__PAYMENT_PORT__`           | Port for Payment Service                                                                                                    | 1337                                                             |
| `__PAYMENT_SERVICE__`        | Version of Payment Service                                                                                                  | "1.0.0"                                                          |  |

### Configuring Docker Credentials

To configure the docker secret necessary to pull images, open `dockercreds.json` and replace `DOCKER_IMAGE_REPO` with the url of your image repository. The `auth` field should contain the authorization token needed to pull from the repository. For more information, refer to the [Kubernetes documentation.](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/#log-in-to-docker).

Once this file has been templated correctly, encode the file for use in `template.yaml`:

```sh
$ base64 -i dockercreds.json
ewogICJhdXRocyI6IHsKICAgICJfX0RPQ0tFUl9JTUFHRV9SRVBPX18iOiB7CiAgICAgICJhdXRoIjogImMzUi4uLnpFMiIKICAgIH0KICB9Cn0K
```

The resulting base64 encoded string should replace the `__DOCKER_IMAGE_REPO_AUTH__` placeholder variable in `template.yaml`.

### Docker Images

The following images are expected to be available in the configured docker repository:

- `gm-catalog:1.0.1`
- `gm-proxy:0.9.1`
- `gm-control:0.5.1`
- `gm-dashboard:3.1.0`
- `gm-data:0.2.7`
- `gm-control-api:0.8.1`
- `gm-jwt-security:0.2.0`
- `gm-slo:0.5.0`
- `greymatter:0.5.1`
- `k8s-waiter:latest`
- `mongo:4.0.3`
- `postgresql-10-centos7`
- `prometheus:v2.7.1`
- `redis-32-centos7`

## Deploying

To validate `template.yaml` and confirm that placeholders were templated correctly, run the following:

```sh
kubectl apply -f template.yaml --dry-run=true --validate=true
```

If this was successful, apply the file:

```sh
kubectl apply -f template.yaml
```
