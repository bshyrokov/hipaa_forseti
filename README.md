#

## Limitations

* Only GitHub repository could be integrated.

## Requirements

* Fulfill all requirements and prerequisites from the [init/README.md](init/README.md) instruction
* Apply all changes from the `init` directory

## Prepare Terraform code

* Whole project based on the [folder.hcl](https://github.com/GoogleCloudPlatform/healthcare-data-protection-suite/blob/master/examples/tfengine/org_foundation.hcl) file. ([details](https://github.com/GoogleCloudPlatform/healthcare-data-protection-suite/tree/master/examples/tfengine))
* Customized `folder.hcl` file is attached to the repository. Please check/modify necessary variables like `parent_id`, `billing_account`, etc.
* Run `tfengine` for the terraform generation:
  
      tfengine --config_path=./folder.hcl --output_path=./terraform

* Generated terraform code is ready, but some fixes and changes has to be done manually. Detailed information about the process is [here](https://github.com/GoogleCloudPlatform/healthcare-data-protection-suite/tree/master/docs/tfengine#usage).

* DevOps project has to be applied first:
  
      cd terraform/devops
      terraform init
      terraform apply

* Enable GCS backend in the `folder.hcl`.

      enable_gcs_backend = true

* Regenerate Terraform code and re-apply changes:

      cd ../../
      tfengine --config_path=./folder.hcl --output_path=./terraform
      cd terraform/devops
      terraform init

  answer `yes` for moving TF state to the bucket in GCS.

* Next step is appllying `terraform/groups` (optional) - if you don't have permission to create groups just make sure the group exists.

      cd ../groups
      terraform init
      terraform apply


* Appply network project manually
  
* Apply changes from cicd

if you see

```bash
Error: Error creating Trigger: googleapi: Error 400: Repository mapping does not exist. Please visit https://console.cloud.google.com/cloud-build/triggers/connect?project=... to connect a repository to your project
```
please just click a link and integrate your repository with the Cloud Build. Run Apply again.

