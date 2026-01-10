# Google Play Store Deployment Guide for Apex App

This guide provides step-by-step instructions for deploying the Apex mobile app to the Google Play Store.

## App Overview

- **App Name**: Apex
- **Description**: Apex Mobile App
- **Package Name**: com.example.agrovets (Note: Change to a unique package name before deployment)
- **Version**: 1.0.0+1
- **Permissions**: Camera (for barcode scanning)

## Prerequisites

Before starting the deployment process, ensure you have the following:

1. **Google Play Console Account**
   - Visit [Google Play Console](https://play.google.com/console/)
   - Sign in with a Google account
   - Pay the one-time registration fee of $25 (USD)

2. **Development Environment**
   - Flutter SDK installed (version >=3.0.0)
   - Android Studio or JDK 8+ for building Android apps
   - Git for version control

3. **App Assets**
   - High-resolution app icon (512x512 PNG)
   - Screenshots (at least 2, up to 8 per device type)
   - Feature graphic (1024x500 PNG)
   - Privacy policy URL

## Preparing the App for Deployment

### 1. Update Package Name

The current package name `com.example.agrovets` is a placeholder. Change it to a unique identifier:

1. Update `android/app/build.gradle`:
   ```gradle
   android {
       namespace = "com.yourcompany.apex"
       defaultConfig {
           applicationId = "com.yourcompany.apex"
       }
   }
   ```

2. Update `android/app/src/main/AndroidManifest.xml` if needed.

3. Update any references in the code.

### 2. Create a Privacy Policy

Since the app uses camera permission, you need a privacy policy:

1. Create a privacy policy document explaining data collection and usage
2. Host it on your website or use a service like [Privacy Policy Generator](https://www.privacypolicygenerator.info/)
3. Note the URL for Play Console

### 3. Prepare App Assets

- **App Icon**: Ensure `assets/images/logo.png` is 512x512 pixels
- **Screenshots**: Capture screenshots showing key features (login, dashboard, sales, etc.)
- **Feature Graphic**: Create a 1024x500 banner image

## Building the Release Version

### 1. Create a Signing Key

Generate a keystore for signing the app:

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Store the keystore file securely and remember the password.

### 2. Configure Signing in Gradle

Update `android/app/build.gradle`:

```gradle
android {
    // ... existing code ...

    signingConfigs {
        release {
            keyAlias 'upload'
            keyPassword 'your_key_password'
            storeFile file('path/to/upload-keystore.jks')
            storePassword 'your_store_password'
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### 3. Build the App Bundle

Run the following command to build the release version:

```bash
flutter build appbundle --release
```

This creates `build/app/outputs/bundle/release/app-release.aab`

## Google Play Console Setup

### 1. Create a New App

1. Log in to Google Play Console
2. Click "Create app"
3. Fill in:
   - App name: Apex
   - Default language: English (en-US)
   - App type: App (not game)
   - Free or paid: Free (or Paid if applicable)

### 2. App Details

1. **Main store listing**
   - Short description (80 characters max)
   - Full description (4000 characters max)
   - Screenshots (upload 2-8 per device type)
   - Icon (512x512 PNG)
   - Feature graphic (1024x500 PNG)

2. **Categorization**
   - Category: Business or Productivity
   - Content rating: Complete the questionnaire

3. **Contact details**
   - Email address
   - Phone number (optional)

4. **Privacy policy**
   - Enter the URL of your privacy policy

### 3. Content Rating

Complete the content rating questionnaire to determine your app's maturity rating.

## Uploading and Publishing

### 1. Upload App Bundle

1. Go to "Production" > "Create new release"
2. Upload the `app-release.aab` file
3. Fill release notes
4. Review and confirm

### 2. Set Pricing and Distribution

1. **Pricing**: Set to Free or specify price
2. **Countries**: Select target countries
3. **Content rating**: Confirm rating

### 3. Publish the App

1. Review all information
2. Click "Start rollout to production"
3. Wait for review (usually 1-3 days)

## Post-Publication Tasks

- Monitor reviews and ratings
- Respond to user feedback
- Plan updates and new releases
- Track app performance in Play Console

## Troubleshooting

- **Build Issues**: Ensure Flutter and Android SDK are up to date
- **Signing Issues**: Double-check keystore passwords and paths
- **Play Console Rejections**: Review rejection reasons and update accordingly
- **App Not Showing**: Check distribution settings and wait for indexing

## Additional Resources

- [Google Play Console Help](https://support.google.com/googleplay/android-developer)
- [Flutter Deployment Docs](https://flutter.dev/docs/deployment/android)
- [Android App Bundle Guide](https://developer.android.com/guide/app-bundle)

---

**Note**: This guide is based on current Google Play Store requirements as of 2024. Requirements may change, so always check the official documentation for the latest information.