# Anchore Engine Helm Operator

The Anchore Engine Operator provides an easy way to deploy the Anchore Engine Helm chart to kubernetes clusters.

This operator is based on the official [Helm Chart](https://github.com/anchore/anchore-charts/tree/master/stable/anchore-engine).

## Quickstart

To stand up an Anchore Engine deployment on your cluster, issue the follow commands.

```bash
make deploy
```

## Testing the Operator for installation with OLM

Install the following:

* [crc](https://code-ready.github.io/crc/)
* [oc](https://docs.openshift.com/container-platform/4.6/cli_reference/openshift_cli/getting-started-cli.html#installing-openshift-cli)
* [operator-sdk](https://sdk.operatorframework.io/docs/installation/)

```bash
export IMG="quay.io/btodhunter/engine-operator:v0.2.0"
export BUNDLE_IMG="quay.io/btodhunter/engine-operator-bundle:v0.2.0"
make docker-build IMG="$IMG"
make bundle IMG="$IMG"
make bundle-build BUNDLE_IMG="$BUNDLE_IMG"
docker push "$IMG"
docker push "$BUNDLE_IMG"
crc setup
crc config set memory 16000
crc start
crc oc-env
operator-sdk run bundle "$BUNDLE_IMG"
```

### Clean up OLM install

```bash
operator-sdk cleanup engine-operator
crc stop
crc delete
```