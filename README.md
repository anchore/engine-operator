# Anchore Engine Helm Operator

The Anchore Engine Operator provides an easy way to deploy the Anchore Engine Helm chart to kubernetes clusters.

This operator is based on the official [Helm Chart](https://github.com/helm/charts/tree/master/stable/anchore-engine). It only includes the open source components of the chart, all enterprise services have been removed. 

All customizable values are specified in `deploy/crds/anchore_v1alpha1_anchoreengine_cr.yaml` before creation.

## Quickstart

To stand up an Anchore Engine deployment on your cluster, issue the follow commands.

```
kubectl create -f deploy/crds/anchore_v1alpha1_anchoreengine_crd.yaml
kubectl create -f deploy
kubectl create -f deploy/crds/anchore_v1alpha1_anchoreengine_cr.yaml
```

To delete the operator deployment, use the following command:
```
kubectl delete -f deploy/crds
kubectl delete -f deploy
```

## Troubleshooting

Occasionally custom resources will fail to delete due to a reported bug in the helm operator. To force the deletion of a Custom Resource and it's associated resources run the following commands.

```
kubectl patch anchoreengines.anchore.com example-anchoreengine -p '{"metadata":{"finalizers":[]}}' --type=merge
kubectl delete anchoreengines.anchore.com example-anchoreengine
```

## Updating the operator to latest anchore-engine chart

* Copy the stable/anchore-engine chart contents to the `helm-charts/` directory
* From the `helm-charts/anchore-engine` directory, move the `deps/postgresql` directory to `charts/postgresql`
* Update the deps in Chart.yaml and remove the `repository` section from both postgresql deps definitions
* Run `helm deps up` to create a new Chart.lock file and pull the redis chart tarball into the `charts/` directory
* Copy the contents of the new values file from `helm-charts/anchore-engine/values.yaml` to `deploy/crds/anchore_v1alpha1_anchoreengine_cr.yaml`
  * Remove ALL enterprise related values from the `deploy/crds/anchore_v1alpha1_anchoreengine_cr.yaml` file contents
* Update `build/Dockerfile` to use the latest helm-operator image & update the engine-operator version
* Update `deploy/operator.yaml` to the latest helm-operator image tag
* Create new operator image and push it to Dockerhub
    ```
    operator-sdk build anchore/engine-operator:<version>
    docker push anchore/engine-operator:<version>
    ```
* Create olm-deployment csv file & upload to the Red Hat Marketplace - see `olm-catalog/README.md`