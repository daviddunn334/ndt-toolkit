# Domain & Hosting Setup Guide

This guide covers the complete domain setup for NDT Toolkit's multi-site hosting architecture.

## 🌐 Domain Structure

The NDT Toolkit uses a multi-site architecture across different domains:

| Domain | Purpose | Firebase Site | Branch |
|--------|---------|---------------|--------|
| `ndt-toolkit.com` | Marketing/Landing Page | ndt-toolkit-marketing | marketing |
| `app.ndt-toolkit.com` | Main Flutter App (Production) | ndt-toolkit | main |
| `preview.ndt-toolkit.com` | Preview/Testing | ndt-toolkit-preview | development |
| `admin.ndt-toolkit.com` | Admin Panel | admin-ndt-toolkit | admin-panel |

---

## 📋 Prerequisites

Before starting domain setup:
- ✅ Domain purchased and verified in Firebase Console
- ✅ Firebase hosting sites created for each target
- ✅ Firebase CLI installed: `npm install -g firebase-tools`
- ✅ Access to domain registrar's DNS settings

---

## 🔧 Firebase Configuration

### `.firebaserc` Configuration

```json
{
  "projects": {
    "default": "ndt-toolkit"
  },
  "targets": {
    "ndt-toolkit": {
      "hosting": {
        "marketing": ["ndt-toolkit-marketing"],
        "production": ["ndt-toolkit"],
        "preview": ["ndt-toolkit-preview"],
        "admin": ["admin-ndt-toolkit"]
      }
    }
  }
}
```

### `firebase.json` Configuration

The firebase.json file defines separate hosting configurations for each target:

```json
{
  "hosting": [
    {
      "target": "marketing",
      "public": "web_marketing",
      "ignore": ["firebase.json", "**/.*", "**/node_modules/**"]
    },
    {
      "target": "production",
      "public": "build/web",
      "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
      "rewrites": [
        { "source": "**", "destination": "/index.html" }
      ]
    },
    {
      "target": "preview",
      "public": "build/web",
      "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
      "rewrites": [
        { "source": "**", "destination": "/index.html" }
      ]
    },
    {
      "target": "admin",
      "public": "build/web",
      "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
      "rewrites": [
        { "source": "**", "destination": "/index.html" }
      ]
    }
  ]
}
```

---

## 🚀 Setting Up Custom Domains

### Step 1: Verify Domain in Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select **ndt-toolkit** project
3. Navigate to **Hosting** → **Get Started**
4. Click **Add custom domain**
5. Enter your root domain: `ndt-toolkit.com`
6. Follow verification steps (add TXT record to DNS)

### Step 2: Connect Root Domain (Marketing Site)

**Firebase Site:** `ndt-toolkit-marketing`

1. In Firebase Console, go to the `ndt-toolkit-marketing` hosting site
2. Click **Add custom domain**
3. Enter: `ndt-toolkit.com`
4. Choose to add both `ndt-toolkit.com` and `www.ndt-toolkit.com`
5. Firebase will provide A records:
   ```
   Type: A
   Name: @ (or blank)
   Value: 199.36.158.100
   
   Type: A
   Name: www
   Value: 199.36.158.100
   ```
6. Add these records to your DNS provider
7. Wait for DNS propagation (5 min - 24 hours)
8. Firebase will auto-provision SSL certificates

### Step 3: Connect App Subdomain

**Firebase Site:** `ndt-toolkit` (production)

1. In Firebase Console, go to the `ndt-toolkit` hosting site
2. Click **Add custom domain**
3. Enter: `app.ndt-toolkit.com`
4. Firebase will provide:
   ```
   Type: TXT (for verification)
   Name: _acme-challenge.app
   Value: [Firebase-provided value]
   
   Type: A
   Name: app
   Value: 199.36.158.100
   ```
5. Add these records to your DNS provider
6. Click **Verify** in Firebase
7. Wait for SSL provisioning

### Step 4: Connect Preview Subdomain

**Firebase Site:** `ndt-toolkit-preview`

1. In Firebase Console, go to the `ndt-toolkit-preview` hosting site
2. Click **Add custom domain**
3. Enter: `preview.ndt-toolkit.com`
4. Firebase will provide:
   ```
   Type: TXT
   Name: _acme-challenge.preview
   Value: [Firebase-provided value]
   
   Type: A
   Name: preview
   Value: 199.36.158.100
   ```
