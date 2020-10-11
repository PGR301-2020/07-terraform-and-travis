resource "google_storage_bucket" "static-site" {
  project       = "terraform-292215"
  name          = "glennsdronefootage"
  location      = "EU"
}
