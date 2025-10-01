# ✓ HTTPS Setup Complete

**Date:** October 1, 2025, 20:24 UTC

## Access URLs

### HTTPS (Recommended)
```
https://193.123.190.9:8443
```

### HTTP (Alternative)
```
http://193.123.190.9:8080
```

## Configuration Details

| Component | Port | Service | Status |
|-----------|------|---------|--------|
| Code-server | 8080 | Direct HTTP access | ✓ Running |
| Nginx | 8443 | HTTPS reverse proxy | ✓ Running |

## SSL Certificate

- **Type:** Self-signed certificate
- **Validity:** 365 days
- **Location:** `/etc/nginx/ssl/`
  - Certificate: `/etc/nginx/ssl/vscode.crt`
  - Private Key: `/etc/nginx/ssl/vscode.key`

## Browser Security Warning

When you first access `https://193.123.190.9:8443`, your browser will show a security warning:

> **"Your connection is not private"** or **"Not secure"**

This is **NORMAL** and expected with self-signed certificates.

### How to Proceed

**Chrome/Edge:**
1. Click "Advanced"
2. Click "Proceed to 193.123.190.9 (unsafe)"

**Firefox:**
1. Click "Advanced"
2. Click "Accept the Risk and Continue"

**Safari:**
1. Click "Show Details"
2. Click "visit this website"
3. Click "Visit Website" again

## Architecture

```
Browser (HTTPS) → Port 8443 (Nginx) → Port 8080 (Code-server)
Browser (HTTP)  → Port 8080 (Code-server directly)
```

## Nginx Configuration

Location: `/etc/nginx/sites-available/vscode`

```nginx
server {
    listen 8443 ssl http2;
    listen [::]:8443 ssl http2;
    server_name _;

    ssl_certificate /etc/nginx/ssl/vscode.crt;
    ssl_certificate_key /etc/nginx/ssl/vscode.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection upgrade;
        proxy_http_version 1.1;
        proxy_read_timeout 86400;
    }
}
```

## Management Commands

### Check Services Status

```bash
# Check nginx
ssh ubuntu@193.123.190.9 "sudo systemctl status nginx"

# Check code-server
ssh ubuntu@193.123.190.9 "sudo systemctl status code-server"

# Check listening ports
ssh ubuntu@193.123.190.9 "sudo ss -tlnp | grep -E ':(8080|8443)'"
```

### Restart Services

```bash
# Restart nginx
ssh ubuntu@193.123.190.9 "sudo systemctl restart nginx"

# Restart code-server
ssh ubuntu@193.123.190.9 "sudo systemctl restart code-server"

# Restart both
ssh ubuntu@193.123.190.9 "sudo systemctl restart nginx code-server"
```

### View Logs

```bash
# Nginx access logs
ssh ubuntu@193.123.190.9 "sudo tail -f /var/log/nginx/access.log"

# Nginx error logs
ssh ubuntu@193.123.190.9 "sudo tail -f /var/log/nginx/error.log"

# Code-server logs
ssh ubuntu@193.123.190.9 "sudo journalctl -u code-server -f"
```

### Test Configuration

```bash
# Test nginx config
ssh ubuntu@193.123.190.9 "sudo nginx -t"

# Reload nginx (without restart)
ssh ubuntu@193.123.190.9 "sudo nginx -s reload"
```

## Troubleshooting

### Can't access HTTPS (port 8443)

1. **Check if nginx is running:**
   ```bash
   ssh ubuntu@193.123.190.9 "sudo systemctl status nginx"
   ```

2. **Check if port is listening:**
   ```bash
   ssh ubuntu@193.123.190.9 "sudo ss -tlnp | grep 8443"
   ```

3. **Check nginx logs:**
   ```bash
   ssh ubuntu@193.123.190.9 "sudo tail -50 /var/log/nginx/error.log"
   ```

4. **Restart nginx:**
   ```bash
   ssh ubuntu@193.123.190.9 "sudo systemctl restart nginx"
   ```

### HTTP (8080) works but HTTPS (8443) doesn't

This is likely a firewall issue. The OCI security list needs to allow port 8443.

**Check OCI Console:**
1. Go to: Networking → Virtual Cloud Networks
2. Select your VCN
3. Click on Security Lists
4. Verify port 8443 is allowed in ingress rules

### Certificate Expired

The self-signed certificate is valid for 365 days. To regenerate:

```bash
ssh ubuntu@193.123.190.9 'bash -s' << 'ENDSSH'
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/vscode.key \
    -out /etc/nginx/ssl/vscode.crt \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=vscode-server"
sudo systemctl restart nginx
ENDSSH
```

## Upgrading to Real SSL Certificate (Optional)

For a production environment, you can use Let's Encrypt for a real SSL certificate:

### Prerequisites
- A domain name pointing to your server IP
- Port 80 must be accessible

### Steps

```bash
ssh ubuntu@193.123.190.9

# Install certbot
sudo apt-get update
sudo apt-get install -y certbot python3-certbot-nginx

# Get certificate (replace example.com with your domain)
sudo certbot --nginx -d example.com

# Certbot will automatically configure nginx
# Certificate auto-renews every 90 days
```

## Security Notes

### Current Setup
- ✓ HTTPS enabled with TLS 1.2/1.3
- ✓ Password authentication required
- ✓ WebSocket support enabled
- ⚠️ Self-signed certificate (browser warning)
- ⚠️ Ports open to 0.0.0.0/0 (all IPs)

### Recommendations

1. **Restrict SSH access** (edit `terraform.tfvars`):
   ```hcl
   allowed_ssh_cidr = "YOUR_IP/32"
   ```

2. **Use a real SSL certificate** (Let's Encrypt) if you have a domain

3. **Enable firewall** (optional):
   ```bash
   ssh ubuntu@193.123.190.9
   sudo ufw allow 22/tcp
   sudo ufw allow 8080/tcp
   sudo ufw allow 8443/tcp
   sudo ufw enable
   ```

4. **Regular updates**:
   ```bash
   ssh ubuntu@193.123.190.9
   sudo apt update && sudo apt upgrade -y
   ```

## Summary

✅ **HTTPS is now enabled on port 8443**
✅ **HTTP still works on port 8080**
✅ **Both services start automatically on boot**
✅ **Self-signed certificate valid for 365 days**

**Primary Access URL:** https://193.123.190.9:8443

---

**Setup completed:** October 1, 2025, 20:24 UTC  
**Next maintenance:** October 1, 2026 (certificate renewal)
