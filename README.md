#

## Limitations

* Only GitHub repository could be integrated. (This is limitation of the TF Engine)
* Project names are not being randomly named. (You have to remember to create name which doesn't exist)

## Requirements

* Fulfill all requirements and prerequisites from the [init/README.md](init/README.md) instruction
* Apply all changes from the `init` directory

## Prepare Terraform code

* Whole project based on the [folder.hcl](https://github.com/GoogleCloudPlatform/healthcare-data-protection-suite/blob/master/examples/tfengine/org_foundation.hcl) file. ([details](https://github.com/GoogleCloudPlatform/healthcare-data-protection-suite/tree/master/examples/tfengine))
* Customized `folder.hcl` file is attached to the repository. Please check/modify necessary variables like `parent_id`, `billing_account`, etc.

* Integration with Forseti.
  * For enabling integration with Forseti you have to install it in your organization by steps from the [instruction](https://forsetisecurity.org/docs/v2.23/configure/notifier/#cloud-scc-notification).
  * After this you'll have `security_command_center_source_id` which has to be set in the `folder.hcl`.

* Run `tfengine` for the terraform generation:

      MAIN=$(pwd)
      tfengine --config_path=${MAIN}/folder.hcl --output_path=${MAIN}/terraform

* Generated terraform code is ready, but some fixes and changes has to be done manually. Detailed information about the process is [here](https://github.com/GoogleCloudPlatform/healthcare-data-protection-suite/tree/master/docs/tfengine#usage).

* DevOps project has to be applied first:
  
      cd ${MAIN}/terraform/devops
      terraform init
      terraform apply

* Enable GCS backend in the `folder.hcl`.

      enable_gcs_backend = true

* Regenerate Terraform code and re-apply changes:

      cd ${MAIN}
      tfengine --config_path=${MAIN}/folder.hcl --output_path=${MAIN}/terraform
      cd ${MAIN}/terraform/devops
      terraform init

  answer `yes` for moving TF state to the bucket in GCS.

* Next step is applying `terraform/groups` (optional) - if you don't have permission to create groups just make sure the group exists.

      cd ${MAIN}/groups
      terraform init
      terraform apply


* Apply network project manually

      cd ${MAIN}/prod-networks
      terraform init
      terraform apply
  
* Apply changes from cicd

  * Firstly you have to install the Cloud Build app and
  [connect your GitHub repository](https://console.cloud.google.com/cloud-build/triggers/connect)
  to your Cloud project by following the steps in
  [Installing the Cloud Build app](https://cloud.google.com/cloud-build/docs/automating-builds/create-github-app-triggers#installing_the_cloud_build_app).
  To perform this operation, you need Admin permission in that GitHub repository. This can't be done through automation.

  * Modify and fix Forseti component:
    * remove `google-cloud-sdk` from the metadata startup script from file `${MAIN}/terraform/monitor/.terraform/modules/forseti/modules/server/templates/scripts/forseti_server_startup_script.sh.tpl` (line 23)
    * add to the `terraform/monitor/main.tf` in the `forseti` configuration section
      ```terraform
      enabled_apis_enabled = true
      ```

  * Because TF Engine is outdated and has some issues you have to extend Service Account role for cicd by adding `roles/serviceusage.serviceUsageAdmin`, `roles/compute.instanceAdmin.v1`,
    `roles/compute.securityAdmin` and `roles/compute.networkAdmin`
  to the `cloudbuild_sa_editor_roles` array in `local` variables in the `cicd/main.tf` file. After this we can apply changes by:
  
        cd ${MAIN}/cicd
        terraform init
        terraform apply

  * if you see

    ```bash
    Error: Error creating Trigger: googleapi: Error 400: Repository mapping does not exist. Please visit https://console.cloud.google.com/cloud-build/triggers/connect?project=... to connect a repository to your project
    ```
    please just click a link and integrate your repository with the Cloud Build. After integration run `terraform apply` again.

* From now Cloud Build is used as your infrastructure automation tool.
  * You can set which folder will be checking by Cloud Build
    by adding folder to the `managed_dir` array in the `folder.hcl` configuration. In our case it'll be `audit`, `prod-networks` and `monitor` folder.
  * After each commit you'll see the validation and plan job. When you'll merge or commit directly to the master the changes will be applied after running job in the Cloud Build.
  * Before pushing to master please change Forseti version and image in the `monitor/main.tf` file from `5.2.1` to `5.2.2` and from `gce-uefi-images/ubuntu-1804-lts` to `ubuntu-1804-bionic-v20210720`.
  * Now you can trigger the job `tf-apply-prod` by click `RUN` button.


Modifications necessary for making Forseti scanner works:
* modify `/home/ubuntu/forseti-security/install/gcp/scripts/run_forseti.sh` in line 65 (leave the line in the below form):
  ```bash
  GET_MODEL_STATUS="forseti model get ${MODEL_NAME} | python3 -c \"import sys, json; print(json.load(sys.stdin)['status'])\""
  ```
* copy `rules` and `policy-library` to the bucket
  * >Open the Forseti project in the Google Cloud Console and go to Storage in the menu. The Forseti Server bucket will be named forseti-server-{SUFFIX} where {SUFFIX} is a random 8 character suffix setup at the time Forseti is deployed. Create a folder with the name policy-library inside the Forseti Server bucket and make note of the suffix.
  * run
    ```bash
    cd ${MAIN}/terraform/monitor
    git clone git@github.com:forseti-security/policy-library.git
    gsutil -m rsync -d -r policy-library/policies gs://forseti-server-${SUFFIX}/policy-library/policies
    gsutil -m rsync -d -r policy-library/lib gs://forseti-server-${SUFFIX}/policy-library/lib
    gsutil -m rsync -d -r rules/ gs://forseti-server-${SUFFIX}/rules/
    ```
