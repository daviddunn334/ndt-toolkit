# NDT Toolkit Documentation

Welcome to the NDT Toolkit documentation! This guide will help you understand, develop, and deploy the NDT Toolkit application.

## 📚 Documentation Structure

### 🚀 [Setup Guides](./setup/)
Initial configuration and deployment setup:
- **[Firebase Setup](./setup/FIREBASE_SETUP.md)** - Configure all Firebase services
- **[Domain Setup](./setup/DOMAIN_SETUP.md)** - Multi-site hosting and custom domains
- **[GitHub Actions](./setup/GITHUB_ACTIONS.md)** - Automated CI/CD deployment

### 🔧 [Build & Development](./guides/)
Building and configuring the application:
- **[Build Configuration](./guides/BUILD_CONFIGURATION.md)** - Platform builds and tooling
- **[App Icons Guide](./guides/APP_ICONS.md)** - Icon generation and configuration

### ✨ [Features](./features/)
Detailed feature documentation:
- **[AI Integration](./features/AI_INTEGRATION.md)** - Defect analysis AI features
- **[Vertex AI Caching](./features/VERTEX_AI_CACHING.md)** - Performance optimization
- **[NDT Tools](./features/NDT_TOOLS.md)** - Calculator tools and recommendations
- **[Offline Functionality](./features/OFFLINE_FUNCTIONALITY.md)** - PWA offline support
- **[PWA Optimization](./features/PWA_OPTIMIZATION.md)** - Progressive Web App features

### 🐛 [Troubleshooting](./troubleshooting/)
Common issues and solutions:
- **[Android Build Fixes](./troubleshooting/ANDROID_BUILD_FIXES.md)** - Android build problems

### 📝 [Changelog](./changelog/)
Feature history and major changes:
- **[AI Defect Analyzer Merge](./changelog/AI_DEFECT_ANALYZER_MERGE.md)** - Tool consolidation
- **[Admin Panel Cleanup](./changelog/ADMIN_PANEL_CLEANUP.md)** - Code separation

### 📖 Core Documentation
- **[Comprehensive Overview](./COMPREHENSIVE_OVERVIEW.md)** - Complete project reference
- **[Design System](./DESIGN.md)** - UI/UX design patterns
- **[Deployment](./DEPLOYMENT.md)** - Manual deployment procedures
- **[LICENSE](./LICENSE)** - Project license

---

## 🎯 Quick Start

### For New Developers

1. **Read the Overview**
   - Start with [Comprehensive Overview](./COMPREHENSIVE_OVERVIEW.md)
   - Understand the project structure and architecture

2. **Setup Your Environment**
   - Follow [Build Configuration](./guides/BUILD_CONFIGURATION.md)
   - Install Flutter, Java 17, and required tools

3. **Configure Firebase**
   - Complete [Firebase Setup](./setup/FIREBASE_SETUP.md)
   - Set up authentication, database, and storage

4. **Run Locally**
   ```bash
   flutter pub get
   flutter run -d chrome
   ```

### For Deployment

1. **Configure Domains**
   - Follow [Domain Setup](./setup/DOMAIN_SETUP.md)
   - Set up DNS records

2. **Setup CI/CD**
   - Configure [GitHub Actions](./setup/GITHUB_ACTIONS.md)
   - Automatic deployments on push

3. **Deploy**
   ```bash
   # Bump version first!
   # Then push to trigger deployment
   git push origin main
   ```

---

## 🏗️ Project Overview

**NDT Toolkit** is a comprehensive mobile and web application for pipeline inspection professionals (NDT - Non-Destructive Testing).

### Key Technologies

- **Frontend:** Flutter 3.24.3+
- **Backend:** Firebase (Auth, Firestore, Storage, Functions)
- **AI:** Google Vertex AI (Gemini 2.5 Flash)
- **Hosting:** Firebase Hosting (multi-site)
- **CI/CD:** GitHub Actions

### Platform Support

- ✅ **Web** - Primary platform (Firebase Hosting)
- ✅ **Android** - Mobile app
- ✅ **iOS** - Mobile app (requires macOS for build)

---

## 🌐 Live Sites

