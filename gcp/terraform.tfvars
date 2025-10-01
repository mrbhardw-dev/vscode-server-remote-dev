project_id       = "solid-choir-472607-r1"
region           = "europe-west2"
zone             = "europe-west2-a"
credentials_file = "secrets/solid-choir-472607-r1-f68352350e87.json"

# Instance configuration
machine_type    = "e2-micro"
boot_disk_image = "projects/debian-cloud/global/images/family/debian-11"

# Service account configuration
service_account = {
  email  = "mrbhardw-dev-terraform-sa@solid-choir-472607-r1.iam.gserviceaccount.com"
  scopes = ["https://www.googleapis.com/auth/cloud-platform"]
}

# VS Code Server configuration
vscode_domain     = "vscode.mbtux.com"
letsencrypt_email = "admin@mbtux.com"
vscode_password   = "P@ssw0rd@123"
admin_ip_cidr     = "208.127.201.111/32"
