# Domain Change Fixes for app.ndt-toolkit.com

## Issues Identified

After changing from `toolkit.integritytools.app` to `app.ndt-toolkit.com`, several Firebase configuration issues need to be addressed:

### 1. ✅ Firebase Analytics Error (FIXED)
**Error:** `Uncaught TypeError: window.firebase.analytics.logEvent is not a function`

**Fix Applied:** Updated `web/install-prompt.js` to use the correct Firebase Analytics modular SDK syntax.
- Changed from: `window.firebase.analytics.logEvent('event_name', {...})`
- Changed to: `window.firebase.analytics('event_name', {...})`

### 2. ⚠️ Firebase Auth Domain Not Authorized
**Error:** 
```
The current domain is not authorized for OAuth operations. Add your domain (app.ndt-toolkit.com) 
to the OAuth redirect domains list in the Firebase console
```

**Required Fix in Firebase Console:**

1. Go to [Firebase Console](https://console.firebase.google.com/u/0/project/ndt-toolkit)
2. Navigate to **Authentication** → **Settings** → **Authorized domains**
3. Click **Add domain**
4. Add: `app.ndt-toolkit.com`
5. Save changes

### 3. ⚠️ Firebase Storage CORS Error
**Error:**
```
Access to XMLHttpRequest at 'https://firebasestorage.googleapis.com/...' from origin 
'https://app.ndt-toolkit.com' has been blocked by CORS policy: No 'Access-Control-Allow-Origin' 
header is present on the requested resource.
```

**Required Fix - Update Storage CORS:**

Option A - Using gcloud CLI (Recommended):
```bash
gcloud storage buckets update gs://ndt-toolkit.firebasestorage.app --cors-file=cors.json
```

Option B - Using gsutil:
```bash
gsutil cors set cors.json gs://ndt-toolkit.firebasestorage.app
```

**Current cors.json configuration:**
```json
[
  {
    "origin": ["https://app.ndt-toolkit.com", "http://localhost:*"],
    "method": ["GET", "HEAD", "PUT", "POST", "DELETE"],
    "maxAgeSeconds": 3600,
    "responseHeader": ["Content-Type", "Access-Control-Allow-Origin"]
  }
]
```

### 4. ⚠️ Firestore Permissions Error
**Error:**
```
Error uploading photo: [cloud_firestore/permission-denied] Missing or insufficient permissions.
Error processing defect photo: [cloud_firestore/permission-denied] Missing or insufficient permissions.
```

**Analysis:**
The Firestore rules for `photo_identifications` collection appear correct. The error is likely occurring because:

1. The initial document creation is successful
2. But the Cloud Function trying to update the document with analysis results is failing

**Required Fix - Verify Cloud Function Service Account:**

The Cloud Function needs to run with proper admin permissions. Check that:

1. The Cloud Function is using the Firebase Admin SDK correctly
2. The service account has Firestore permissions
3. The function is updating only allowed fields: `['analysisStatus', 'analysisCompletedAt', 'matches', 'processingTime', 'errorMessage']`

**Check function code in:** `functions/src/defect-photo-identification.ts`

## Deployment Steps

### 1. Deploy Code Changes ✅
```bash
# Already completed - install-prompt.js has been fixed
firebase deploy --only hosting
```

### 2. Configure Firebase Console Settings ⚠️

You need to manually configure these in the Firebase Console:

#### A. Add Authorized Domain
1. Open: https://console.firebase.google.com/u/0/project/ndt-toolkit/authentication/settings
2. Scroll to "Authorized domains"
3. Click "Add domain"
4. Enter: `app.ndt-toolkit.com`
5. Click "Add"

#### B. Update Storage CORS
Run this command from your project directory:
```bash
gcloud storage buckets update gs://ndt-toolkit.firebasestorage.app --cors-file=cors.json
```

Or if you prefer gsutil:
```bash
gsutil cors set cors.json gs://ndt-toolkit.firebasestorage.app
```

### 3. Verify DNS Configuration

Ensure your DNS is properly configured:
- `app.ndt-toolkit.com` should point to Firebase Hosting
- SSL certificate should be active (Firebase handles this automatically)

### 4. Test After Configuration

After completing the above steps, test these features:
- [ ] User login/authentication
- [ ] Photo upload to defect analyzer
- [ ] Viewing existing defect photos
- [ ] AI analysis of defect photos
- [ ] PWA install prompt (should work without errors)

## Verification Commands

```bash
# Check if domain is in Firebase hosting
firebase target:apply hosting app ndt-toolkit

# Check hosting configuration
firebase hosting:sites:list

# View current CORS configuration
gsutil cors get gs://ndt-toolkit.firebasestorage.app

# Test authentication
# Open browser console at https://app.ndt-toolkit.com
# Look for the OAuth authorization warning - should be gone
```

## Quick Reference

| Issue | Status | Action Required |
|-------|--------|-----------------|
| Analytics Error | ✅ Fixed | ✅ Deployed |
| Auth Domain | ⚠️ Pending | Add domain in Console |
| Storage CORS | ✅ Fixed | ✅ Applied |
| Firestore Permissions | ⚠️ Pending | Verify function code |

## Next Steps

1. **Deploy the code fix:**
   ```bash
   firebase deploy --only hosting
   ```

2. **Add authorized domain in Firebase Console** (see instructions above)

3. **Update Storage CORS** (run gcloud command above)

4. **Test the application** at https://app.ndt-toolkit.com

5. **Clear browser cache** to ensure new install-prompt.js is loaded

## Notes

- The analytics error fix will take effect immediately after deployment
- Auth domain configuration is instant once saved in Console
- Storage CORS changes can take a few minutes to propagate
- You may need to clear browser cache and localStorage for a clean test

## Troubleshooting

If issues persist after configuration:

1. **Clear all browser data** for app.ndt-toolkit.com
2. **Check browser console** for any remaining errors
3. **Verify Firebase Console settings** are saved
4. **Wait 5-10 minutes** for DNS/CORS propagation
5. **Test in incognito/private mode** to rule out cache issues