| Site | URL | Purpose |
|------|-----|---------|
| **Marketing** | [ndt-toolkit.com](https://ndt-toolkit.com) | Landing page |
| **Production** | [app.ndt-toolkit.com](https://app.ndt-toolkit.com) | Main application |
| **Preview** | [preview.ndt-toolkit.com](https://preview.ndt-toolkit.com) | Testing environment |
| **Admin** | [admin.ndt-toolkit.com](https://admin.ndt-toolkit.com) | Admin panel |

---

## 🎨 Key Features

### NDT Calculators
- **Most Used Tools** - 8 frequently used calculators
- **NDT Tools** - 13 categories with specialized calculators
- All calculators work fully offline

### AI-Powered Analysis
- **Defect Analyzer** - AI analysis with procedure validation
- **Photo Identification** - Defect identification from photos
- **Vertex AI Caching** - 18x faster, 73-95% cost reduction

### Core Business Features
- Inspection reports with photo attachments
- Method hours tracking and export
- Knowledge base with procedures and guides
- Company directory with contact management
- News and updates system

### Progressive Web App
- Installable on all platforms
- Offline functionality
- Auto-update system
- Push notifications (future)

---

## 📂 Repository Structure

```
ndt-toolkit/
├── lib/                    # Flutter application code
│   ├── calculators/       # Calculator implementations
│   ├── models/            # Data models
│   ├── screens/           # UI screens
│   ├── services/          # Business logic
│   ├── theme/             # App theming
│   └── widgets/           # Reusable components
├── web/                   # Web-specific files
├── android/               # Android configuration
├── ios/                   # iOS configuration
├── functions/             # Cloud Functions
├── documentation/         # 📖 You are here!
└── assets/                # Images and resources
```

---

## 🔐 Important Notes

### Version Bumping

**CRITICAL:** Always bump versions before deployment:

1. **Update** `web/service-worker.js`:
   ```javascript
   const CACHE_VERSION = 'v1.0.X';
   ```

2. **Update** `pubspec.yaml`:
   ```yaml
   version: 1.0.X+Y
   ```

Without version bumps, users won't receive auto-updates!

### Security

**Never commit:**
- `android/key.properties`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- Service account JSON files
- API keys or secrets

---

## 🤝 Contributing

### Development Workflow

1. Create feature branch from `development`
2. Make changes and test locally
3. Push to trigger preview deployment
4. Test on preview.ndt-toolkit.com
5. Create PR to `main` for production

### Code Style

- Follow Flutter best practices
- Use meaningful variable names
- Comment complex logic
- Add analytics tracking for new features
- Update documentation for new features

---

## 🆘 Getting Help

### Troubleshooting

1. Check [Android Build Fixes](./troubleshooting/ANDROID_BUILD_FIXES.md)
2. Review [Comprehensive Overview](./COMPREHENSIVE_OVERVIEW.md)
3. Check Flutter doctor: `flutter doctor -v`
4. Review Firebase Console logs

### Resources

- [Flutter Documentation](https://docs.flutter.dev)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Material Design](https://m3.material.io)

### Support

- **Email:** ndt-toolkit-support@gmail.com
- **GitHub Issues:** [Report bugs](https://github.com/daviddunn334/ndt-toolkit/issues)

---

## 📊 Project Stats

- **Lines of Code:** ~50,000+
- **Screens:** 40+
- **Services:** 15+
- **Calculators:** 20+
- **Firebase Collections:** 10+
- **Cloud Functions:** 6

---

## 📅 Recent Updates

**February 2026:**
- ✅ Documentation reorganized and consolidated
- ✅ AI Defect Analyzer tools merged
- ✅ Admin panel separated from user app
- ✅ Critical Angle Calculator added
- ✅ Mode Conversion Calculator added
- ✅ Multi-site hosting configured
- ✅ GitHub Actions CI/CD implemented

---

## 📝 Documentation Maintenance

This documentation is actively maintained. When making changes:

1. Update relevant documentation files
2. Keep version dates current
3. Add new features to changelog
4. Update this README if structure changes

**Last Updated:** February 19, 2026

---

## 🚀 Ready to Start?

Choose your path:

- **New Developer?** → [Comprehensive Overview](./COMPREHENSIVE_OVERVIEW.md)
- **Setting Up Environment?** → [Build Configuration](./guides/BUILD_CONFIGURATION.md)
- **Deploying?** → [Firebase Setup](./setup/FIREBASE_SETUP.md) → [Domain Setup](./setup/DOMAIN_SETUP.md)
- **Build Issues?** → [Troubleshooting](./troubleshooting/ANDROID_BUILD_FIXES.md)

Happy coding! 🎉
