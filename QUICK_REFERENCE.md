# 🚀 Quick Reference - Domain & Deployment

## 🌐 Live Sites

| URL | Description | Deploy From |
|-----|-------------|-------------|
| https://ndt-toolkit.com | Marketing Site | `marketing` branch |
| https://app.ndt-toolkit.com | Main App (Production) | `main` branch |
| https://preview.ndt-toolkit.com | Preview/Testing | `development` branch |
| https://admin.ndt-toolkit.com | Admin Panel | `admin-panel` branch |

## 📝 Quick Commands

### Update Marketing Site
```bash
git checkout marketing
# Edit files in web_marketing/
git add .
git commit -m "Your message"
git push
```

### Update Main App
```bash
git checkout main
# Edit Flutter code
git add .
git commit -m "Your message"
git push
```

### Test Changes First
```bash
git checkout development
# Make changes
git add .
git commit -m "Testing new feature"
git push
# Visit https://preview.ndt-toolkit.com to test
```

## 🔄 Workflow

1. **Develop** → Push to `development` → Test at preview.ndt-toolkit.com
2. **Ready?** → Merge to `main` → Auto-deploys to app.ndt-toolkit.com
3. **Marketing** → Push to `marketing` → Auto-deploys to ndt-toolkit.com

## 📚 Full Documentation

See `DOMAIN_RESTRUCTURE.md` for complete details on:
- Firebase configuration
- DNS setup
- GitHub Actions workflow
- Troubleshooting

## ✅ Current Status

- ✅ DNS configured
- ✅ Firebase hosting sites created
- ✅ GitHub Actions workflow updated
- ✅ Marketing branch created
- ✅ All branches deploy automatically

**Everything is ready to go!**
