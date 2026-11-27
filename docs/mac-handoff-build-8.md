# Mac handoff: build 8 for App Review (Nov 26, 2026)

For the Claude session on the Mac mini. Written from the Windows PC, where Flutter and Xcode aren't installed,
so nothing on this branch has been run or tested yet.

## Why

Apple held Aloft 1.0 (build 7) under **2.1 Information Needed** and asked for a screen recording plus answers
in the App Review notes. The drafted reply is in [app-review-response.md](app-review-response.md). Before
Shannon records the video, the iPhone/iPad build must stop offering the reviewers' access code: an unlock
that skips in-app purchase risks a guideline 3.1.1 rejection. Commit `6b992dd` on branch
`ios-no-access-code` does that (`app/lib/pro/review_access.dart`, `app/lib/main.dart`, new tests in
`app/test/pro_test.dart`). Android keeps the code for Google's reviewers.

## Steps (all from `app/`, see [fastlane.md](fastlane.md))

1. `git fetch && git checkout ios-no-access-code && git pull`
2. `flutter pub get`, then `flutter analyze` and `flutter test`. **Stop and tell Shannon if anything fails.**
   Fix it on this branch if the cause is clear.
3. Run the app on the iPad or the simulator and check that More → Aloft Pro has **no** "Have an access code?"
   link. If an Android device or emulator is handy, check the link is still there.
4. `bundle exec fastlane bump` (should raise the build number in `pubspec.yaml` from 7 to 8). Commit it:
   "Version 1.0.0 (build 8)".
5. `bundle exec fastlane ios beta`: build and upload to TestFlight. If code signing fails with
   `errSecInternalComponent` or a keychain prompt, the keychain is locked: ask Shannon to run the lane in
   their own Terminal on the Mac.
6. Optional, same build for Play: `bundle exec fastlane android internal`. Not required for Apple.
7. Push the branch and open a PR to `main`. Update STATUS.md (the "App Review: 2.1 Information Needed" item):
   build 8 uploaded, tests passed, what was checked on a device.

## Not for this session (Shannon does these)

- Answer the encryption question for build 8 in TestFlight ("standard encryption algorithms").
- Record the screen video on the iPad with build 8 (plan in app-review-response.md, section 1).
- Paste the notes in App Store Connect, reply to Apple, attach build 8, and **Resubmit to App Review**.
  Don't submit anything for review from the Mac.
