# 🎯 Domain Restructuring Complete

## Overview

The NDT Toolkit hosting has been restructured to support a marketing site at the root domain with the app on a subdomain.

---

## 🌐 Domain Structure

### Before:
- `ndt-toolkit.com` → Flutter App (production)
- `preview.ndt-toolkit.com` → Flutter App (preview)
- `admin.ndt-toolkit.com` → Admin Panel

### After (Current):
- **`ndt-toolkit.com`** → Marketing/Landing Page
- **`app.ndt-toolkit.com`** → Flutter App (production)
- **`preview.ndt-toolkit.com`** → Flutter App (preview)
- **`admin.ndt-toolkit.com`** → Admin Panel

---

## 📂 Repository Structure

### Branches in This Repo:

1. **`main`** → Production Flutter App
   - Deploys to: `app.ndt-toolkit.com`
   - Source: `build/web`

2. **`development`** → Preview Flutter App
   - Deploys to: `preview.ndt-toolkit.com`
   - Source: `build/web`

3. **`admin-panel`** → Admin Panel
   - Deploys to: `admin.ndt-toolkit.com`
   - Source: `build/web`

### Marketing Site (Separate Repo):

The marketing site has been moved to its own repository:
- **Repository:** `ndt-toolkit-marketing` (separate repo)
- **Deploys to:** `ndt-toolkit.com` (root domain)
- **Note:** Marketing site is no longer maintained in this repository

---

## 🔧 Firebase Configuration

### Firebase Hosting Sites:

1. **ndt-toolkit-marketing** → `ndt-toolkit.com`
2. **ndt-toolkit** → `app.ndt-toolkit.com`
3. **ndt-toolkit-preview** → `preview.ndt-toolkit.com`
4. **admin-ndt-toolkit** → `admin.ndt-toolkit.com`

### Configuration Files:

#### `.firebaserc`
```json
{
  "targets": {
    "ndt-toolkit": {
      "hosting": {
        "production": ["ndt-toolkit"],
        "preview": ["ndt-toolkit-preview"],
        "admin": ["admin-ndt-toolkit"]
      }
    }
  }
}
```

**Note:** Marketing target has been removed from this repo's configuration.

#### `firebase.json`
- **All targets**: Serve from `build/web/` folder (Flutter output)

---

## 🚀 Deployment Workflow

### Automatic Deployments (GitHub Actions):

When you push to any of these branches, GitHub Actions automatically builds and deploys:

| Branch | Builds | Deploys To | Domain |
|--------|--------|------------|--------|
| `main` | Flutter Web | Production | app.ndt-toolkit.com |
| `development` | Flutter Web | Preview | preview.ndt-toolkit.com |
| `admin-panel` | Flutter Web | Admin | admin.ndt-toolkit.com |

**Note:** Marketing site is deployed from a separate repository.

---

## 📝 How to Update Each Site

### Main App (app.ndt-toolkit.com):
```bash
git checkout main
# Make changes to Flutter app
git add .
git commit -m "Update main app"
git push origin main
# Automatically deploys to app.ndt-toolkit.com
```

### Preview App (preview.ndt-toolkit.com):
```bash
git checkout development
# Make changes to Flutter app
git add .
git commit -m "Test new features"
git push origin development
# Automatically deploys to preview.ndt-toolkit.com
```

### Admin Panel (admin.ndt-toolkit.com):
```bash
git checkout admin-panel
# Make changes to admin features
git add .
git commit -m "Update admin panel"
git push origin admin-panel
# Automatically deploys to admin.ndt-toolkit.com
```

---

## 🌍 DNS Configuration (GoDaddy)

### TXT Record (Root Domain Ownership):
```
Type: TXT
Name: @
Value: hosting-site=ndt-toolkit-marketing
```

**Important:** Only ONE `hosting-site=` TXT record should exist for the root domain.

### CNAME Records (Subdomains):
```
app      → ndt-toolkit.web.app.
admin    → admin-ndt-toolkit.web.app.
preview  → ndt-toolkit-preview.web.app.
```

### A Record (Root Domain):
```
@        → 199.36.158.100
```

---

## 🔍 Testing Locally

### Flutter App:
```bash
flutter run -d chrome
# Or build and serve:
flutter build web --release
cd build/web
python -m http.server 8000
```

---

## 📊 GitHub Actions Workflow

The `.github/workflows/firebase-deploy.yml` file handles all deployments:

- **Detects which branch** was pushed
- **Builds Flutter app** for web
- **Deploys to correct Firebase target** based on branch

### Secrets Required:
- `GITHUB_TOKEN` (automatically provided)
- `FIREBASE_SERVICE_ACCOUNT` (configured in repo secrets)

---

## ✅ Benefits of This Structure

1. **Marketing Independence**: Marketing site is maintained in separate repo
2. **Branch-Based Deployments**: Each branch deploys to its own domain
3. **Professional URLs**: 
   - Clean root domain for marketing
   - Subdomain for the actual app
4. **Easy Testing**: Preview changes on `preview.ndt-toolkit.com` before production
5. **Admin Separation**: Dedicated domain for admin features

---

##  Troubleshooting

### Site not updating after push?
- Check GitHub Actions tab for deployment status
- Verify branch name matches workflow triggers
- Firebase Hosting can take a few minutes to propagate

### DNS issues?
- Ensure only ONE `hosting-site=` TXT record exists for root domain
- CNAME records should end with a period: `ndt-toolkit.web.app.`
- DNS changes can take up to 48 hours to propagate

### Build failures?
- Check GitHub Actions logs
- Ensure Flutter dependencies are up to date
- Verify `firebase.json` targets are correct

---

## 📅 Created: February 13, 2026

This structure allows for independent development of marketing content while keeping the app deployment pipeline intact.
