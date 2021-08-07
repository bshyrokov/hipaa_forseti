resource "random_id" "id" {
  byte_length = 4
}

resource "google_folder" "folder" {
  display_name = format("fldr-healthcare-%s", random_id.id.hex)
  parent       = format("organizations/%s", var.organization_id)
}

resource "google_folder_iam_binding" "folder_folder_admin" {
  folder = google_folder.folder.name
  role   = "roles/resourcemanager.folderAdmin"

  members = [
    for member in var.project_owners :
    format("%s:%s", "user", member)
  ]
}

resource "google_folder_iam_binding" "folder_project_creator" {
  folder = google_folder.folder.name
  role   = "roles/resourcemanager.projectCreator"

  members = [
    for member in var.project_owners :
    format("%s:%s", "user", member)
  ]
}

resource "google_folder_iam_binding" "folder_xpn_admin" {
  folder = google_folder.folder.name
  role   = "roles/compute.xpnAdmin"

  members = [
    for member in var.project_owners :
    format("%s:%s", "user", member)
  ]
}
