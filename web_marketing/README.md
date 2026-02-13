# NDT Toolkit Marketing Site

This is the marketing/landing page for NDT Toolkit, hosted at **ndt-toolkit.com** (root domain).

## Structure

- `index.html` - Main landing page
- `styles.css` - Styling
- Additional pages and assets can be added here

## Deployment

This site is automatically deployed when pushing to the `marketing` branch.

```bash
git checkout marketing
# Make your changes
git add .
git commit -m "Update marketing site"
git push origin marketing
```

The GitHub Actions workflow will automatically deploy to Firebase Hosting at ndt-toolkit.com.

## Local Testing

You can test locally with any HTTP server:

```bash
# Using Python
python -m http.server 8000

# Using Node.js http-server
npx http-server

# Using PHP
php -S localhost:8000
```

Then visit http://localhost:8000

## Links to App

The main app is hosted at: https://app.ndt-toolkit.com
