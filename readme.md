# USCIS Deployment

From the generated helm charts, replace the following:



- `__DOCKER_IMAGE_REPO__` -> full endpoint of repo to pull images from
- update `dockerCredentials` secret with email, username, and password
- replace `__NAMESPACE__` with desired openshift namespace
- replace `__AWS__...` in `name: data-secrets` and `data-internal-secrets`
- update user:password resources, if needed
  - `__REDIS_PASSWORD__` in `internal-redis-password`
  - `__MONGO_...` in `internal-mongo-credentials` ,`external-mongo-credentials`, `data-internal`, and`data`
  - `__MYSQL__` in `postgres-credentials`
- Replace service ports and versions
  - replace `__INSTAKE_PORT__` and `__INTAKE_VERSION__` with required values
  - replace `__PAYMENT_PORT__` and `PAYMENT_VERSION__` with required values





TODO

- find straggler images docker.io/XXXX and replace with `__DOCKER_IMAGE_REPO__`
- replace `users : ` with empty array in external-jwt-users
- replace `myproject` namespace with `__NAMESPACE__`
- replace `aws_s3_bucket` and `master_key_` with `__AWS_BUCKET__`, `__AWS__...`

- replace `mongo` password and username with `__MONGO_...`
- replace `sql` passwords with `__MYSQL_...`