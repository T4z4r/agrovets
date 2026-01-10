# Building the Release Version of Apex App

## 1. Create a Signing Key

Generate a keystore for signing the app:

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Store the keystore file securely and remember the password.

## 2. Configure Signing in Gradle

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

## 3. Build the App Bundle

Run the following command to build the release version:

```bash
flutter build appbundle --release
```

This creates `build/app/outputs/bundle/release/app-release.aab`

## 4. Verify the Build

- Check that the AAB file is generated successfully
- Test the release build on a device if possible
- Ensure all features work as expected in release mode