# Firebase Service Account Setup - Manual Method

The Firebase CLI automatic setup encountered an error. Follow these manual steps instead:

## Step 1: Enable Required APIs in Google Cloud

1. Go to https://console.cloud.google.com/apis/dashboard?project=ndt-toolkit
2. Click **+ ENABLE APIS AND SERVICES**
3. Search for and enable:
   - **Service Account Credentials API**
   - **Identity and Access Management (IAM) API**

## Step 2: Generate Service Account Key

### Option A: Via Firebase Console (Recommended)
1. Go to https://console.firebase.google.com/project/ndt-toolkit/settings/serviceaccounts/adminsdk
2. Click **Generate new private key** button
3. Click **Generate key** in the confirmation dialog
4. Save the downloaded JSON file securely (e.g., `Downloads/ndt-toolkit-firebase-key.json`)
5. ⚠️ **Do NOT commit this file to git**

### Option B: Via Google Cloud Console
1. Go to https://console.cloud.google.com/iam-admin/serviceaccounts?project=ndt-toolkit
2. Click **+ CREATE SERVICE ACCOUNT**
3. Name: `github-actions-deployer`
4. Description: `Service account for GitHub Actions Firebase deployments`
5. Click **CREATE AND CONTINUE**
6. Grant roles:
   - **Firebase Hosting Admin**
   - **Service Account User**
7. Click **CONTINUE** then **DONE**
8. Click on the newly created service account
9. Go to **KEYS** tab
10. Click **ADD KEY** → **Create new key**
11. Select **JSON** format
12. Click **CREATE**
13. Save the downloaded JSON file

## Step 3: Add Secret to GitHub

1. Open the JSON file you downloaded
2. Copy the **entire contents** (should start with `{` and end with `}`)
3. Go to https://github.com/daviddunn334/ndt-toolkit/settings/secrets/actions
4. Click **New repository secret**
5. Name: `FIREBASE_SERVICE_ACCOUNT`
6. Value: Paste the entire JSON content
7. Click **Add secret**

## Step 4: Verify Secret Added

1. Go to https://github.com/daviddunn334/ndt-toolkit/settings/secrets/actions
2. You should see `FIREBASE_SERVICE_ACCOUNT` listed
3. If you see it, the secret was added successfully ✅

## Step 5: Commit and Push Workflow

Once the secret is added, commit and push the workflow file:

```bash
git status
git add .
git commit -m "Set up Firebase multi-site hosting and GitHub Actions automation"
git push origin development
```

## Step 6: Monitor First Deployment

1. Go to https://github.com/daviddunn334/ndt-toolkit/actions
2. You should see a workflow run triggered by your push
3. Click on it to view the deployment progress
4. If successful, check https://ndt-toolkit-preview.web.app

---

## What to Do After Adding the Secret

**IMMEDIATELY DELETE THE JSON FILE FROM YOUR COMPUTER**
- The key is now safely stored in GitHub Secrets
- You don't need the local file anymore
- Keeping it around is a security risk

```bash
# If on Windows
del C:\Users\david\Downloads\ndt-toolkit-firebase-key.json

# Or right-click and delete it manually
```

---

**Ready?** Let me know when you've added the secret to GitHub, and I'll help you commit and push the changes!
