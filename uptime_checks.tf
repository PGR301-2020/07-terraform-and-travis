resource "google_monitoring_uptime_check_config" "http" {
  display_name = "http-uptime-check"
  timeout      = "60s"

  http_check {
    path = "/"
    request_method = "GET"
  }

  monitored_resource {
    type = "uptime_url"
    labels = {
      project_id = "terraform"
      host       = module.urlparser.host
    }
  }

  content_matchers {
    content = "example"
  }
}
Open in Cloud Shell


module "urlparser" {
  source = "matti/urlparse/external"
  url = google_cloud_run_service.hello.status[0].url

}