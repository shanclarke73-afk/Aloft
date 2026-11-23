# Android release signing

Google Play only accepts a build signed with Aloft's **upload key**. The key is a file plus a
password. Neither is in this repository, and neither should ever be.

## What is where

| Thing | Where | In git? |
| --- | --- | --- |
| The upload key file | `~/keys/aloft-upload-keystore.jks` on the Mac that makes release builds | No |
| Its password and alias | `app/android/key.properties` | No (git-ignored) |
| The template for that file | `app/android/key.properties.example` | Yes |
| The build setup that reads it | `app/android/app/build.gradle.kts` | Yes |

Without `key.properties`, a release build still works and is signed with the debug key. That
is fine for installing on a phone over USB. Google Play rejects it.

## One-time setup

1. Make the key. It asks for a password (twice) and a few questions such as your name; the
   answers other than the password can be anything sensible.

   ```bash
   mkdir -p ~/keys && "/Applications/Android Studio.app/Contents/jbr/Contents/Home/bin/keytool" -genkey -v -keystore ~/keys/aloft-upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. Copy `app/android/key.properties.example` to `app/android/key.properties` and fill in the
   password (both password lines get the same one) and the full path to the key file.

3. Save the key file and the password somewhere safe that is not this Mac: a password manager
   that takes file attachments is ideal.

## If the key is lost

With Play App Signing (the default for new apps), Google holds the real signing key and this
one only proves an upload came from you. If it is lost or exposed, Play Console → the app →
Test and release → App integrity → App signing → "Request upload key reset" replaces it. It
takes a day or two and no user is affected.

## Making the build for Google Play

```bash
cd app && flutter build appbundle --release --dart-define-from-file=dart_defines.release.json
```

The result is `app/build/app/outputs/bundle/release/app-release.aab`. The defines file holds
the RevenueCat **Google** key (`goog_...`), not the Test Store key: a release build ignores a
`test_` key. Raise the build number in `pubspec.yaml` (the part after `+`) for every upload.

To confirm which key signed a bundle:

```bash
"/Applications/Android Studio.app/Contents/jbr/Contents/Home/bin/keytool" -printcert -jarfile app/build/app/outputs/bundle/release/app-release.aab
```

"CN=Android Debug" in the output means the upload key was not used.
