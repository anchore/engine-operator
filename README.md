# Anchore Engine Helm Operator

The Anchore Engine Operator provides an easy way to deploy the Anchore Engine Helm chart to kubernetes clusters.

This operator is based on the official [Helm Chart](https://github.com/helm/charts/tree/master/stable/anchore-engine). It only includes the Open Source components of the chart, all enterprise services have been removed. 

All customizable values can be specified in `deploy/crds/anchore_v1alpha1_anchoreengine_cr.yaml` before creation.

## Quickstart

To stand up an Anchore Engine deployment on your cluster, issue the follow commands.

```yaml
kubectl create -f deploy/crds/anchore_v1alpha1_anchoreengine_crd.yaml
kubectl create -f deploy
kubectl create -f deploy/crds/anchore_v1alpha1_anchoreengine_cr.yaml
```

To delete the operator deployment, use the following command:
```
kubectl delete -f deploy/crds
kubectl delete -f deploy
```