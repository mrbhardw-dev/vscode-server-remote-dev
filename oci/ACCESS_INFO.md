# VS Code Server Access Information

## ⚠️ Important: Correct Port Information

**VS Code Server is on port 8080, NOT 8443**

## Access URLs

### HTTP (Recommended for initial access)
```
http://193.123.190.9:8080
```

### HTTPS (Self-signed certificate)
```
https://193.123.190.9:8080
```

**Note:** If using HTTPS, your browser will show a security warning because it uses a self-signed certificate. This is normal - click "Advanced" and "Proceed" to continue.

## Current Status

- **Installation:** IN PROGRESS ⏳
- **Estimated completion:** 5-10 minutes from deployment
- **Code-server service:** Not started yet (will start automatically when installation completes)

## Why Can't I Access It Yet?

The instance was just created and cloud-init is:
1. ✓ Running system updates
2. ⏳ Installing dependencies (curl, wget, etc.)
3. ⏳ Downloading and installing VS Code Server
4. ⏳ Configuring the systemd service
5. ⏳ Starting the code-server service

This process takes 5-10 minutes on a fresh instance.

## How to Check Installation Progress

### Option 1: Use the status checker script
```bash
./check-vscode-status.sh
```

### Option 2: Monitor via SSH
```bash
# Connect to the instance
ssh ubuntu@193.123.190.9

# Check cloud-init status
sudo cloud-init status

# Watch installation logs in real-time
sudo tail -f /var/log/cloud-init-output.log

# Check if code-server is installed
code-server --version

# Check service status
sudo systemctl status code-server
```

### Option 3: Wait and retry
Simply wait 5-10 minutes and try accessing:
```
http://193.123.190.9:8080
```

## When Installation is Complete

You'll know it's ready when:
1. `sudo cloud-init status` shows: `status: done`
2. `sudo systemctl status code-server` shows: `Active: active (running)`
3. You can access http://193.123.190.9:8080 in your browser

## Troubleshooting

### "Connection refused" or "Unable to connect"
- **Cause:** Installation not complete yet
- **Solution:** Wait a few more minutes and try again

### "This site can't be reached"
- **Cause:** Wrong port (using 8443 instead of 8080)
- **Solution:** Use http://193.123.190.9:8080

### "Your connection is not private" (HTTPS)
- **Cause:** Self-signed certificate
- **Solution:** Click "Advanced" → "Proceed to 193.123.190.9 (unsafe)"
- **Better solution:** Use HTTP: http://193.123.190.9:8080

### Installation seems stuck
```bash
# SSH into the instance
ssh ubuntu@193.123.190.9

# Check what's happening
sudo ps aux | grep cloud-init
sudo tail -100 /var/log/cloud-init-output.log

# If needed, manually install code-server
curl -fsSL https://code-server.dev/install.sh | sh
sudo systemctl enable --now code-server@$USER
```

## Quick Commands Reference

```bash
# Check status
./check-vscode-status.sh

# SSH to instance
ssh ubuntu@193.123.190.9

# View logs
ssh ubuntu@193.123.190.9 "sudo tail -f /var/log/cloud-init-output.log"

# Check service
ssh ubuntu@193.123.190.9 "sudo systemctl status code-server"

# Restart service (if needed)
ssh ubuntu@193.123.190.9 "sudo systemctl restart code-server"
```

## Configuration Details

- **Server IP:** 193.123.190.9
- **VS Code Port:** 8080
- **SSH Port:** 22
- **SSH User:** ubuntu
- **Password:** Set in your terraform.tfvars file

## Next Steps

1. **Wait 5-10 minutes** for installation to complete
2. **Run status checker:** `./check-vscode-status.sh`
3. **Access VS Code:** http://193.123.190.9:8080
4. **Enter your password** (from terraform.tfvars)
5. **Start coding!**

---

**Last Updated:** October 1, 2025, 20:10 UTC  
**Instance Created:** October 1, 2025, 19:05 UTC  
**Expected Ready:** October 1, 2025, 19:15 UTC (approximately)
