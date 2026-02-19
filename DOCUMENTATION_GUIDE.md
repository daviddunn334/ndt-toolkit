# 📚 Documentation Guide

Welcome! This guide explains the documentation structure for the NDT Toolkit project.

## 📂 Where is the Documentation?

All project documentation is located in the **`documentation/`** folder.

👉 **[Start here: documentation/README.md](./documentation/README.md)**

---

## 🗂️ Documentation Structure

```
documentation/
├── README.md                    # 📖 Main documentation index (START HERE)
├── COMPREHENSIVE_OVERVIEW.md    # Complete project reference
├── DESIGN.md                    # UI/UX design system
├── DEPLOYMENT.md                # Manual deployment guide
├── LICENSE                      # Project license
│
├── setup/                       # 🚀 Initial setup guides
│   ├── FIREBASE_SETUP.md       # Firebase configuration
│   ├── DOMAIN_SETUP.md         # Multi-site hosting & domains
│   └── GITHUB_ACTIONS.md       # CI/CD automation
│
├── guides/                      # 🔧 Build & development
│   ├── BUILD_CONFIGURATION.md  # Platform builds & tooling
│   └── APP_ICONS.md            # Icon generation
│
├── features/                    # ✨ Feature documentation
│   ├── AI_INTEGRATION.md       # AI defect analysis
│   ├── VERTEX_AI_CACHING.md    # Performance optimization
│   ├── NDT_TOOLS.md            # Calculator tools
│   ├── OFFLINE_FUNCTIONALITY.md # PWA offline support
│   └── PWA_OPTIMIZATION.md     # Progressive Web App
│
├── troubleshooting/            # 🐛 Common issues & fixes
│   └── ANDROID_BUILD_FIXES.md  # Android build problems
│
└── changelog/                  # 📝 Feature history
    ├── AI_DEFECT_ANALYZER_MERGE.md
    └── ADMIN_PANEL_CLEANUP.md
```

---

## 🎯 Quick Links

### For New Developers
1. [📖 Documentation README](./documentation/README.md) - Start here!
2. [📘 Comprehensive Overview](./documentation/COMPREHENSIVE_OVERVIEW.md) - Understand the project
3. [🔧 Build Configuration](./documentation/guides/BUILD_CONFIGURATION.md) - Setup environment

### For Deployment
1. [🔥 Firebase Setup](./documentation/setup/FIREBASE_SETUP.md) - Configure Firebase
2. [🌐 Domain Setup](./documentation/setup/DOMAIN_SETUP.md) - Setup hosting domains
3. [🤖 GitHub Actions](./documentation/setup/GITHUB_ACTIONS.md) - Automated deployments

### For Troubleshooting
1. [🐛 Android Build Fixes](./documentation/troubleshooting/ANDROID_BUILD_FIXES.md) - Fix build issues

---

## 📋 What Stays in Root Directory?

Only essential project files remain in the root:

### Configuration Files
- `.firebaserc` - Firebase project configuration
- `firebase.json` - Firebase hosting configuration
- `pubspec.yaml` - Flutter dependencies
- `.gitignore` - Git ignore rules

### Quick Reference
- **`QUICK_REFERENCE.md`** - Quick commands & URLs (handy!)
- **`DOCUMENTATION_GUIDE.md`** - This file

### Build Scripts
- `deploy.bat` / `deploy.sh` - Deployment scripts
- `*.ps1` - PowerShell utilities

---

## 🧹 What Was Cleaned Up?

The following outdated/duplicate files were **removed** from root and consolidated into `documentation/`:

### Moved to `documentation/setup/`
- ✅ `FIREBASE_MULTISITE_SETUP.md`
- ✅ `GITHUB_ACTIONS_SETUP.md`
- ✅ `SERVICE_ACCOUNT_INSTRUCTIONS.md`
- ✅ `CUSTOM_DOMAIN_SETUP.md`
- ✅ `DOMAIN_RESTRUCTURE.md`

### Moved to `documentation/guides/`
- ✅ `FINAL_BUILD_CONFIGURATION.md`

### Moved to `documentation/troubleshooting/`
- ✅ `ANDROID_BUILD_FIX_COMMANDS.md`
- ✅ `FIX_JAVA24_ISSUE.md`
- ✅ `INSTALL_JAVA17_FIX.md`
- ✅ `DOMAIN_CHANGE_FIXES.md`
- ✅ `DEFECT_PHOTO_ANALYTICS_FIXES.md`

### Moved to `documentation/changelog/`
- ✅ `AI_DEFECT_ANALYZER_MERGE.md`
- ✅ `ADMIN_CLEANUP_SUMMARY.md`

### Removed (outdated/completed)
- ❌ `CLEANUP_READY_FOR_REVIEW.md` - Task completed
- ❌ `DEPLOYMENT_SUMMARY.md` - Info consolidated elsewhere
- ❌ `NEXT_STEPS.md` - Outdated steps list

---

## 🎨 Benefits of New Structure

### ✅ Organized
- Clear categorization (setup, features, troubleshooting)
- Easy to find what you need
- Logical folder structure

### ✅ Consolidated
- Related documents combined
- Eliminated duplicates
- Single source of truth

### ✅ Maintainable
- Clear ownership of docs
- Easy to update
- Version dates tracked

### ✅ Discoverable
- Main README as entry point
- Cross-references between docs
- Quick links for common tasks

---

## 📝 Updating Documentation

When making changes:

1. **Update relevant file** in `documentation/` folder
2. **Update dates** at bottom of modified files
3. **Add to changelog** if it's a significant change
4. **Update main README** if structure changes

---

## 🚀 Ready to Go?

Head to **[documentation/README.md](./documentation/README.md)** to get started!

---

**Documentation reorganized:** February 19, 2026
