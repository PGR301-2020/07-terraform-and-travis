# LAB 9 - Terraform i Travis CI pipeline 

I denne oppgaven skal vi se nærmere på terraform, og hvorfan vi bruker HCL til å beskrive infrastruktur. Vi skal også se på
hvordan terraform lager infrastruktur. Når vi begynner å få oversikt over terraform, skal vi la Travis kjøre infrastrukturkoden. 


# Terraform og google cloud platform

## provider

```hcl-terraform
provider "google" {
  credentials = "${file("service-account.json")}"
  project     = "devopscube-demo"
  region      = "us-central1"
  zone        = "us-central1-c"
}
```

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

  traffic {
    percent         = 100
    latest_revision = true
  }
}
```

## Operasjoner 

* Prøv ```terraform plan```
* Prøv ```terraform apply```
* Endre en egenskap i main.tf 
* Prøv ```terraform plan```
* prøv terraform destroy
