# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

terraform {
  required_version = ">=0.14"
  required_providers {
    google      = "~> 3.0"
    google-beta = "~> 3.0"
    kubernetes  = "~> 1.0"
  }
  backend "gcs" {
    bucket = "bck-hipaa-demo-terraform-state"
    prefix = "groups"
  }
}


module "project" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 11.1.0"

  project_id    = "proj-devops-rgol"
  activate_apis = []
}
# Required when using end-user ADCs (Application Default Credentials) to manage Cloud Identity groups and memberships.
provider "google-beta" {
  user_project_override = true
  billing_project       = module.project.project_id
}


module "healthcare_auditors_cs_gcp_t_com" {
  source  = "terraform-google-modules/group/google"
  version = "~> 0.2"

  id           = "healthcare-auditors@cs-gcp-t.com"
  customer_id  = "C03kl1ar3"
  display_name = "healthcare-auditors"
  owners       = ["rgola@cs-gcp-t.com"]
}

module "healthcare_cicd_viewers_cs_gcp_t_com" {
  source  = "terraform-google-modules/group/google"
  version = "~> 0.2"

  id           = "healthcare-cicd-viewers@cs-gcp-t.com"
  customer_id  = "C03kl1ar3"
  display_name = "healthcare-cicd-viewers"
  owners       = ["rgola@cs-gcp-t.com"]
}

module "healthcare_cicd_editors_cs_gcp_t_com" {
  source  = "terraform-google-modules/group/google"
  version = "~> 0.2"

  id           = "healthcare-cicd-editors@cs-gcp-t.com"
  customer_id  = "C03kl1ar3"
  display_name = "healthcare-cicd-editors"
  owners       = ["rgola@cs-gcp-t.com"]
}
