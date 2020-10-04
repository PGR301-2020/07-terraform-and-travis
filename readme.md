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

# Terraform state

Terraform har et konsept om "state" som i praksis er et JSON dokument som holder orden knytningen til de faktiske ressurser i infrastrukturen og terraform koden. Denne JSON filen oppdateres kontinuerlig når infrastrukturen endrer seg, og må deles av teamet og med CI server. En mekanisme for lagring av en slik fil kalles en "backend" i Terraform. 
Vi skla bruke GCP og tjenesten google storage for dette. 

T
```
terraform {
  backend "s3" {
    bucket = "pgr301bucket"
    key    = "<unik_id>/terraform.tfstate"
    region = "eu-north-1"
  }
}
```

# Infrastruktur - repo

Det kan være god praksis å skille infrastruktur fra app (det er diskusjoner rundt dette...) - og i dette faget velger i å lage et eget github repository for Github koden vår. Da er det enklere å lage en egen Travis pipeline, som reagerer på kun endringer i infrastrukturkoden. 

* Lag et helt nytt repo for infrastruktur for Spring boot eksemplet. 
* Legg til Repoet til i Travis CI. 
* Flytt Terraform koden som du brukte for å lage en pipeline i Heroku dit. 
* Se på https://github.com/pgr301-2019/infra-repo-example for inspirasjon

Ps Husk at build.sh må være executable (chmod +x build.sh)

## Hemmeligheter 

For at Travis skal kunne deploye kode til Heroku - og for at Travis skal få lov til å skrive terraform state til AWS S3 - må vi legge til "hemmeligheter" med travis encrypt på kommandlinje 

```
travis encrypt HEROKU_EMAIL=your.email@somewhere.com --add
travis encrypt HEROKU_API_KEY=<API_KEY> --add
travis encrypt AWS_ACCESS_KEY_ID=<KEY> --add
travis encrypt AWS_SECRET_ACCESS_KEY=<SECRET_ACCESS_KEY>
```

Disse kommandoene krypterer hemmeligheter med repoets offentlige nøkke, og legger veridiene inn i .travis.yml - du må huske på å sjekke inn/pushe - filen etterpå. Disse verdiene / nøklene blir miljøvariabler og gjort tilgjengelig for Travis og applikasjonen.

# Lek med pipeline

Dere skal nå være i stand til å endre på infrastruktur koden, og Travis vil endre på infrastrukturen. Det er slik dere bør 
jobbe med IAC - og det er det eneste som virker for team og prosjekter av litt størrelse. 

# Utvid infrakoden med overvåking

Bruk dokumentasjonen til StatusCake provider for Terraform ; https://www.terraform.io/docs/providers/statuscake/index.html - og legg til overvåkning på endepunktene på en test applikasjon - eller en annen tjeneste dere vil overvåke. Dere kan for eksempel besøke Lab3 på nytt og deploye en enkel heroku applikasjon. 

* Bruk travis encrypt til å legge til StatusCake credentials til byggejobben (STATUSCAKE_APIKEY, STATUSCAKE_USERNAME)
* Se på https://github.com/pgr301-2019/infra-repo-example for inspirasjon

