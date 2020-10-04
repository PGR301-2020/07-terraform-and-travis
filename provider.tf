terraform {
  backend "gcs" {
    bucket = "devopscube-states"
    prefix = "demo"
    credentials = "service-account.json"
  }
}

provider "google" {
  credentials = "${file("service-account.json")}"
  project     = ""
}