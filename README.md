# 🚀 VS Code Server on GCP and OCI

This project provides Terraform configurations for deploying VS Code Server on both Google Cloud Platform (GCP) and Oracle Cloud Infrastructure (OCI).

Each platform has its own dedicated directory containing all the necessary Terraform files, scripts, and documentation.

## ☁️ Platforms

| Platform | Description | Features |
| :--- | :--- | :--- |
| **[Google Cloud (GCP)](./gcp/README.md)** | A robust and scalable deployment on GCP. | • Automated HTTPS with Let's Encrypt<br>• Custom VPC and Firewall<br>• Dedicated IAM Service Account<br>• Static IP Address |
| **[Oracle Cloud (OCI)](./oci/README.md)** | A cost-effective deployment leveraging OCI's Always Free Tier. | • Optimized for Always Free resources<br>• ARM-based instances for performance<br>• Secure VCN with NSGs<br>• Persistent block storage |

## 🚀 Getting Started

Choose your desired cloud platform and follow the detailed instructions in its respective `README.md` file.

###  GCP

1.  **Navigate to the GCP directory:**
    ```bash
    cd gcp
    ```
2.  **Follow the instructions:**
    - GCP README.md

### OCI

1.  **Navigate to the OCI directory:**
    ```bash
    cd oci
    ```
2.  **Follow the instructions:**
    - OCI README.md

## 📁 Project Structure

```plaintext
.
├── gcp/
│   ├── README.md
│   ├── compute.tf
│   ├── locals.tf
│   ├── network.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── variables.tf
│   ├── terraform.tfvars.example
│   └── scripts/
│       └── install-vscode-server.sh
├── oci/
│   ├── README.md
│   ├── compute.tf
│   ├── locals.tf
│   ├── network.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── variables.tf
│   ├── terraform.tfvars.example
│   └── scripts/
│       └── cloud-init.yaml
└── README.md
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a pull request or open an issue for any bugs, improvements, or new features.

1.  Fork the repository.
2.  Create a new feature branch (`git checkout -b feature/amazing-feature`).
3.  Commit your changes (`git commit -m 'Add some amazing feature'`).
4.  Push to the branch (`git push origin feature/amazing-feature`).
5.  Open a Pull Request.

## 📄 License

This project is licensed under the MIT License. See the `LICENSE` file for details.