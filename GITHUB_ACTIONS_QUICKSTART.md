# GitHub Actions Quick Start Guide

## 🚀 Quick Setup (5 minutes)

### For GCP Deployment

1. **Add these secrets** to your GitHub repository (Settings → Secrets → Actions):

   | Secret Name | Where to Find It | Example |
   |------------|------------------|---------|
   | `GCP_CREDENTIALS` | Copy entire service account JSON file | `{"type": "service_account",...}` |
   | `GCP_PROJECT_ID` | GCP Console → Project Info | `solid-choir-472607-r1` |
   | `VSCODE_PASSWORD` | Create a strong password (12+ chars) | `MySecureP@ssw0rd123` |
   | `VSCODE_DOMAIN` | Your domain for VS Code | `vscode.mbtux.com` |
   | `LETSENCRYPT_EMAIL` | Your email for SSL certs | `admin@mbtux.com` |

2. **Run the workflow:**
   - Go to Actions → "Deploy to GCP" → Run workflow
   - Select `plan` first to preview
   - Then select `apply` to deploy

### For OCI Deployment

1. **Add these secrets** to your GitHub repository:

   | Secret Name | Where to Find It | Example |
   |------------|------------------|---------|
   | `OCI_TENANCY_OCID` | OCI Console → Profile → Tenancy | `ocid1.tenancy.oc1..aaa...` |
   | `OCI_USER_OCID` | OCI Console → Profile → User Settings | `ocid1.user.oc1..aaa...` |
   | `OCI_FINGERPRINT` | Generated when you add API key | `aa:bb:cc:dd:ee:ff:...` |
   | `OCI_PRIVATE_KEY` | Your API private key file content | `-----BEGIN RSA PRIVATE KEY-----...` |
   | `OCI_COMPARTMENT_ID` | OCI Console → Identity → Compartments | `ocid1.compartment.oc1..aaa...` |
   | `OCI_REGION` | Your preferred region | `us-phoenix-1` |
   | `VSCODE_PASSWORD` | Create a strong password (12+ chars) | `MySecureP@ssw0rd123` |
   | `SSH_PUBLIC_KEY` | Your SSH public key | `ssh-rsa AAAAB3NzaC1yc2E...` |

2. **Run the workflow:**
   - Go to Actions → "Deploy to OCI" → Run workflow
   - Select `plan` first to preview
   - Then select `apply` to deploy

## 📋 Workflow Actions

### Plan (Preview Changes)
```
Action: plan
Environment: production
```
- Shows what will be created/changed
- No actual changes made
- Safe to run anytime

### Apply (Deploy Infrastructure)
```
Action: apply
Environment: production
```
- Creates/updates infrastructure
- **This will incur cloud costs**
- Review plan output first

### Destroy (Tear Down)
```
Action: destroy
Environment: production
```
- Removes all infrastructure
- **This deletes everything**
- Use when you're done

## 🔒 Security Best Practices

1. **Never commit secrets** to the repository
2. **Use environment protection** for production:
   - Settings → Environments → production
   - Enable "Required reviewers"
3. **Restrict admin IP** in terraform.tfvars:
   ```hcl
   admin_ip_cidr = "YOUR_IP/32"  # Not 0.0.0.0/0
   ```

## 💰 Cost Management

### GCP
- **Free Tier:** e2-micro instance (1 per month)
- **After Free Tier:** ~$7-10/month
- **Always destroy** when not in use

### OCI
- **Always Free:** VM.Standard.E2.1.Micro or VM.Standard.A1.Flex
- **No charges** if using Free Tier resources
- **Still destroy** to clean up when done

## 🔍 Monitoring Deployments

1. **Watch the workflow run:**
   - Actions tab → Click on running workflow
   - Expand steps to see detailed logs

2. **Check Terraform outputs:**
   - Download artifacts after successful apply
   - Contains instance IP, URLs, etc.

3. **Access your VS Code Server:**
   - Wait 5-10 minutes after deployment
   - Visit your domain (GCP) or instance IP (OCI)
   - Login with your VSCODE_PASSWORD

## ❗ Troubleshooting

### "Secrets not found"
→ Double-check secret names (case-sensitive)

### "Authentication failed"
→ Verify credentials are correct and have proper permissions

### "Resource already exists"
→ Run `destroy` first, then `apply` again

### "Terraform state locked"
→ Wait for other workflows to complete, or manually unlock state

## 🎯 Recommended Workflow

**First Time:**
1. Set up all secrets
2. Run `plan` to verify configuration
3. Review plan output carefully
4. Run `apply` to deploy
5. Wait 5-10 minutes for initialization
6. Access your VS Code Server

**When Done:**
1. Save your work
2. Run `destroy` to tear down
3. Verify in cloud console that resources are deleted

**Regular Use:**
1. Run `apply` when you need it
2. Run `destroy` when you're done
3. Only pay for what you use

## 📚 Additional Resources

- [Full Workflow Documentation](.github/workflows/README.md)
- [GCP Terraform Documentation](./gcp/README.md)
- [OCI Terraform Documentation](./oci/README.md)
- [Project Overview](./README.md)

## 🆘 Need Help?

1. Check workflow logs in Actions tab
2. Review error messages carefully
3. Verify all secrets are configured
4. Check cloud provider console for resource status
5. Review Terraform documentation in respective folders

---

**Remember:** Only one cloud environment should be deployed at a time. Destroy one before deploying to another.
