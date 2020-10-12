resource "google_cloud_run_service" "default" {
  name     = "cloudrun-srv-2"
  project  = "terraform-292215"
  location = "us-central1"

  template {
    spec {
      containers {
        image = "gcr.io/cloudrun/hello"
      }
    }
  }
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = google_cloud_run_service.default.location
  project     = google_cloud_run_service.default.project
  service     = google_cloud_run_service.default.name

  policy_data = data.google_iam_policy.noauth.policy_data
}


provider "google" {
  credentials = "${file("terraform.json")}"
  project     = "terraform-292215"
  region      = "us-central1"
  zone        = "us-central1-c"
}