# Terraform fra lokal maskin og i Travis CI pipeline 

I denne oppgaven skal vi se nærmere på terraform, og hvorfan vi bruker HCL til å beskrive infrastruktur. Vi skal også se på
hvordan terraform lager infrastruktur. Når vi begynner å få oversikt over terraform, skal vi la Travis kjøre infrastrukturkoden. 

## Instaler Terraform 

https://www.terraform.io/downloads.html

## provider

Terraform er ikke kresen på hva du kaller filer. I praksis vil bare terrafrom ta alle .tf filer i nåværende katalog og lage ett dokument før  
prosessering starter. 

Lag en fil som du kaller provider.tf

```hcl-terraform
provider "google" {
  credentials = "${file("service-account.json")}"
  project     = "devopscube-demo"
  region      = "us-central1"
  zone        = "us-central1-c"
}
```

Lag en fil du kaller main.tf

## Resource 

```hcl-terraform
resource "google_cloud_run_service" "default" {
  name     = "cloudrun-srv"
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
```

## Autentiser gcloud mot et GCP prosjekt  

```
gcloud auth application-default login
```

## Operasjoner 

* Prøv ```terraform plan```
* Prøv ```terraform apply```
* Endre en egenskap i main.tf 
* Prøv ```terraform plan```
* prøv terraform destroy


# Terraform i pipeline 

Målet er at vi kun skal Travis eller valgt "CI" verktøy skal gjøre endringer i infrastrukturen. Vi skal kun endre infrastrukturkoden. 
For å 

## Lag et nytt repository for infrastruktur 

Kopier terraform filene i denne dette dokumentet til repoet. 

## Lag en service 

