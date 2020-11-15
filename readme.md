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

Kjør følgende kommando og velg det samme prosjektet som du har brukt for Docker/Travis øvningen. 

```
gcloud init
```

## Operasjoner 

* Prøv ```terraform plan```
* Prøv ```terraform apply```
* Endre en egenskap i main.tf - prøv for eksempel å bytte container  
* Prøv ```terraform plan```
* prøv terraform destroy

Se på state filen for moro skyld. 

# Terraform i pipeline 

Målet er at vi kun skal Travis eller valgt "CI" verktøy skal gjøre endringer i infrastrukturen. Vi skal kun endre infrastrukturkoden. 
For å 

## Lag et nytt repository for infrastruktur 

Kopier filene fra dette repositoryet, eller lag en fork 

Du må se over provider.tf og endre 

* Bucket - Du må lage en Google Cloud Storage bucket i prosjektet ditt, og sette navnet inn her
* credentials - Du må sette inn riktig navn til credentials fil *både* i backend - og provider blokken
* project - Du må sette inn riktig prosjekt id 

Aktiver Travis for repositoriet. 


## Lag et nytt prosjekt og serviceaccount

Jeg anbefaler å lage et nyttt prosjekt for å være sikker på at du kjenner til prosessen. Husk det "vanlige"

- Sørg for at prosjektet har billing, ved å besøke "billing" siden i console når du har valgt prosjektet som det aktive i UI. 
- Velg APIs & services. Sørg for at Container Registry, Cloud Storage og Cloud Run er enabled. 
- Lag en ny service account
- Legg til service account som en "member" i prosjektet
- Legg til følgende roller til service account; Google Stoeage Admin, Container Registry Service Agent, Cloud Run Service Agent 
- Last ned en nøkkelfil for service account og lagre denne i rotkatalogen til infrastruktur repository
- DU må ikke COMITTE denne filen!


## Lag en .travis.yml fil

Du kan bruke følgende som utgangspunkt, og erstatte for egne verdier for <key file> og <your project id> 

```yaml
env:
  global:
  - GCP_PROJECT_ID=<your project id>
  - tf_version=0.12.19
  - CLOUDSDK_CORE_DISABLE_PROMPTS=1
branches:
  only:
  - master
before_install:
- curl https://sdk.cloud.google.com | bash > /dev/null
- source "$HOME/google-cloud-sdk/path.bash.inc"
- gcloud auth activate-service-account --key-file=<key-file>.json
- gcloud config set project "${GCP_PROJECT_ID}"
- export GOOGLE_APPLICATION_CREDENTIALS=./<key-file>.json
- wget https://releases.hashicorp.com/terraform/"$tf_version"/terraform_"$tf_version"_linux_amd64.zip
- unzip terraform_"$tf_version"_linux_amd64.zip
- sudo mv terraform /usr/local/bin/
- rm terraform_"$tf_version"_linux_amd64.zip
install: true
script:
- |-
  set -ex;
  terraform init
  terraform plan
  terraform apply --auto-approve
  terraform output

```

## Kjør travis encrypt 

Legg merke til --add. openssl kommandoen som dekrypterer legges rett inn i .travis.yml filen uten at du trenger å gjøre noe .
```bash
 travis encrypt-file terraform.json --add
```

NB. Hvis du har hatt problemer med Travis Encrypt for Windows er naturligvis løsningen... Docker. Det finnes et Docker image som har travis CLI, og som er basert
på et Linux OS. Du kan kjøre (feks git bash)

```bash
docker run -v $(pwd):/project --rm skandyla/travis-cli encrypt-file <some-file> --add 
``` 

## Forsøk å endre på infrastruktur 

Endringer i infrastrukturen din skal nå kunne gjøres ved å  comitte endringer på master i ditt infrastruktur repository

## Del 2: Connect the dots. ..

### Prøv følgende

Det er nå på tide å deploye vår egen applikasjon i Google cloudrun ved hjelp av Terraform og Travis.  
Vi skal bruke samme GCP prosjekt for både infrastruktur og kode. Vi skal ogsså ha to repositories, ett for applikasjonen, og ett for 
infrastruktur. 

Nye versjoner av applikasjonen bygges av Travis og et nytt docker image pushes til Google Cloud Registry på hver endring av master branch. 
Når man ønsker å legge ut en ny versjon av applikasjonen, endrer man Docker image i Terraform koden.

* lag en endring i applikasjonen, push til master
* Se at Jenkins jobben til applikasjonen kjører ok
* Kontroller Google Cloud Registry at det er ny revisjon av container image for applikasjonen 
* Kopier container image ID, og sett den inn i main.tf i terrafomr koden  under "google_cloud_run_service" ressursen
* Sjekk at Jenkins jobben for terraform infrastruktur kjører OK
* Verifiser at applikasjonen



### Applikasjon

Bruk en oppgave der vi tidligere har bygget en Java applikasjon med maven i docker multi stage. For et eksempel, se på https://github.com/PGR301-2020/01-devops-helloworld. 

.travis.yml skal se omtrent slik ut ; 

```yml
services:
- docker
env:
  global:
  - GCP_PROJECT_ID=<gcp-project-id>
  - IMAGE=gcr.io/<gcp-project-id>/<image-name>
  - CLOUDSDK_CORE_DISABLE_PROMPTS=1
before_install:
- openssl aes-256-cbc -K $encrypted_ba8f794f8d33_key -iv $encrypted_ba8f794f8d33_iv
  -in <key-json-file>.enc -out <key-json-file> -d
- curl https://sdk.cloud.google.com | bash > /dev/null
- source "$HOME/google-cloud-sdk/path.bash.inc"
- gcloud auth activate-service-account --key-file=<key-json-file>
- gcloud auth configure-docker
- gcloud config set project "${GCP_PROJECT_ID}"
install: true
script:
- |-
  set -ex;
  docker build -t "${IMAGE}:${TRAVIS_COMMIT}" . && \
  docker push "${IMAGE}:${TRAVIS_COMMIT}" && \
  set +x
```

Vi må erstatte følgende verdier 

* gcp-project-id - Hvilket Google Cloud prosjekt vi skal bruke 
* image-name - Et navn du velger for et docker image 
* key-json-file - Navnet på en JSON som inneholdet privat nøkkel lastet ned for en Service Account.


### Inrastruktur 

Følgende seksjon i main.tf bestemmer hvilket container image som brukes for cloud run
```
template {
  spec {
    containers {
      image = "gcr.io/terraform-292215/helloworld@sha256:0ee92532317e87faadbe0231986e827605d1d97cbf9acd9c44557f49a416867d"
    }
  }
}
```
