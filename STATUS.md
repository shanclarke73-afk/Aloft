# Aloft: where we stand

_Last updated: November 25, 2026 (1.0: features built; products in both stores and in RevenueCat; paywall states the trial; build 5 on both stores and purchases tested on a Pixel and an iPad; left are screenshots, store graphics and forms, and the pre-release checks)_

Aloft is a private GLP-1 tracker for iPhone and Android (Flutter), for brand-name pens, compounded vials and pills,
with progress photos. Tagline: *From titration to thriving.* Full plan: [SPEC.md](SPEC.md).

## Done
- [x] Feature plan, competitor check and pricing research, name chosen (Aloft), spec
- [x] Pricing: $1.99/mo, $14.99/yr, $29.99 lifetime; free vs Pro split decided (SPEC section 8)
- [x] Release plan: 1.0 MVP (incl. Shotsy/CSV import), 1.5, 2.0 (SPEC section 11)
- [x] Screen mockups (app, onboarding, two-medication, pill, quick-add, weight, measurements, Pro, icon concepts):
      https://claude.ai/artifact/Lzbyu8ZRQ8LN998PQqeayh. Copy in [mockups/](mockups/) (open `mockups/index.html`);
      icon concepts are on the canvas only.
- [x] GitHub repo: https://github.com/shanclarke73-afk/Aloft
- [x] App icon chosen: **Summit trail** (round 3, concept J). Final files in [brand/](brand/)

## Build progress (1.0, SPEC section 11)
- [x] **Step 1, foundation** (merged Nov 21): Flutter project in [app/](app/), encrypted database,
      settings (units, appearance), app lock, app-switcher cover, the five tabs (only More has content).
      Bundle ID decided: `com.shannonsonlinebookkeeping.aloft`.
- [x] **Step 2, medications and logging** (merged Nov 21): add a compounded vial, brand-name pen or
      pill by typing it in; units ⇄ mL ⇄ mg with the math shown and added ingredients; Log shot / Log dose with
      mismatch notes, skip, pain 0–10 and site rotation across all medications; simple Today and My medications.
