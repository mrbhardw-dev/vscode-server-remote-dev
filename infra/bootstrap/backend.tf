terraform {
  backend "gcs" {
    bucket = "tf-state-solid-choir-472607-r1"
    prefix = "gcp-cicd-bootstrap"
  }
}