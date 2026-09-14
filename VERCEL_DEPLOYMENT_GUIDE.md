# 🚀 Deploying CarLink to Vercel

This guide provides step-by-step instructions for deploying your **CarLink Flutter Web** application to **Vercel**.

---

## ⚡ Method 1: Deploy with Vercel CLI (Quickest)

If you have the [Vercel CLI](https://vercel.com/docs/cli) installed:

### 1. Build the Web App
Run the build script or flutter build command:
```bash
# On Windows
build-web.bat

# Or using flutter directly
flutter build web --release --no-tree-shake-icons
```

### 2. Deploy to Vercel
```bash
vercel --prod
```
When prompted:
- **Set up and deploy?** `Y`
- **Which scope?** (Select your personal or team account)
- **Link to existing project?** `N` (or `Y` if updating an existing project)
- **What's your project's name?** `carlink`
- **In which directory is your code located?** `./`
- **Want to modify these settings?** `N` (it will use `vercel.json`)

Vercel will upload the pre-built `build/web` folder and return your live production URL!

---

## 🌐 Method 2: Deploy via Vercel Dashboard (Git Integration)

When you push your code to **GitHub**, **GitLab**, or **Bitbucket**:

1. Log in to [vercel.com](https://vercel.com).
2. Click **"Add New..."** > **"Project"**.
3. Import your `carlink` repository.
4. Under **Build and Output Settings**:
   - **Framework Preset**: `Other`
   - **Build Command**: `bash vercel-build.sh` (or toggle override and enter `npm run vercel-build`)
   - **Output Directory**: `build/web`
5. Click **"Deploy"**.

> [!NOTE]
> Vercel's build environment will automatically execute `vercel-build.sh`, which installs the Flutter SDK, fetches dependencies, and compiles the production web bundle.

---

## 🤖 Method 3: Deploy via GitHub Actions CI/CD (Recommended for Teams)

A pre-configured GitHub Actions workflow is included at [`.github/workflows/deploy-vercel.yml`](.github/workflows/deploy-vercel.yml).

### Steps to activate:
1. Go to your GitHub repository > **Settings** > **Secrets and variables** > **Actions**.
2. Add three repository secrets:
   - `VERCEL_TOKEN`: Your Vercel Personal Access Token (from [Vercel Account Settings > Tokens](https://vercel.com/account/tokens)).
   - `VERCEL_ORG_ID`: Found in your Vercel project settings or `.vercel/project.json`.
   - `VERCEL_PROJECT_ID`: Found in your Vercel project settings or `.vercel/project.json`.
3. Every time you push to `main` or `master`, GitHub Actions will:
   - Install Flutter
   - Build the web release
   - Deploy directly to Vercel production!

---

## ⚙️ Project Configuration Files Explained

| File | Purpose |
|------|---------|
| [`vercel.json`](vercel.json) | Vercel deployment configuration, SPA URL rewrites (`index.html`), backend API proxying, and caching headers. |
| [`package.json`](package.json) | NPM scripts for Vercel build detection (`npm run build`, `npm run vercel-build`). |
| [`vercel-build.sh`](vercel-build.sh) | Automated Linux build script to download Flutter and build web on Vercel runners. |
| [`.vercelignore`](.vercelignore) | Prevents uploading unnecessary Android, iOS, and desktop files to Vercel. |
| [`build-web.bat`](build-web.bat) | One-click Windows build script for local compilation. |
| [`web/index.html`](web/index.html) | Modern branded loading screen matching the CarLink design system (`#1347FF`). |
| [`web/manifest.json`](web/manifest.json) | Web app metadata, theme color, and PWA settings. |

---

## 🗺️ Google Maps on Web
The Google Maps JavaScript API script is already enabled in [`web/index.html`](web/index.html):
```html
<script src="https://maps.googleapis.com/maps/api/js"></script>
```
For production, append your Google Cloud Maps API key:
```html
<script src="https://maps.googleapis.com/maps/api/js?key=YOUR_GOOGLE_MAPS_API_KEY"></script>
```

---

## 🔑 Essential Environment Keys Needed

See [`.env.example`](.env.example) for the complete reference.

| Key | Where Configured | Description |
|-----|------------------|-------------|
| `GOOGLE_MAPS_API_KEY` | `web/index.html`, `android/.../AndroidManifest.xml`, `ios/.../AppDelegate.swift` | Powers Google Maps interactive rendering, car markers, and geocoding. |
| `BASE_URL` | `lib/utils/config.dart` (`Config.baseUrl`) | Your CarLink backend API endpoint (default: `https://carlink.cscodetech.cloud/api/`). |
| `PAYSTACK_PUBLIC_KEY` | `lib/payments/paystack.dart` | Public key for live Nigerian card processing (`pk_live_...` or `pk_test_...`). |
| `PAYSTACK_SECRET_KEY` | Admin backend / server environment | Secret key for webhook signature verification and server-to-server transaction verification. |
| `VERCEL_TOKEN` | GitHub Secrets (CI/CD only) | Personal Access Token from Vercel Account Settings for automated deployments. |
| `VERCEL_ORG_ID` | GitHub Secrets (CI/CD only) | Vercel Organization / Team ID. |
| `VERCEL_PROJECT_ID` | GitHub Secrets (CI/CD only) | Vercel Project ID. |
