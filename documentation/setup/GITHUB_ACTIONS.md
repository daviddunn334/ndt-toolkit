# GitHub Actions CI/CD Setup

This guide covers the automated deployment setup using GitHub Actions for multi-site Firebase hosting.

## 🎯 Overview

GitHub Actions automatically deploys your app to different Firebase hosting sites based on which branch you push to:

| Branch | Deploys To | URL |
|--------|-----------|-----|
| `main` | Production | https://app.ndt-toolkit.com |
| `development` | Preview | https://preview.ndt-toolkit.com |
| `admin-panel` | Admin | https://admin.ndt-toolkit.com |
| `marketing` | Marketing | https://ndt-toolkit.com |

---

## 📋 Prerequisites

- Firebase project created (`ndt-toolkit`)
- Firebase hosting sites configured (see [Domain Setup](./DOMAIN_SETUP.md))
- GitHub repository access
- Firebase CLI installed locally

---

## 🔐 Step 1: Generate Firebase Service Account Key

### Option A: Via Firebase Console (Recommended)

1. Go to [Firebase Console](https://console.firebase.google.com/project/ndt-toolkit/settings/serviceaccounts/adminsdk)
2. Click **Generate new private key** button
3. Click **Generate key** in confirmation dialog
4. Save the downloaded JSON file securely
5. ⚠️ **NEVER commit this file to git**

### Option B: Via Google Cloud Console

1. Go to [Google Cloud IAM](https://console.cloud.google.com/iam-admin/serviceaccounts?project=ndt-toolkit)
2. Click **+ CREATE SERVICE ACCOUNT**
3. Enter details:
   - **Name:** `github-actions-deployer`
   - **Description:** `Service account for GitHub Actions Firebase deployments`
4. Click **CREATE AND CONTINUE**
5. Grant roles:
   - **Firebase Hosting Admin**
   - **Service Account User**
6. Click **CONTINUE** → **DONE**
7. Click on the newly created service account
8. Go to **KEYS** tab
9. Click **ADD KEY** → **Create new key**
10. Select **JSON** format
11. Click **CREATE**
12. Save the downloaded JSON file

### Option C: Using Firebase CLI

```bash
firebase init hosting:github
```

This automatically creates a service account and adds it to GitHub secrets.

---

## 🔑 Step 2: Add Service Account to GitHub Secrets

### Manual Method

1. Open the JSON file downloaded in Step 1
2. Copy the **entire contents** (from `{` to `}`)
3. Go to [GitHub Repository Secrets](https://github.com/daviddunn334/ndt-toolkit/settings/secrets/actions)
4. Click **New repository secret**
5. Configure:
   - **Name:** `FIREBASE_SERVICE_ACCOUNT`
   - **Value:** Paste the entire JSON content
6. Click **Add secret**

### Verify Secret Added

1. Go to [GitHub Secrets page](https://github.com/daviddunn334/ndt-toolkit/settings/secrets/actions)
2. Verify `FIREBASE_SERVICE_ACCOUNT` is listed
3. ✅ Secret successfully added

### Security: Delete Local JSON File

After adding to GitHub:

```powershell
# Windows
del C:\Users\david\Downloads\ndt-toolkit-firebase-key.json

# Or manually delete it
```

The key is now safely in GitHub Secrets - you don't need the local copy.

---

## 📝 Step 3: GitHub Actions Workflow File

The workflow file is located at `.github/workflows/firebase-deploy.yml`:

```yaml
name: Deploy to Firebase Hosting

on:
  push:
    branches:
      - main
      - development
      - admin-panel
      - marketing

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Determine deployment target
        id: target
        run: |
          if [ "${{ github.ref }}" == "refs/heads/main" ]; then
            echo "target=production" >> $GITHUB_OUTPUT
            echo "build_flutter=true" >> $GITHUB_OUTPUT
          elif [ "${{ github.ref }}" == "refs/heads/development" ]; then
            echo "target=preview" >> $GITHUB_OUTPUT
            echo "build_flutter=true" >> $GITHUB_OUTPUT
          elif [ "${{ github.ref }}" == "refs/heads/admin-panel" ]; then
            echo "target=admin" >> $GITHUB_OUTPUT
            echo "build_flutter=true" >> $GITHUB_OUTPUT
          elif [ "${{ github.ref }}" == "refs/heads/marketing" ]; then
            echo "target=marketing" >> $GITHUB_OUTPUT
            echo "build_flutter=false" >> $GITHUB_OUTPUT
          fi

      - name: Set up Flutter
        if: steps.target.outputs.build_flutter == 'true'
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.3'

      - name: Install dependencies
        if: steps.target.outputs.build_flutter == 'true'
        run: flutter pub get

      - name: Build Flutter web
        if: steps.target.outputs.build_flutter == 'true'
        run: flutter build web --release

      - name: Deploy to Firebase Hosting
        uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: '${{ secrets.GITHUB_TOKEN }}'
          firebaseServiceAccount: '${{ secrets.FIREBASE_SERVICE_ACCOUNT }}'
          projectId: ndt-toolkit
          target: ${{ steps.target.outputs.target }}
```

---

## 🚀 Step 4: Test the Workflow

### Trigger First Deployment

Since you're on the `development` branch:

```bash
# Commit and push the workflow file
git add .github/workflows/firebase-deploy.yml
git commit -m "Add GitHub Actions workflow for automated Firebase deployments"
git push origin development
```

### Monitor Deployment

1. Go to [GitHub Actions](https://github.com/daviddunn334/ndt-toolkit/actions)
2. You should see the workflow running
3. Click on it to view progress
4. Green checkmark ✅ = Success
5. Red X ❌ = Failed (check logs)

### Verify Deployment

Once complete, visit: https://preview.ndt-toolkit.com

---

## 🔄 How It Works

### Workflow Trigger

The workflow runs automatically when you push to:
- `main`
- `development`  
- `admin-panel`
- `marketing`

### Deployment Steps

1. **Checkout Code:** Clone repository
2. **Determine Target:** Based on branch name
3. **Setup Flutter:** Install Flutter SDK (skipped for marketing branch)
4. **Install Dependencies:** Run `flutter pub get`
5. **Build Web App:** Run `flutter build web --release`
6. **Deploy:** Push to appropriate Firebase hosting site

### Target Mapping

```
main branch        → production target → ndt-toolkit site
development branch → preview target    → ndt-toolkit-preview site
admin-panel branch → admin target      → admin-ndt-toolkit site
marketing branch   → marketing target  → ndt-toolkit-marketing site
```

---

## 🛠️ Workflow Customization

### Update Flutter Version

Edit `.github/workflows/firebase-deploy.yml`:

```yaml
- name: Set up Flutter
  uses: subosito/flutter-action@v2
  with:
    flutter-version: '3.24.3'  # Change this version
```

### Add New Branch

Add branch to trigger list:

```yaml
on:
  push:
    branches:
      - main
      - development
      - admin-panel
      - marketing
      - your-new-branch  # Add here
```

Then add target mapping in "Determine deployment target" step.

### Skip CI for Certain Commits

Add `[skip ci]` to commit message:

```bash
git commit -m "Update README [skip ci]"
```

---

## 📊 Monitoring Deployments

### GitHub Actions Dashboard

View all deployments:
- [Actions tab](https://github.com/daviddunn334/ndt-toolkit/actions)
- See status, logs, and timing for each deployment

### Firebase Hosting Dashboard

View deployed versions:
- [Firebase Hosting Console](https://console.firebase.google.com/project/ndt-toolkit/hosting/sites)
- See deployment history and rollback if needed

---

## 🆘 Troubleshooting

### Workflow Fails to Start

**Issue:** Workflow doesn't trigger on push

**Solutions:**
- Verify workflow file is in `.github/workflows/` directory
- Check YAML syntax is valid
- Ensure you pushed to a monitored branch

### Secret Not Found Error

**Issue:** `Error: FIREBASE_SERVICE_ACCOUNT secret not found`

**Solutions:**
- Verify secret is added to GitHub repository secrets
- Secret name must be exactly: `FIREBASE_SERVICE_ACCOUNT`
- Secret must contain valid JSON

### Build Fails

**Issue:** Flutter build fails during workflow

**Solutions:**
- Check Flutter version matches your local version
- Verify `pubspec.yaml` dependencies are valid
- Review build logs in GitHub Actions for specific errors
- Test build locally: `flutter build web --release`

### Deploy Fails

**Issue:** Firebase deployment fails

**Solutions:**
- Verify Firebase service account has correct permissions
- Check that hosting target exists in Firebase Console
- Ensure `.firebaserc` targets are configured correctly
- Verify `firebase.json` has the target defined

### Wrong Site Deployed

**Issue:** Code deploys to wrong Firebase hosting site

**Solutions:**
- Verify branch-to-target mapping in workflow file
- Check `.firebaserc` target configuration
- Confirm you pushed to the correct branch

---

## 🔒 Security Best Practices

### Service Account Key

- ✅ Store only in GitHub Secrets
- ❌ Never commit to git
- ❌ Never share publicly
- ✅ Delete local copy after adding to GitHub
- ✅ Rotate keys periodically (every 90 days)

### Repository Access

- Limit who has write access to repository
- Require PR reviews for main branches
- Use branch protection rules

### Workflow Permissions

Service account should have minimum required permissions:
- Firebase Hosting Admin (for deployments)
- Service Account User (to run as service account)

---

## 📈 Advanced Features

### Deploy Previews for Pull Requests

Add PR preview deployments:

```yaml
on:
  pull_request:
    branches:
      - main

jobs:
  preview:
    runs-on: ubuntu-latest
    steps:
      # ... build steps ...
      - uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: '${{ secrets.GITHUB_TOKEN }}'
          firebaseServiceAccount: '${{ secrets.FIREBASE_SERVICE_ACCOUNT }}'
          projectId: ndt-toolkit
          expires: 7d  # Preview expires in 7 days
```

### Deployment Notifications

Add Slack/Discord notifications on deployment:

```yaml
- name: Notify on success
  if: success()
  run: |
    curl -X POST ${{ secrets.SLACK_WEBHOOK_URL }} \
      -H 'Content-Type: application/json' \
      -d '{"text":"Deployed to ${{ steps.target.outputs.target }}!"}'
```

---

## 📚 Related Documentation

- [Domain Setup](./DOMAIN_SETUP.md) - Configure custom domains
- [Getting Started](./GETTING_STARTED.md) - Initial project setup
- [Deployment Guide](../DEPLOYMENT.md) - Manual deployment procedures

---

## 📝 Quick Commands Reference

```bash
# View workflow runs
gh run list

# View specific run details
gh run view [run-id]

# Manually trigger workflow (if configured)
gh workflow run firebase-deploy.yml

# Check workflow status
gh run watch
```

---

**Last Updated:** February 19, 2026
