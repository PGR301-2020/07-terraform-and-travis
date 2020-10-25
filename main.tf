resource "google_cloud_run_service" "hello" {
  name = "helloworld-service"
  location = "us-central1"
  project = "terraform-292215"

  template {
    spec {
      containers {
        image = "gcr.io/terraform-292215/helloworld@sha256:11b936b0a2f6adf879d7167291e46cca44dae155f70bfb210bb8731edfe8589e"
        env {
          name = "LOGZ_TOKEN"
          value = var.logz_token
        }
      }
    }
  }


  traffic {
    percent = 100
    latest_revision = true
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
  location = google_cloud_run_service.hello.location
  project = google_cloud_run_service.hello.project
  service = google_cloud_run_service.hello.name
  policy_data = data.google_iam_policy.noauth.policy_data
}