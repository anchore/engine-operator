# RedHat Operator Hub Preperation
To make this operator available on the RedHat Operator Hub, an OLM bundle must be created and zipped up with the crd & package.yaml files. The zip file can then be uploaded to the Operator Hub from the connect.redhat.com console.

OLM bundle versions can be found in `deploy/olm-catalog/`.

## Create a new bundle

See [OLM - building your csv](https://github.com/operator-framework/operator-lifecycle-manager/blob/master/Documentation/design/building-your-csv.md)

* Create a new OLM bundle version - run the following command from the anchore-engine-operator project root.
  * This will create the `deploy/olm-catalog/<version>` directory and a csv resource spec file. 

```
operator-sdk generate csv --csv-version <new_version> --from-version <previous_version>
```
* Copy `deploy/crds/anchore_v1alpha1_anchoreengine_crd.yaml` to the `deploy/olm-catalog/<version>/` directory.
* Create `deploy/olm-catalog/<version>/anchore-engine.package.yaml` with the updated version.
* Verify that the bundle is valid for uploading to connect.redhat.com - run the following command from the anchore-engine-operator project root.
```
operator-courier --verbose verify --ui_validate_io deploy/olm-catalog/<version>
```
* Finally zip up the `deploy/olm-catalog/<version>` directory and upload the zip file to connect.redhat.com in the anchore-engine operator project.
