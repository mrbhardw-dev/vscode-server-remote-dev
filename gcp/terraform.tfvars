project_id = "solid-choir-472607-r1"
region     = "europe-west2"
zone       = "europe-west2-a"
#credentials_file = "secrets/solid-choir-472607-r1-f68352350e87.json"

# Instance configuration
machine_type = "e2-micro"
#boot_disk_image = "ubuntu-os-cloud/ubuntu-2204-jammy-v2025-09-20"

# Service account configuration
#service_account = {
#  email  = "mrbhardw-dev-terraform-sa@solid-choir-472607-r1.iam.gserviceaccount.com"
#  scopes = ["https://www.googleapis.com/auth/cloud-platform"]
#}

# VS Code Server configuration
code_server_password = "P@ssw0rd@123"
code_server_domain   = "vscode.mbtux.com"
letsencrypt_email    = "mritunjay.bhardwaj@mbtux.com"
code_server_user     = "codeuser"
http_port            = 8080
