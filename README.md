# Anchore Engine Helm Operator

The Anchore Engine Operator provides an easy way to deploy the Anchore Engine Helm chart to kubernetes clusters.

This operator is based on the official [Helm Chart](https://github.com/anchore/anchore-charts/tree/master/stable/anchore-engine).

## Quickstart

To stand up an Anchore Engine deployment on your cluster using the engine-operator, issue the follow command:

```bash
make install
make deploy
```

To delete the Anchore Engine deployment and the engine-operator from your cluster, issue the follow command:

```bash
make uninstall
make undeploy
```

## Updating Operator with newest chart version

* Install/Update operator-sdk cli tool - [operator-sdk](https://sdk.operatorframework.io/docs/installation/)
* Copy latest anchore-engine helm chart to `helm-charts/anchore-engine`
* Update `config/manager/manager.yaml` ENV vars with images used by the current anchore-engine helm chart.

    ```yaml
    ...

    env:
    - name: RELATED_IMAGE_ANCHORE_ENGINE
      value: docker.io/anchore/anchore-engine:v0.10.0
    - name: RELATED_IMAGE_ANCHORE_POSTGRESQL
      value: docker.io/postgres:9.6.18
    ```

* Update `config/manager/manager_redhat_patch.yaml` ENV vars with the current images pushed up to the RedHat image repository.

    ```yaml
    ...

    env:
    - name: RELATED_IMAGE_ANCHORE_ENGINE
      value: registry.connect.redhat.com/anchore/engine0:v0.10.0-r0
    - name: RELATED_IMAGE_ANCHORE_POSTGRESQL
      value: registry.redhat.io/rhel8/postgresql-96:latest
    ```

* Update all resource with latest operator-sdk version
  * Update `Dockerfile` with latest helm-operator image (matching the version of the operator-sdk used to update the operator)

    ```bash
    FROM quay.io/operator-framework/helm-operator:<LATEST_VERSION>
    ```

  * Update `scorecard/patches/[basic.config.yaml][olm.config.yaml]` with latest scorecard-test image (matching the version of the operator-sdk used to update the operator)

    ```bash
    image: quay.io/operator-framework/scorecard-test:<LATEST_VERSION>
    ```

  * Implement all required changes for the sdk version upgrade (as well as previous versions if upgrading multiple versions) - [Upgrade SDK Version](https://sdk.operatorframework.io/docs/upgrading-sdk-version/)
* Update `Makefile` with current operator version

  ```make
  VERSION ?= 1.0.0
  ```

* Update `Dockerfile` with the current operator version

  ```bash
  LABEL name="Anchore Engine Operator" \
    vendor="Anchore Inc." \
    maintainer="dev@anchore.com" \
    version="v1.0.0" \
  ```

* [Test the operator](#testing-the-operator-for-installation-with-olm)
* [Clean up testing artifacts](#clean-up-olm-install)
* Create a new operator bundle and image, then push them to DockerHub & RedHat OperatorHub

  ```bash
  make docker-build
  make docker-push
  make docker-push-redhat
  make docker-bundle-build
  make docker-bundle-push
  ```

* Commit all changes & push to remote branch for PR

## Testing the Operator for installation with OLM

Install the following:

* [crc](https://code-ready.github.io/crc/)
* [oc](https://docs.openshift.com/container-platform/4.6/cli_reference/openshift_cli/getting-started-cli.html#installing-openshift-cli)
* [operator-sdk](https://sdk.operatorframework.io/docs/installation/)

### Setup local OpenShift cluster & install operator

```bash
export OPERATOR_TEST_MODE=true
make docker-build
make docker-push
make docker-bundle-build
make docker-bundle-push
crc setup
crc start
crc config set memory 16000
eval $(crc oc-env)
eval $(crc console --credentials | grep admin | cut -d"'" -f2)
make deploy-olm
crc console
```

### From the crc console, install an instance of anchore-engine using the operator

* Login using `kubeadmin` and the password from `crc start` stdout
* Navigate to Operators -> Install Operators -> Anchore Engine Operator
* Deploy an instance of anchore-engine from the Anchore Engine Operator
  * Under `Provided APIs` click the `Create Instance` button
  * Add labels or update the name as needed
  * If you want to customize the anchore-engine deployment, use a YAML spec and add custom values
  * click the `Create` button
* Ensure that anchore-engine deployed correctly by checking the status of all pods under the `Resources` tab
* Port forward anchore-engine API pod & check anchore-engine status

  ```bash
  kubectl port-forward svc/anchoreengine-sample-anchore-engine-api 8228:8228
  ANCHORE_CLI_PASS=$(kubectl get secret anchoreengine-sample-anchore-engine-admin-pass -o 'go-template={{index .data "ANCHORE_ADMIN_PASSWORD"}}' | base64 -D -)
  anchore-cli system status
  ```

### Clean up OLM install

```bash
unset OPERATOR_TEST_MODE
make clean
crc stop
crc delete
```

# Troubleshooting

* Sometimes the helm deployment can fail, this creates a situation where the anchoreengine.charts.anchore.io CR is stuck and cannot be deleted. To delete a stuck `anchoreengine-sample` CR run the following command:

```bash
kubectl patch anchoreengines.charts.anchore.io anchoreengine-sample -p '{"metadata":{"finalizers":[]}}' --type=merge
```