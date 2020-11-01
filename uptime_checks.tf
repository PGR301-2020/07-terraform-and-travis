provider "statuscake" {
  username = "postglennbechno"
}

resource "statuscake_test" "google" {
  website_name = "google.com"
  website_url  = google_cloud_run_service.hello.status[0].url
  test_type    = "HTTP"
  check_rate   = 300
  contact_id   = 12345
}