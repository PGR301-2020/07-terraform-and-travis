
provider "google" {
  credentials = "${file("terraform.json")}"
  project     = "terraform-292215"
  region      = "us-central1"
  zone        = "us-central1-c"
}