- [x] **Step 3, Today, History, reminders, supply** (Nov 21): Today shows when each medication is due, with a
      late-dose card (taking it now / took it, didn't log it / skipped); History with edit, delete and 10-second
      undo; local reminders for shot days, reorder at 2 doses left and use-by date, each with its own switch;
      My medications: change dose, edit schedule, start a new vial, finish a vial, adjust what's left, pause.
- [x] **Step 4a, weight and side effects** (Nov 21): log weight in lb or kg with the change since last time and since
      the start; log several side effects at once, each 1–10, with "likely from"; both show in History (with
      All / Shots / Weight / Effects filters) and in quick-add; Today has a weight card.
- [x] **Step 4b, level chart and Charts tab** (Nov 21): estimated level for injected semaglutide, tirzepatide,
      liraglutide and dulaglutide, with a projection to the next scheduled dose, always labelled as an estimate;
      weight chart; an estimated-level card on Today.
- [ ] Step 4c: Apple Health / Health Connect. **Moved to 1.5** (Nov 22).
- [x] **Step 5a, progress photos** (Nov 21): the Progress tab. Add photos with the phone's camera or choose older
      ones from the library (they keep the date stored inside the photo; pose and date can be changed). Gallery by
      day with that day's weight; Compare shows two days of one pose side by side with the time and weight change
      between them; full-screen view with zoom, edit and delete. Files are kept in the app's private folder, never
      the camera roll, and the chooser only hands Aloft the photos picked.
- [ ] Step 5b, **moved to 1.5** (Nov 22): Aloft's own camera screen with the faint outline of the last photo and the 3 / 10 second timer;
      the swipe slider and timelapse (both Pro); the monthly photo reminder and the Today "Photo check-in" card.
- [x] **Step 6a, Shotsy import** (Nov 21): More → Import from Shotsy reads the CSV export, shows a preview (date
      range, counts, pen or compounded vial for each medication), and brings in shots, weights, day notes and
      side effects. Importing the same file twice adds nothing. Tested with made-up data only.
- [x] **Step 6b-1, backup file and restore** (Nov 21): More → Backup and restore. "Save a backup file" makes one
      zip (all records as JSON, plus the photo files unless switched off) and opens the share sheet; an optional
      password locks the whole file (AES-256). "Restore from a backup file" shows what's in the file first, then
      either adds what's missing (the default; doing it twice adds nothing) or replaces everything after a
      confirmation. Records restore all-or-nothing. App-lock choices always stay as set on the phone.
- [x] **Onboarding** (Nov 21): a new install opens on five screens: welcome, medication (pen, vial, pill, or
      import from Shotsy), starting weight with its date, starting photos, then app lock, the shot-day reminder
      and the medical disclaimer. Every step can be skipped except ticking the disclaimer. The welcome screen
      has a link to restore a backup file. A phone set up before this existed sees the screens once.
- [x] **Icon, fonts and About** (Nov 21): the Summit trail icon is the app icon on both platforms (generated
      from `brand/` with `dart run flutter_launcher_icons`); Inter for body text and Plus Jakarta Sans for headings
      and big numbers are bundled (open font license, no download at run time); More → About Aloft has the
      version, medical disclaimer, privacy summary, level-chart note, trademark notice and open-source licenses.
- [ ] Step 6b-2, **moved to 1.5** (Nov 22): automatic backup to the person's own iCloud / Google Drive with snapshots, the "no backup in 7
      days" warning on Today, and restore during onboarding. Needs the iCloud capability, a Google sign-in setup
      and real phones.
- [x] CSV export (Nov 22): More → Backup and restore → Export as CSV shares a zip of doses, weights, side
      effects and notes. Behind Pro since Nov 22.
      Measurements aren't in it (not built). Not opened in Excel, Numbers or Sheets yet.
- [x] **PDF report and the Pro switch** (Nov 22): More → Report for your provider makes a PDF (real text; summary,
      weight chart, dose history by step, side effects, notes; Letter or A4; last 3 / 6 / 12 months or everything)
      and saves it to Documents › Aloft or the share sheet. It and CSV export are behind one Pro switch
      (`proProvider`). **Purchases are not connected**, so in a normal build nobody can get Pro; the Pro screen says
      so and has no buy button. Test builds pass `--dart-define=ALOFT_PRO=true`. Not in the report yet: the
      estimated-level curve, choosing medications, measurements, photos, and bold text (the bundled font has one
      weight). A step heading can be left alone at the foot of a page.
- [x] **Purchases connected to RevenueCat's Test Store** (Nov 22): `purchases_flutter`, a `ProStore` the app
      talks to, and a real paywall (three plans with the store's prices, renewal terms, Restore purchases, Manage
      subscription). More has an "Aloft Pro" row. Seen working on an Android emulator: plans loaded, a failed test
      purchase said no charge was made, a valid one switched Pro on, and it stayed on after a restart.
      The key comes from `--dart-define-from-file=dart_defines.local.json` (git-ignored). **RevenueCat closes the
      app if a release build uses a Test Store key**, so the app ignores a `test_` key in release: test purchases
      need a debug build. A build with no key has no store and says buying isn't available.
- [x] **Second medication is Pro** (Nov 22): one active medication at a time is free. Without Pro, "Add another
      medication" and "Resume" next to an active one open the Pro screen with the reason ("Track NAD+ alongside
      Zepbound with Pro") and say that pausing the other one is the free way to switch. A Shotsy import without
      Pro keeps one medication active (one already active, else the one with the latest shot) and brings the
      others in paused with their history, and says so. Nothing is ever paused or hidden when Pro ends, and
      restoring a backup is not limited. The welcome screens' "Taking something else as well?" asks too.
      Seen on an Android emulator (Nov 22): the Pro screen on Add another, on Resume and in the welcome
      screens, and adding for free once the other is paused. The import's paused message is tests only.
- [x] **Android release signing set up** (Nov 22): the build reads the upload key from `app/android/key.properties`
      (git-ignored) and falls back to the debug key without it. Steps are in
      [docs/android-signing.md](docs/android-signing.md). Checked with a throwaway key, since deleted.
      The real upload key was made on Nov 22 (`~/AndroidKeys/aloft-upload.jks`, with `app/android/key.properties`).
- [ ] Real stores (Nov 22: both apps now exist as **"Aloft: GLP-1 Tracker"**: Google Play app
      `4973392568712926705`, free; App Store Connect app `6838066361`, bundle ID registered). The products exist
      in both stores and in RevenueCat (see below). The RevenueCat service account
      (`revenuecat@taxtote-prod`) has Aloft access in Play Console and its file is in RevenueCat (Nov 24);
      RevenueCat's Play credentials show as valid since Nov 25. Still needed: a review screenshot on each App
      Store product.
- [x] **First Google Play upload** (Nov 23): 1.0.0 build 1, signed with the upload key, is in Internal testing as
      a **draft** release. Testers can't install it until the draft is rolled out in Play Console. It was built
      with an empty `ALOFT_RC_KEY` in `app/dart_defines.release.json`, so it has no purchases and the Pro screen
      says buying isn't available. Its job is to unlock creating the three products in Play. The next store build
      needs the RevenueCat Play key in that file (as `ALOFT_RC_KEY_ANDROID`) and a higher build number (`bundle exec fastlane bump`).
- [x] **Purchases tested on real devices** (Nov 25), build 4, by Shannon:
      - Pixel (Google Play): the three plans load with real prices; she started the yearly plan and RevenueCat
        recorded it as a trial, so the 14-day free trial is offered and applied. Her Gmail is a licence tester
        (Play Console → License testing), so nothing was charged.
      - iPad (TestFlight): she bought Lifetime; RevenueCat recorded a $29.99 one-time App Store purchase. The
        plans load in testing even though the three App Store products still say "Missing metadata".
      - Both devices switched to "You have Aloft Pro".
      - Google real-time developer notifications are on for Aloft (Play Console → Monetization setup, topic
        `projects/taxtote-prod/topics/Play-Store-Notifications`, all product types) and RevenueCat has
        received one.
      Not tested: Restore purchases, Manage subscription, a subscription ending, or the trial on the App Store.
- [x] **Build 5 uploaded to both stores** (Nov 25), 1.0.0 (5): build 4 plus the Today backup-reminder fix
      and the level chart's source line without brand names. Google Play: released to Internal testing.
      App Store: uploaded to TestFlight. The Android bundle of build 5 is about 21 MB bigger than it should
      be: iCloud Drive had made " 2" copies of files inside `app/build`, and an old "libapp 2.so" was packed
      beside the real one. It is never loaded, so the app behaves the same. `app/build` on the Mac is now a
      link to `~/Library/Caches/flutter-builds/aloft-main`, outside iCloud, and the iPhone build 5 was made
      after that from a clean folder. The next Android build will be clean too.
- [x] **Build 4 uploaded to both stores** (Nov 25), 1.0.0 (4): build 3 plus the Save button kept above the
      phone's navigation buttons, and getting started asking about history first. Google Play: released to
      Internal testing. App Store: uploaded to TestFlight. **Answer the encryption question on this build as
      "standard encryption algorithms", not sold in France.** The Save button was seen fixed on Shannon's Pixel (Nov 25). The new getting-started step has not been
      seen on a real device.
- [x] **Build 3 uploaded to both stores** (Nov 24), 1.0.0 (3): build 2 plus the iPad layout and the
      "iPad" / "tablet" wording. Google Play: released to Internal testing by `fastlane android internal`
      (no draft step needed now that the track is live). App Store: uploaded to TestFlight by
      `fastlane ios beta`, which ran end to end for the first time and worked. The TestFlight encryption
      question is still unanswered and there are no TestFlight testers.
- [x] **Build 2 uploaded to both stores** (Nov 24), 1.0.0 (2), the first with real purchases (RevenueCat keys
      for each store). **Google Play:** rolled out to Internal testing on Nov 24 with the "Tax Tote testers"
      list (Shannon only); it replaces build 1.
      **App Store:** uploaded to TestFlight for the first time; it processed, but the encryption question is not answered yet and
      there are no testers. Xcode has no Apple account on this Mac, so
      `flutter build ipa` can't sign; `fastlane ios beta` now archives with the App Store Connect key and signs
      the store copy with the profile "com.shannonsonlinebookkeeping.aloft AppStore" (made Nov 24). The steps
      were run by hand for build 2; the lane itself ran end to end for build 3.
      `fastlane android internal draft:true` makes the Play draft. Not yet done: testers on either store, and a
      test purchase.
- [x] **iPad** (Nov 24): the iPhone project already targets iPad, so the TestFlight build installs on one. On an
      iPad or tablet the app now sits in a centred column 640 points wide instead of stretching edge to edge
      (`WideFrame`). The wording follows the device too: "this phone", "this iPad" or
      "this tablet" (`deviceWord`). Seen on the iPad Pro 13-inch simulator, welcome screen only. The other
      screens have not been looked at on an iPad, and a real iPad has not run it. Both are in build 3.
- [x] **Store listing text** (Nov 24), in [docs/store-listing.md](docs/store-listing.md): approved by Shannon and
      entered into both stores. The App Store has the subtitle, promotional text, keywords, description, links,
      category and review notes. Google Play has the short and full description as a draft store listing.
      Still missing in both: screenshots (they need made-up data and there is no demo mode), the Play icon
      and feature graphic, App Store review contact details, and all the forms (privacy labels, data safety,
      content and age ratings, health and exact-alarm declarations).
- [x] **Getting started asks about history first** (Nov 25): after the welcome screen, step 1 of 5 is "Bringing
      your history?" with Import from Shotsy, Restore an Aloft backup file, or "No, start fresh". After a file
      comes in, Aloft goes straight to the first step it didn't answer (medication, then weight, then photos)
      and says what it found. The weight step shows the weights that came in and only asks for goal and height.
      The Shotsy and restore links moved here from the welcome and medication screens. Seen on the iPad
      simulator (the question screen only); the path after a real file is covered by tests, not seen on a device.
- [x] **Listing no longer names Shotsy** (Nov 25): the import line in both stores now says "another tracker's
      CSV export". The name stays inside the app, where people need it to pick the right file, and About says
      Aloft isn't affiliated with it.
- [x] **Encryption answer** (Nov 25): on build 4 Shannon chose "standard encryption algorithms", not sold in
      France, and Apple asked for no documents. Apple's API shows the same value on builds 2, 3 and 4 (exempt),
      so it can't tell which option was chosen. Submit build 4 or later for review, not 2 or 3.
- [ ] **Store screenshots** (Nov 25). A screenshot build (`flutter run --dart-define=ALOFT_DEMO=true`, debug
      only; add `--dart-define=ALOFT_PRO=true` for everything except the Aloft Pro screen) opens a throwaway
      database with a made-up person's twelve weeks of compounded semaglutide and a pretend store with the
      three plans, so no real records appear and nothing can be bought. Raw captures are in
      [store/screenshots/raw](store/screenshots/raw); `python3 store/screenshots/compose.py` turns them into
      the captioned store images (captions are in that file).
      - **App Store: uploaded.** Five iPhone 6.9-inch images (Today, Log shot, History, Charts, Aloft Pro) and
        four iPad 13-inch images, in [store/screenshots/app-store](store/screenshots/app-store). The plain
        Aloft Pro capture is also the review screenshot on all three products, which now say "Ready to
        Submit" instead of "Missing metadata".
      - **Google Play: uploaded by Shannon in Play Console on Nov 25** (not checked from here). The notes
        that follow are how the automatic upload failed.
      - **Google Play, earlier: made, not uploaded.** Four phone images (1080 x 1920) and the feature graphic
        (1024 x 500) are in [store/screenshots/play](store/screenshots/play); the icon is
        `brand/play-store-512.png`. On Nov 25 the fastlane Play key (`fastlane@taxtote-prod`) was given
        "Manage store presence" for Aloft, which also covers pricing, in-app products and content ratings.
        Uploading the images through Google's API then worked, but saving the change was still refused
        ("The caller does not have permission") several minutes later. Either the permission needs longer to
        take effect, or the files go in by hand through Play Console (Grow → Store presence → Store listings).
        Google's API also shows the listing's descriptions as empty: the text entered on Nov 24 is a draft in
        Play Console only.
      - Not made: Android tablet images (optional on Play), and a Pro image for Play.
- [x] **Level chart source line** (Nov 25): it now reads "US prescribing information for semaglutide" (and the
      same for the other three), instead of naming the brand-name products, so store images carry no other
      company's trademarks. The figures and where they came from are unchanged.
- [x] **Today's backup reminder no longer breaks the screen** (Nov 25): with 5 or more logs and no backup
      saved, the reminder card's two buttons could not be laid out, and in a debug build the whole Today screen
      went blank. Found while making screenshots. What a release build showed was not checked. Fixed in build 5.
- [ ] **Store forms** (Nov 25): answers approved by Shannon; what is entered so far is in the table at the top
      of [docs/store-forms.md](docs/store-forms.md). App Store: age rating (12+), free price, countries without
      France and content rights are in. Google Play: 7 of 11 declarations saved (none sent for review). Still
      open: Play's Sign in details (a decision, since Pro counts as "restricted"), which blocks Target
      audience; Content ratings; Data safety; and the App Store privacy labels and review contact. The iPhone
      privacy file now lists Analytics beside App functionality for purchase history, and the matching
      privacy-policy sentences are in an open pull request on the website repo.
- [x] **Google Play products** (Nov 23), all active, sold in every country Play offers except France:
      | Product ID | Kind | US price | Inside it |
      |---|---|---|---|
      | `aloft.pro.monthly` | subscription | $1.99 | base plan `monthly` |
      | `aloft.pro.yearly` | subscription | $14.99 | base plan `yearly`; offer `free-trial`, 2 weeks, for people who never had an Aloft subscription |
      | `aloft.pro.lifetime` | one-time product | $29.99 | purchase option `lifetime` |

      Other countries' prices are Google's conversions of the US price. Made in Play Console: the fastlane Play
      key can read products but isn't allowed to create or price them. Use the same three IDs in the App Store.
- [x] **App Store products** (Nov 24), made with the App Store Connect key, same IDs as Play, in subscription
      group "Aloft Pro" (yearly is level 1, monthly level 2): `aloft.pro.monthly` $1.99, `aloft.pro.yearly`
      $14.99 with a 2-week free trial for new subscribers, `aloft.pro.lifetime` $29.99 (non-consumable). Sold in
      174 countries, not France; other countries' prices are Apple's equivalents of the US price. All three say
      "Missing metadata" until each has a review screenshot (a picture of the paywall), and they go to review
      with the first app version.
- [x] **RevenueCat set up for both stores** (Nov 24), project "Aloft": apps "Aloft (Play Store)" and "Aloft (App
      Store)"; the App Store one uses the in-app purchase key already used by Tax Tote and Debt Shredder. All six
      store products are on the `pro` entitlement and in the `default` offering (Monthly, Lifetime, Annual
      packages), beside the Test Store ones. Both public keys are in `app/dart_defines.release.json` on the Mac.
      **Not done:** RevenueCat has no App Store Connect API key (optional; only for importing products and
      price changes).
