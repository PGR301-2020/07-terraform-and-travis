resource "google_storage_bucket" "static-site" {
  project     = "terraform"
  name          = "image-store.com"
  location      = "EU"
}
