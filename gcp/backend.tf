terraform {
  backend "gcs" {
    bucket = "mbtux-dev-tf-01"
    prefix = "terraform/state/vscode-server-gcp"

  }
}