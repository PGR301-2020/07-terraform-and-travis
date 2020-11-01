resource "google_monitoring_uptime_check_config" "https" {
  display_name = "https-uptime-check"
  timeout = "10s"

  http_check {
    path = module.urlparser.path
  }

  monitored_resource {
    type = "uptime_url"
    labels = {
      host = module.urlparser.host
    }
  }
}

module "urlparser" {
  source = "matti/urlparse/external"
  url = google_cloud_run_service.status.url

}