- [x] **The paywall states the free trial** (Nov 24): when the store offers this person a trial, the yearly card
      says "Best value · 14 days free", the button says "Start 14-day free trial", and the terms give the length,
      the price after it, that it renews, and that cancelling before the trial ends costs nothing. The trial is
      read from the store, never assumed: Google Play only reports it to people who can still use it, and on
      iPhone RevenueCat is asked whether the person is eligible. No trial reported means no mention of one.
      Tests only so far; not seen with a real store.
- [x] **One key per store** (Nov 24): `app/dart_defines.release.json` now takes `ALOFT_RC_KEY_ANDROID`
      (`goog_...`) and `ALOFT_RC_KEY_IOS` (`appl_...`), and each build picks its own. `ALOFT_RC_KEY` is still
      the Test Store key for debug builds.

## Next time
1. Shotsy export received (Nov 20) and its format documented in [docs/shotsy-import.md](docs/shotsy-import.md).
   Side-effect values are 1–10 whole numbers (confirmed Nov 21). Keep real exports out of git
   (`samples/` is git-ignored). General CSV import moved to Release 1.5.
2. Done: app screens use the icon's navy + teal palette (icon: Summit trail, files in [brand/](brand/)).
3. All 1.0 screens are mocked up, including Settings, My medications, side effects, edit/delete, late shot, day 1, Shotsy import preview, restore on a new phone, typed vial setup
   and the lock screen. Widgets (Release 1.5) mocked up; suggested split: small + Lock Screen free, medium Pro (confirm).
