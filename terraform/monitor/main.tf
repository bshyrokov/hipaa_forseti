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
    prefix = "monitor"
  }
}

# Create the project and optionally enable APIs, create the deletion lien and add to shared VPC.
# Deletion lien: https://cloud.google.com/resource-manager/docs/project-liens
# Shared VPC: https://cloud.google.com/docs/enterprise/best-practices-for-enterprise-organizations#centralize_network_control
module "project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 11.1.0"

  name            = "prj-monitor-rgol"
  org_id          = ""
  folder_id       = "909984588844"
  billing_account = "011BB4-25F476-819B61"
  lien            = true
  # Create and keep default service accounts when certain APIs are enabled.
  default_service_account = "keep"
  # Do not create an additional project service account to be used for Compute Engine.
  create_project_sa = false
  # When Kubernetes Engine API is enabled, grant Kubernetes Engine Service Agent the
  # Compute Security Admin role on the VPC host project so it can manage firewall rules.
  # It is a no-op when Kubernetes Engine API is not enabled in the project.
  grant_services_security_admin_role = true

  svpc_host_project_id = "prj-prod-networks-rgol"
  activate_apis        = ["compute.googleapis.com"]
}


module "forseti" {
  source  = "terraform-google-modules/forseti/google"
  version = "~> 5.2.2"

  domain          = "cs-gcp-t.com"
  project_id      = module.project.project_id
  folder_id       = "909984588844"
  network_project = "prj-prod-networks-rgol"
  network         = "prod-network"
  subnetwork      = "forseti-subnet"
  composite_root_resources = [
    "folders/909984588844",
  ]

  server_region           = "us-central1"
  cloudsql_region         = "us-central1"
  storage_bucket_location = "us-central1"
  bucket_cai_location     = "us-central1"

  cloudsql_private  = true
  client_enabled    = false
  server_private    = true
  server_boot_image = "ubuntu-1804-bionic-v20210720"
  server_shielded_instance_config = {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  manage_rules_enabled          = false
  config_validator_enabled      = true
  enabled_apis_enabled          = true

  # Enable Security Command Center (SCC) notification.
  cscc_violations_enabled = true
  cscc_source_id          = "organizations/369138972385/sources/15146003993443038854"
}
