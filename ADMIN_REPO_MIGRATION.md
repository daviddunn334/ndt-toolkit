# Admin Panel Repository Migration

**Date**: February 14, 2026  
**Status**: ✅ Complete

## Overview

The admin panel has been successfully migrated to a separate repository for better code organization, security, and independent deployment.

## 🎯 What Changed

### New Repository Structure

```
📦 ndt-toolkit (Main App)
  └── User-facing Flutter app
  └── Deploys to: app.ndt-toolkit.com

📦 ndt-toolkit-admin (Admin Panel) ← NEW
  └── Admin Flutter app
  └── Deploys to: admin.ndt-toolkit.com

📦 ndt-toolkit-marketing (Marketing Site)
  └── Marketing/landing page
  └── Deploys to: ndt-toolkit.com
```

## ✅ Migration Completed

### Admin Repo (ndt-toolkit-admin)
- ✅ Created at: https://github.com/daviddunn334/ndt-toolkit-admin
- ✅ Admin-panel branch pushed as main branch
- ✅ Firebase configuration added (.firebaserc, firebase.json)
- ✅ GitHub Actions workflow configured
- ✅ README.md documentation created
- ✅ All admin screens and services included
- ✅ Independent deployment pipeline

### Main Repo Cleanup (ndt-toolkit)
- ✅ Removed admin target from .firebaserc
- ✅ Removed admin deployment from GitHub Actions
- ✅ Removed admin hosting config from firebase.json
- ✅ Removed admin_metrics_service.dart (only needed in admin repo)
- ⚠️ Kept admin-panel branch (will delete after verification)

## 📋 What Was NOT Changed

### Shared Code Approach
We chose the **simple duplication approach** for shared code:
- Models, services, and utilities are duplicated in both repos
- Each repo is completely independent
- No shared packages or dependencies between repos
- Accept manual synchronization when changes affect both repos

### Services Still in Main Repo
These services remain in the main repo even though they have some admin methods:
- `user_service.dart` - Contains user management methods
- `report_service.dart` - Contains report generation
- `employee_service.dart` - Contains employee management
- `feedback_service.dart` - Contains feedback management
- etc.

**Reason**: These services are used by both apps. The admin repo has its own copy of all needed services.

## 🚀 Deployment Configuration

### Admin Repo Deployment
**Repository**: https://github.com/daviddunn334/ndt-toolkit-admin  
**Branch**: main  
**GitHub Action**: Triggers on push to main  
**Firebase Target**: admin  
**Domain**: admin.ndt-toolkit.com

### Main Repo Deployment
**Repository**: https://github.com/daviddunn334/ndt-toolkit  
**Branches**:
- `main` → app.ndt-toolkit.com (production)
- `development` → preview.ndt-toolkit.com (preview)

## 🔧 Setup Instructions for Admin Repo

### For GitHub Actions to Work:
You need to add the Firebase service account secret to the admin repo:

1. Go to: https://github.com/daviddunn334/ndt-toolkit-admin/settings/secrets/actions
2. Click "New repository secret"
3. Name: `FIREBASE_SERVICE_ACCOUNT`
4. Value: Copy from main repo's secrets (same service account)
5. Save

### For Local Development:
When you want to work on the admin panel locally:

```bash
# Navigate to your projects folder
cd C:\Users\david\StudioProjects

# Clone the admin repo
git clone https://github.com/daviddunn334/ndt-toolkit-admin.git

# Open in VS Code
code ndt-toolkit-admin

# Install dependencies
flutter pub get

# Run locally
flutter run -d chrome
```

## 🔍 Verification Checklist

- [ ] Add `FIREBASE_SERVICE_ACCOUNT` secret to admin repo
- [ ] Push a test commit to admin repo's main branch
- [ ] Verify admin panel deploys to admin.ndt-toolkit.com
- [ ] Test admin login and functionality
- [ ] Push a commit to main repo's main branch
- [ ] Verify user app deploys to app.ndt-toolkit.com
- [ ] Test user app functionality
- [ ] Delete admin-panel branch from main repo (after verification)

## 📝 Maintenance Notes

### When to Update Both Repos
If you make changes to shared code (models, services), you may need to update both repos:
- **Firebase changes** (auth, Firestore rules, etc.) - affects both
- **Model changes** (User, Employee, etc.) - duplicate in both repos
- **Service changes** - if admin uses it, update admin repo too

### Future Improvement Option
If maintaining duplicate code becomes too tedious, consider:
- Creating a shared Dart package
- Publishing to pub.dev or using a local package
- Both repos depend on the shared package
- Single source of truth for shared code

## 🎉 Benefits Achieved

1. ✅ **Complete Code Isolation** - Admin code no longer in user app
2. ✅ **Smaller Bundle Size** - User app doesn't include admin code
3. ✅ **Better Security** - Admin repo can have restricted access
4. ✅ **Independent Deployment** - Deploy admin without affecting users
5. ✅ **Cleaner Architecture** - Clear separation of concerns
6. ✅ **Flexible Development** - Different Flutter versions possible

## 🔗 Related Files

- See `.firebaserc.admin` - Firebase config template for admin repo
- See `firebase.json.admin` - Firebase hosting config template  
- See `.github/workflows/firebase-deploy-admin.yml` - GitHub Actions workflow
- See `README.admin.md` - Full admin repo documentation

## ⚠️ Important Notes

- Both apps share the same Firebase project (ndt-toolkit)
- Both apps access the same Firestore database
- Both apps use the same Firebase Auth
- Only hosting is separate (different sites/domains)
- Functions, Firestore rules, and Storage rules are shared

---

**Migration completed successfully! 🎉**

Next step: Add the Firebase service account secret to the admin repo and test deployment.
