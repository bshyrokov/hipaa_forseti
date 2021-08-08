# HIPAA compliant organization bootstrap
**This tutorial will let you:**

* Bootstrap new organization structure from scratch
* Create the folder inside organization with proper privileges

## Requirememnts

* All variables in the `variables.tf` file have to be setup correctly
* User which will `apply` this code need the `Organization Admin` and `Billing Admin` role
* User need access to integrate BitBucket / GitHub with Cloud Build.

## Prerequisits

* Terraform version `v0.14.8` has to be installed.
* [Terraform Engine](https://github.com/GoogleCloudPlatform/healthcare-data-protection-suite/releases/) version `v0.9.0` has to be installed.

## Apply changes

        terraform init
        terraform apply

## Install

Check [../README.md](../README.md)