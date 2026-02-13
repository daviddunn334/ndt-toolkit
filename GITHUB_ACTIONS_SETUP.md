# GitHub Actions Setup Guide

## Step 1: Generate Firebase Service Account Key

### Via Firebase Console
1. Go to https://console.firebase.google.com
2. Select your **ndt-toolkit** project
3. Click the gear icon ⚙️ next to "Project Overview" → **Project settings**
4. Go to **Service accounts** tab
5. Click **Generate new private key**
6. Confirm by clicking **Generate key**
7. A JSON file will download - **keep this secure!**

### Via Firebase CLI (Alternative)
```bash
firebase init hosting:github
```
This will automatically create a service account and add it to your GitHub repository secrets.

## Step 2: Add Service Account to GitHub Secrets

### Manual Method
1. Go to https://github.com/daviddunn334/ndt-toolkit
2. Click **Settings** tab
3. In left sidebar, click **Secrets and variables** → **Actions**
4. Click **New repository secret**
5. Name: `FIREBASE_SERVICE_ACCOUNT`
6. Value: Paste the **entire contents** of the JSON file from Step 1
7. Click **Add secret**

### Using Firebase CLI (Automatic)
```bash
firebase init hosting:github
```
Follow the prompts:
- Select your repository: `daviddunn334/ndt-toolkit`
- Authorize with GitHub
- It will automatically add the secret

## Step 3: Verify the Workflow

### Test on Development Branch
Since you're currently on the `development` branch, any commit will trigger the workflow.

1. Commit the new workflow file:
```bash
git add .github/workflows/firebase-deploy.yml
git commit -m "Add GitHub Actions workflow for automated Firebase deployments"
git push origin development
```

2. Go to GitHub Actions:
   - https://github.com/daviddunn334/ndt-toolkit/actions
   - You should see the workflow running
   - It will build and deploy to the preview site

### Monitor the Workflow
- Green checkmark ✅ = Success
- Red X ❌ = Failed (check logs for errors)

## How It Works

### Automated Deployments
- **Push to `main`** → Deploys to production (`ndt-toolkit.web.app`)
- **Push to `development`** → Deploys to preview (`ndt-toolkit-preview.web.app`)
- **Push to `admin-panel`** → Deploys to admin (`admin-ndt-toolkit.web.app`)

### What the Workflow Does
1. Checks out code from the branch
2. Sets up Flutter (v3.24.3)
3. Installs dependencies (`flutter pub get`)
4. Builds web app (`flutter build web --release`)
5. Deploys to the appropriate Firebase site based on branch

## Troubleshooting

### Workflow Fails to Start
- Check that `FIREBASE_SERVICE_ACCOUNT` secret is added
- Verify the secret contains valid JSON

### Build Fails
- Check Flutter version matches (3.24.3)
- Review build logs in GitHub Actions

### Deploy Fails
- Verify Firebase service account has correct permissions
- Check that hosting targets exist in Firebase Console

## Security Notes
- ⚠️ **Never commit the service account JSON file to git**
- ✅ Keep it in GitHub Secrets only
- ✅ The secret is encrypted and only accessible during workflow execution

---

**Next Step:** Run the Firebase CLI command or manually add the secret, then commit and push the workflow file.