4. Answer the remaining open questions in SPEC section 12 (dose unit on your label, crash reporting).
5. USPTO trademark search for "Aloft" (classes 9 and 44); pick a page (likely peaceofmindapps.com/aloft/).
6. **Try the Shotsy import with the real export** on the Mac mini or a phone, and compare the totals with
   Shotsy's Summary PDF (the acceptance test in SPEC 6.11).
7. **Left for 1.0** (Nov 22): Pro with RevenueCat (second medication, PDF report, Manage subscription, Restore
   purchases); the PDF report itself; privacy policy, terms and support pages, linked from About; store listings,
   screenshots and declarations (health apps, "Alarms & reminders"); saving the Android upload key password to 1Password; trademark check;
   closed testing, including someone with a real iPhone. Automatic backup, Health sync and the outline camera
   are now 1.5.

## Checked on a real phone
On Shannon's Pixel 11 Pro (Android), Nov 22, 2026, from a release build installed over USB:
- Works: the app icon, welcome screens, fingerprint lock (and no second prompt after Aloft's own camera), typing
  a vial with "5 mg in 0.5 mL", taking a progress photo with the camera, the real Shotsy export (doses included),
  saving a backup file, Delete all my data, restoring that backup, goal weight and BMI, dates with years, and
  the quiet "Log a shot early" button.
- Not yet: a reminder was not seen on the phone. On an Android 17 emulator the same build schedules and shows it
  (a weekly 11:45 reminder appeared at 11:48), so the next step is to read the phone's permission and alarm
  state over USB. Read Nov 22: notifications were allowed and the reminder was set, for 11:35 PM rather than AM.
  Android gave it a one-hour delivery window, so Aloft now declares `SCHEDULE_EXACT_ALARM` and schedules exactly
  when the person has switched on "Alarms & reminders" (More offers the setting); otherwise it falls back to the
  old timing. **Before release:** declare the permission on the Play Console form and confirm the current policy.
- Shannon's iPad runs build 4 from TestFlight (Nov 25): installed, opened, and a purchase went through.
- Nothing has run on a real iPhone. Shannon has no iPhone; a TestFlight tester or a borrowed phone is needed.
- iPhone store-review fixes (Nov 23, 2026, seen on the simulator only):
  - The database and photos are kept out of iCloud Backup and computer backups (guideline 5.1.3: no personal
    health information in iCloud). **So a new or restored iPhone starts empty unless the person saved a backup
    file**; the Today reminder to save one matters more now. Backup files saved to Files stay where they are.
    The automatic iCloud backup planned for 1.5 conflicts with 5.1.3 as written and needs a rethink.
  - The app no longer tells Apple it has no encryption (it uses SQLCipher, a standard algorithm that isn't
    Apple's own). App Store Connect will ask on each upload: answer "standard encryption algorithms". Apple
    then wants a French encryption declaration only if the app is sold in France. **Decided Nov 23:** launch
    without France in the App Store countries; it can be added later by filing that declaration. Google Play
    has no such rule.
  - A privacy manifest (`ios/Runner/PrivacyInfo.xcprivacy`) says no tracking and purchase history only.
- The phone build is signed with the debug key, so it must be uninstalled before a Play Store build goes on.
- To see the Android screen on an emulator, build with `--dart-define=ALOFT_ALLOW_SCREENSHOTS=true` (the normal
  build blocks screenshots while "Hide screen in app switcher" is on, which also blocks the person's own).

## Not done / not verified
- Backup to a set folder (Nov 22): "Save a backup to this phone" writes to Documents › Aloft on Android (10 and
  newer; older phones get the share sheet) and to Files › On My iPhone › Aloft on iPhone, with no chooser.
  "Send a backup somewhere else" is the share sheet. The iPhone side has not been run at all, and files kept in
  the app's own folder there are removed if the app is deleted.
- Backup reminder (Nov 22): Today shows "Save a backup file" once there are 5 logged shots and weights and no
  backup file has been saved from this phone, and "Time for a fresh backup" 30 days after the last one. "Not now"
  hides it for 7 days. Aloft only knows a file was offered to the share sheet, not that it was kept. Not seen on
  a screen yet.
- Added Nov 22 and seen only on an Android emulator: the goal line on the weight chart, goal and BMI lines,
  adding and editing notes. Not seen on any device: editing a side effect, the import's "where do these shots
  go?" choice, Export as CSV.
- No trademark check.
- Step 1 was run on the iPhone simulator only. Not yet tried: Face ID on a real iPhone, the lock on a real Android
  phone, and moving the encrypted data to a new phone.
- Left out so far, to pick up later: the body-map picture for injection sites (it's a list for now), "Something
  else" medications, the pill wait timer, "Remind me tonight" on a late dose, pen counts, and the "second
  medication is Pro" limit (any number can be added until Pro is built in step 7).
- Reminders have been seen firing on an Android emulator only (see above). They are rebuilt each time the app opens or something is
  logged, and cover the next 14 doses per medication, so they'd stop if the app weren't opened for that long.
- Half-life and time to peak for the level chart were read from section 12.3 of each US prescribing information on
  DailyMed on Nov 21, 2026 (semaglutide 1 week / 1–3 days; tirzepatide 5 days / median 24 h; liraglutide 13 h /
  8–12 h; dulaglutide 5 days / median 48 h). Shannon should look these over once, and they need re-checking before
  each release. Retatrutide has no prescribing information, so it gets no curve, and since Nov 23 it is no longer on the
  built-in list (store rules on unapproved substances); it can be typed in as a name. The numbers are built in and
  can't be edited in the app yet.
- The Shotsy import was run with the real export on the Pixel (Nov 22) and worked; the totals were not compared
  with Shotsy's Summary PDF. Shots can be sent to a medication already in Aloft under another name. Day notes come in as notes in History; notes can't be added or
  edited by hand yet (long-press deletes one).
- Progress photos were checked on the iPhone simulator with library photos only. The simulator has no camera, so
  taking a photo has not been tried, and nothing has run on Android. Photos are saved at up to 2400 pixels on the
  long side. They are only backed up when a backup file is saved by hand, so deleting the app without one deletes them. A photo has no note field,
  and a day's photos are grouped by date instead of being stored as a named set.
- Backup and restore were checked on the iPhone simulator only (save to Files, open, add missing, replace). Not
  tried: a real phone, Android, moving a file between iPhone and Android, a backup with hundreds of photos, or
  opening a password-locked file in another zip app. There is no automatic backup yet, and no reminder to make one.
  A forgotten backup password can't be recovered.
- Onboarding differs from the spec and mockups where the feature behind a screen isn't built: the welcome screen
  says data stays on the phone with a backup file you save yourself (no iCloud / Google Drive promise), and there
  is no label scan, Apple Health import, or backup switch. Add those when the features exist. Goal weight and
  height (for BMI) are on the starting-weight step and in More; BMI is not yet on the charts or in a report.
- The Android icon was seen on the Pixel and on an emulator's notification (Nov 22). Its generated file was edited by hand
  to drop an extra 16% inset (the artwork already sits in the safe area); re-running the icon tool puts the inset
  back, and it also changes an unrelated Xcode setting that should be reverted (`git checkout` the `.pbxproj`).
- The privacy policy, terms and support pages are live at peaceofmindapps.com/aloft/ (Nov 22) and linked from
  About and the paywall. They are plain-language drafts, not reviewed by a lawyer, and Aloft isn't linked from
  the website's home page, apps page, footer or support form yet. The
  trademark owners named there (Novo Nordisk, Eli Lilly) are from memory and should be checked before release.
- Shotsy side effects are confirmed as whole numbers 1–10 (Aloft now uses 1–10 too). Pain level is a 0–10 slider that
  starts at 0, in Shotsy and in Aloft.
