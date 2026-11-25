# Releasing with fastlane

Fastlane builds the release app and uploads it. Its version is pinned in `app/Gemfile` / `app/Gemfile.lock`, and its config is in `app/fastlane/`. Run it from `app/`, always through `bundle exec`:

```bash
bundle exec fastlane bump                 # raise the build number (+N) in pubspec.yaml
bundle exec fastlane ios beta             # build the IPA and upload it to TestFlight
bundle exec fastlane android internal     # build the AAB and release it to Internal testing
bundle exec fastlane android production   # build the AAB and add it to a draft production release
```

`bundle exec fastlane ios check` and `bundle exec fastlane android check` test the store keys without changing anything. No lane submits for review or changes store listings, screenshots or descriptions. Commit the `bump` change like any other.

Store builds need `app/dart_defines.release.json` (git-ignored) with the RevenueCat platform keys; the lanes stop if it is missing. The same file holds `ALOFT_REVIEW_CODE_SHA256`, the fingerprint of the access code store reviewers type to reach Aloft Pro (`shasum -a 256` of the code, with no trailing newline: `printf '%s' 'the-code' | shasum -a 256`). See [android-signing.md](android-signing.md).

## One-time setup

1. Use Homebrew's Ruby, not the one built into macOS (`brew install ruby`, with `/opt/homebrew/opt/ruby/bin` and `/opt/homebrew/lib/ruby/gems/4.0.0/bin` first on your PATH in `~/.zprofile`). Then run `bundle install` in `app/`.
2. Copy `app/fastlane/.env.example` to `app/fastlane/.env` (git-ignored). The values are the same as Tax Tote's: the App Store Connect "fastlane" team key and the `fastlane@taxtote-prod` Google Play service account, both in `~/AppStoreKeys`. The service account needs release permission for this app in Play Console (**Users and permissions**).
3. Android uploads need `app/android/key.properties` (the upload key); the Android lanes stop without it.
4. Run `bundle exec fastlane ios beta`. Xcode needs no Apple account: the lane signs through the App Store Connect key and the Apple Distribution certificate in the Mac's keychain. If the keychain asks for permission, run it in your own Terminal.
