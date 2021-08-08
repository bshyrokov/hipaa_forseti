variable "project_owners" {
  type = map(strings)
  default = [
    "rgola@cs-gcp-t.com"
  ]
}

variable "organization_id" {
  type = string
  default = "369138972385"
}

variable "region" {
  type = string
  default = "europe-west3"
}

variable "zone" {
  type = map(string)
  default = ["europe-west3-b", "europe-west3-c", "europe-west3-a"]
}
