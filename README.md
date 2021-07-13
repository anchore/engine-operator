# Anchore Engine Helm Operator

The Anchore Engine Operator provides an easy way to deploy the Anchore Engine Helm chart to kubernetes clusters.

This operator is based on the official [Helm Chart](https://github.com/anchore/anchore-charts/tree/master/stable/anchore-engine).

## Quickstart

To stand up an Anchore Engine deployment on your cluster using the engine-operator, issue the follow command

```bash
make deploy
```

To delete the Anchore Engine deployment and the engine-operator from your cluster, issue the follow command

```bash
make undeploy
```

## Updating Operator with newest chart version

* Install/Update operator-sdk cli tool - [operator-sdk](https://sdk.operatorframework.io/docs/installation/)
* Copy latest anchore-engine helm chart to `helm-charts/anchore-engine`
* Update `Dockerfile` with latest helm-operator image (matching the version of the operator-sdk used to update the operator)
* Check what changes are needed for the sdk version upgrade (and previous versions) - [Upgrade SDK Version](https://sdk.operatorframework.io/docs/upgrading-sdk-version/)
* Run `make bundle` to create a new operator bundle
* Run `make docker-build` to create docker image
* Run `make docker-push` to push `anchore/engine-operator` image
* Run `make docker-push-redhat` to push the operator image to the RedHat Marketplace
* Run `make bundle-build` to create the bundle image
* Run `make docker-push-bundle` to push the bundle image to the RedHat Marketplace

## Testing the Operator for installation with OLM

Install the following:

* [crc](https://code-ready.github.io/crc/)
* [oc](https://docs.openshift.com/container-platform/4.6/cli_reference/openshift_cli/getting-started-cli.html#installing-openshift-cli)
* [operator-sdk](https://sdk.operatorframework.io/docs/installation/)

```bash
export IMG="docker.io/anchore/engine-operator-dev:latest"
export BUNDLE_IMG="docker.io/anchore/engine-operator-dev:bundle-latest"
make docker-build
make bundle REDHAT_IMG="$IMG"
make bundle-build
docker push "$IMG"
docker push "$BUNDLE_IMG"
crc setup
crc config set memory 16000
crc start
eval $(crc oc-env)
operator-sdk run bundle "$BUNDLE_IMG"
```

### Clean up OLM install

```bash
operator-sdk cleanup anchore-engine
crc stop
crc delete
```
