# Anchore Engine Helm Operator

The Anchore Engine Operator provides an easy way to deploy the Anchore Engine Helm chart to kubernetes clusters.

This operator is based on the official [Helm Chart](https://github.com/anchore/anchore-charts/tree/master/stable/anchore-engine).

## Quickstart

To stand up an Anchore Engine deployment on your cluster using the engine-operator, issue the follow command:

```bash
make deploy
```

To delete the Anchore Engine deployment and the engine-operator from your cluster, issue the follow command:

```bash
make undeploy
```

## Updating Operator with newest chart version

* Install/Update operator-sdk cli tool - [operator-sdk](https://sdk.operatorframework.io/docs/installation/)
* Copy latest anchore-engine helm chart to `helm-charts/anchore-engine`
* Update all resource with latest operator-sdk version
  * Update `Dockerfile` with latest helm-operator image (matching the version of the operator-sdk used to update the operator)

    ```bash
    FROM quay.io/operator-framework/helm-operator:v1.9.0
    ```

  * Update `scorecard/patches/[basic.config.yaml][olm.config.yaml]` with latest scorecard-test image (matching the version of the operator-sdk used to update the operator)

    ```bash
    image: quay.io/operator-framework/scorecard-test:v1.9.0
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
* Reset $IMG & BUNDLE_IMAGE environment variables `unset IMG BUNDLE_IMG REDHAT_IMG`
* Run `make bundle` to create a new operator bundle
* Run `make docker-build` to create docker image
* Run `make docker-push` to push `anchore/engine-operator` image
* Run `make docker-push-redhat` to push the operator image to the RedHat Marketplace
* Run `make docker-bundle-build` to create the bundle image
* Run `make docker-push-bundle` to push the bundle image to the RedHat Marketplace

## Testing the Operator for installation with OLM

Install the following:

* [crc](https://code-ready.github.io/crc/)
* [oc](https://docs.openshift.com/container-platform/4.6/cli_reference/openshift_cli/getting-started-cli.html#installing-openshift-cli)
* [operator-sdk](https://sdk.operatorframework.io/docs/installation/)

### Setup local OpenShift cluster & install operator

```bash
export IMG="docker.io/anchore/engine-operator-dev:latest"
export BUNDLE_IMG="docker.io/anchore/engine-operator-dev:bundle-latest"
export REDHAT_IMG="$IMG"
make docker-build
make docker-push
make docker-bundle-build
make docker-bundle-push
crc setup
crc start
crc config set memory 16000
eval $(crc oc-env)
oc login -u kubeadmin -p <PASSWORD_FROM_STDOUT> https://api.crc.testing:6443
operator-sdk run bundle "$BUNDLE_IMG"
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

### Clean up OLM install

```bash
operator-sdk cleanup anchore-engine
crc stop
crc delete
```
