# Anchore Engine Helm Operator

The Anchore Engine Operator provides an easy way to deploy the Anchore Engine Helm chart to kubernetes clusters.

This operator is based on the official [Helm Chart](https://github.com/helm/charts/tree/master/stable/anchore-engine). It only includes the Open Source components of the chart, all enterprise services have been removed. 

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

Occasionally custom resources will fail to delete due to a reported bug in the helm operator spec. To force the deletion of a Custom Resource and it's associated resources run the following commands.

```
kubectl patch anchoreengines.anchore.com example-anchoreengine -p '{"metadata":{"finalizers":[]}}' --type=merge
kubectl delete anchoreengines.anchore.com example-anchoreengine
```

# RedHat Operator Hub Preperation
To make this operator available on the RedHat Operator Hub, an OLM bundle must be created and zipped up with the crd & package.yaml files. The zip file can then be uploaded to the Operator Hub from the connect.redhat.com console.

OLM bundle versions can be found in `deploy/olm-catalog/`.

## Create a new bundle

See [OLM - building your csv](https://github.com/operator-framework/operator-lifecycle-manager/blob/master/Documentation/design/building-your-csv.md)

* Create a new OLM bundle version - run the following command from the anchore-engine-operator project root.
  * This will create the `deploy/olm-catalog/<version>` directory and a csv resource spec file. 

```
operator-sdk olm-catalog gen-csv --csv-version <version>
```
* Copy `deploy/crds/anchore_v1alpha1_anchoreengine_crd.yaml` to the `deploy/olm-catalog/<version>/` directory.
* Create `deploy/olm-catalog/<version>/anchore-engine.package.yaml` with the updated version.
* Verify that the bundle is valid for uploading to connect.redhat.com - run the following command from the anchore-engine-operator project root.
```
operator-courier --verbose verify --ui_validate_io deploy/olm-catalog/<version>
```
* Finally zip up the `deploy/olm-catalog/<version>` directory and upload the zip file to connect.redhat.com in the anchore-engine operator project.
