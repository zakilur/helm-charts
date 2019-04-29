# Helm Charts for Grey Matter

## Prerequisites:

### OpenShift:

- Be able to loginto development environment.
- Run `oc login` this will respnd with something along the lines of

```Login failed (401 Unauthorized)
Verify you have provided correct credentials.
You must obtain an API token by visiting https://development.deciphernow.com:8443/oauth/token/request
```

- Follow the link provided and use the provided comand to login. The command will look something like:
  `oc login --token=<some_crazy_long_and_random_string> --server=https://development.deciphernow.com:8443`

### AWS:

Have an:

- Account access key
- Secret key
- Ability to create a s3 bucket.

### Docker Credentials:

Have:

- Registry OpenShift is configured to pull from
- Account Email
- Account Username/pass

## Deploying charts:

### Install Chart:

To deploy a chart use the helm install command:
`helm install --name <project_name> --namespace <my_namespace> --debug -f custom.yaml <chart_to_deploy>`

- `--debug` prints out the deployment YAML to the terminal
- `--dry-run` w/ debug will print out the deployment YAML without actually deploying to OS/kubernetes env
- `--replace` will create new deployments if they are undefined or replace old ones if they exist
- `-f` allow you to pass in a file with values that can override the chart's defaults. (relative path)

### Dependencies:

If you are deploying a chart like `greymatter` with dependendencies defined in `requirements.yaml` you will have an additional step before you can install. You will have to first run `helm dep up greymatter`. This command will create a `charts/` directory with tarballs of the child charts that the parrent chart will use. This is statically generated so if you make updates to the child charts the command will need to be re-run.

### Deleting install:

To delete a deployment run `helm del --purge <namespace>`. This will delete everything in the deployment. You can use `oc get pods` and `oc get pvc` to check that the rescources in the deployment have been removed (persistent volumes seem to take longer than pods).

### Custom file:

You can override configurations in the `values.yaml` file by including them in the `custom.yaml` file:

```
# What type of enviornment are you deploying Grey Matter into?
#  Valid answers are openshift or kubernetes (all lowercase)
#  Defaults to kubernetes
environment: openshift
domain: development.deciphernow.com
route_url_name: fabric

data:
  data:
    access_key:
    secret_key:
    bucket:
    region:
exhibitor:
  exhibitor:
    access_key:
    secret_key:
    bucket:
    region:

dockerCredentials:
  registry:
  email:
  username:
  password:

jwt:
  jwt:
    secrets:
      - name: jwt-certs
        jwt.cert.pem: |-
        -----BEGIN CERTIFICATE-----
        ...
        -----END CERTIFICATE-----

```

To override values in a particular chart's values.yaml file you will need to include a line in the custom.yaml file similar to the following:

```
<chart_directory>
  <chart name>
      <key_to_override>: <value>
```

## Troubleshooting:

- Keep in mind that helm will not teardown any rescources that it did not create in the firstplace. Therefore bestpractice is to manage everything inside a project/namespace with helm or nothing at all.