5. Add these records to your DNS provider
6. Click **Verify** in Firebase
7. Wait for SSL provisioning

### Step 5: Connect Admin Subdomain

**Firebase Site:** `admin-ndt-toolkit`

1. In Firebase Console, go to the `admin-ndt-toolkit` hosting site
2. Click **Add custom domain**
3. Enter: `admin.ndt-toolkit.com`
4. Firebase will provide:
   ```
   Type: TXT
   Name: _acme-challenge.admin
   Value: [Firebase-provided value]
   
   Type: A
   Name: admin
   Value: 199.36.158.100
   ```
5. Add these records to your DNS provider
6. Click **Verify** in Firebase
7. Wait for SSL provisioning

---

## 📊 Final DNS Configuration Summary

After setup, your DNS records should look like this:

| Type | Name/Host | Value | Purpose |
|------|-----------|-------|---------|
| TXT | @ | hosting-site=ndt-toolkit-marketing | Root domain ownership |
| A | @ | 199.36.158.100 | Root domain (marketing) |
| A | www | 199.36.158.100 | WWW subdomain (marketing) |
| A | app | 199.36.158.100 | App subdomain (production) |
| A | preview | 199.36.158.100 | Preview subdomain |
| A | admin | 199.36.158.100 | Admin subdomain |
| TXT | _acme-challenge.app | [Firebase value] | SSL verification |
| TXT | _acme-challenge.preview | [Firebase value] | SSL verification |
| TXT | _acme-challenge.admin | [Firebase value] | SSL verification |

**Important:** Only ONE `hosting-site=` TXT record should exist for the root domain.

---

## ✅ Verification

After DNS propagation, test each domain:

```bash
# Test domains are loading
curl -I https://ndt-toolkit.com
curl -I https://app.ndt-toolkit.com
curl -I https://preview.ndt-toolkit.com
curl -I https://admin.ndt-toolkit.com

# Check SSL certificates
curl -vI https://app.ndt-toolkit.com 2>&1 | grep "SSL certificate"
```

All should return **200 OK** with valid SSL certificates.

---

## 🆘 Troubleshooting

### Domain Not Loading
- **Wait longer:** DNS can take up to 24 hours to propagate
- **Clear cache:** Try incognito mode or different browser
- **Check DNS propagation:** Use [DNS Checker](https://dnschecker.org)
- **Verify records:** Double-check all DNS records in registrar

### SSL Certificate Issues
- Wait up to 1 hour after DNS verification for auto-provisioning
- Ensure TXT records for `_acme-challenge` subdomains are correct
- Try re-verifying domain in Firebase Console
- Check Firebase Console for SSL status

### Wrong Site Loading on Subdomain
- Verify the subdomain is connected to the correct Firebase hosting site
- Check `.firebaserc` targets match Firebase site IDs
- Ensure you deployed to the correct target

### DNS Changes Not Taking Effect
- Flush DNS cache locally: `ipconfig /flushdns` (Windows) or `sudo dscacheutil -flushcache` (Mac)
- Some ISPs cache DNS longer than others
- Test with online DNS checker tools

---

## 🔄 Deployment After Domain Setup

Once domains are connected, deploy to each site using:

```bash
# Deploy to production (app.ndt-toolkit.com)
firebase deploy --only hosting:production

# Deploy to preview (preview.ndt-toolkit.com)
firebase deploy --only hosting:preview

# Deploy to marketing (ndt-toolkit.com)
firebase deploy --only hosting:marketing

# Deploy to admin (admin.ndt-toolkit.com)
firebase deploy --only hosting:admin

# Deploy to all sites
firebase deploy --only hosting
```

Or use GitHub Actions for automatic deployment (see CI/CD documentation).

---

## 📱 Benefits of This Architecture

1. **Marketing Independence:** Update marketing site without touching app code
2. **Branch-Based Deployments:** Each branch deploys to its own domain automatically
3. **Professional URLs:** Clean structure with purpose-specific subdomains
4. **Easy Testing:** Preview changes before production deployment
5. **Admin Separation:** Dedicated domain for admin features
6. **SEO Friendly:** Marketing site on root domain for better discoverability

---

## 📚 Related Documentation

- [GitHub Actions Setup](./GITHUB_ACTIONS.md) - Automated deployments
- [Getting Started](./GETTING_STARTED.md) - Initial project setup
- [Deployment Guide](../DEPLOYMENT.md) - Manual deployment procedures

---

**Last Updated:** February 19, 2026
