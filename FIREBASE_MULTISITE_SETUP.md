# Firebase Multi-Site Hosting Setup Guide

## Step-by-Step Instructions

### 1. Open Firebase Console
1. Go to https://console.firebase.google.com
2. Select your **ndt-toolkit** project
3. Click **Hosting** in the left sidebar

### 2. Add Preview Site
1. Click **"Add another site"** button
2. Enter site ID: `ndt-toolkit-preview`
3. Click **"Add site"**
4. Wait for confirmation that the site was created

### 3. Add Admin Site
1. Click **"Add another site"** button again
2. Enter site ID: `admin-ndt-toolkit`
3. Click **"Add site"**
4. Wait for confirmation

### 4. Verify Sites Created
You should now see three sites listed in Firebase Hosting:
- ✅ `ndt-toolkit` (your existing production site)
- ✅ `ndt-toolkit-preview` (new - for development branch)
- ✅ `admin-ndt-toolkit` (new - for admin panel branch)

Each site will have its own URL:
- Production: `https://ndt-toolkit.web.app` and `https://ndt-toolkit.firebaseapp.com`
- Preview: `https://ndt-toolkit-preview.web.app` and `https://ndt-toolkit-preview.firebaseapp.com`
- Admin: `https://admin-ndt-toolkit.web.app` and `https://admin-ndt-toolkit.firebaseapp.com`

---

## After Creating Sites in Console

Come back and let me know when you've created the sites. We'll then:
1. Apply the targets locally with Firebase CLI
2. Test a deployment to the preview site
3. Verify everything works correctly

---

## What We Just Configured

### `.firebaserc`
Added hosting targets that map friendly names to Firebase site IDs:
- `production` → `ndt-toolkit`
- `preview` → `ndt-toolkit-preview`
- `admin` → `admin-ndt-toolkit`

### `firebase.json`
Changed from single hosting configuration to array of three configurations:
- Each target uses the same build output (`build/web`)
- Each has identical rewrites for Flutter web routing
- Separate targets allow independent deployments

This enables us to deploy different branches to different sites while maintaining the same configuration.
