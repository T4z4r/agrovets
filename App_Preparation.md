# Preparing the Apex App for Deployment

## 1. Update Package Name

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

## 2. Create a Privacy Policy

Since the app uses camera permission for barcode scanning, you need a privacy policy:

1. Create a privacy policy document explaining data collection and usage
2. Host it on your website or use a service like [Privacy Policy Generator](https://www.privacypolicygenerator.info/)
3. Note the URL for Play Console

## 3. Prepare App Assets

- **App Icon**: Ensure `assets/images/logo.png` is 512x512 pixels
- **Screenshots**: Capture screenshots showing key features (login, dashboard, sales, stock management, reports, etc.)
- **Feature Graphic**: Create a 1024x500 banner image highlighting the app's agricultural management capabilities