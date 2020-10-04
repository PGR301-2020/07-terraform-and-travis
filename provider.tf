terraform {
  backend "gcs" {
    bucket = "pgr301-state"
    prefix = "pgr301-docker-demo"
    credentials = "service-account.json"
  }
}

provider "google-beta" {
  credentials = "${file("./service-account.json")}"
  project     = "pgr301-docker-demo"
  version = "~> 3.0.0-beta.1"
}
