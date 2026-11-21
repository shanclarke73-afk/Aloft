# Aloft: where we stand

_Last updated: November 21, 2026 (1.0 build: steps 1–4 done except Health sync; Shotsy import done)_

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
- [ ] Step 4c: Apple Health / Health Connect (needs the HealthKit capability set up in Xcode and a real phone)
- [x] **Step 5a, progress photos** (Nov 21): the Progress tab. Add photos with the phone's camera or choose older
      ones from the library (they keep the date stored inside the photo; pose and date can be changed). Gallery by
      day with that day's weight; Compare shows two days of one pose side by side with the time and weight change
      between them; full-screen view with zoom, edit and delete. Files are kept in the app's private folder, never
      the camera roll, and the chooser only hands Aloft the photos picked.
- [ ] Step 5b: Aloft's own camera screen with the faint outline of the last photo and the 3 / 10 second timer;
      the swipe slider and timelapse (both Pro); the monthly photo reminder and the Today "Photo check-in" card.
- [x] **Step 6a, Shotsy import** (Nov 21): More → Import from Shotsy reads the CSV export, shows a preview (date
      range, counts, pen or compounded vial for each medication), and brings in shots, weights, day notes and
      side effects. Importing the same file twice adds nothing. Tested with made-up data only.
- [x] **Step 6b-1, backup file and restore** (Nov 21): More → Backup and restore. "Save a backup file" makes one
      zip (all records as JSON, plus the photo files unless switched off) and opens the share sheet; an optional
      password locks the whole file (AES-256). "Restore from a backup file" shows what's in the file first, then
      either adds what's missing (the default; doing it twice adds nothing) or replaces everything after a
      confirmation. Records restore all-or-nothing. App-lock choices always stay as set on the phone.
- [ ] Step 6b-2: automatic backup to the person's own iCloud / Google Drive with snapshots, the "no backup in 7
      days" warning on Today, and restore during onboarding. Needs the iCloud capability, a Google sign-in setup
      and real phones.
- [ ] CSV and PDF export (Pro, step 7).

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
7. Build step 6b-2 (automatic iCloud / Google Drive backup), step 5b (outline camera), then Health sync, all of
   which need a real phone.

## Not done / not verified
- No trademark check.
- Step 1 was run on the iPhone simulator only. Not yet tried: Face ID on a real iPhone, the lock on a real Android
  phone, and moving the encrypted data to a new phone.
- Left out so far, to pick up later: the body-map picture for injection sites (it's a list for now), "Something
  else" medications, the pill wait timer, "Remind me tonight" on a late dose, pen counts, and the "second
  medication is Pro" limit (any number can be added until Pro is built in step 7).
- Reminders have not been seen firing on a real phone. They are rebuilt each time the app opens or something is
  logged, and cover the next 14 doses per medication, so they'd stop if the app weren't opened for that long.
- Half-life and time to peak for the level chart were read from section 12.3 of each US prescribing information on
  DailyMed on Nov 21, 2026 (semaglutide 1 week / 1–3 days; tirzepatide 5 days / median 24 h; liraglutide 13 h /
  8–12 h; dulaglutide 5 days / median 48 h). Shannon should look these over once, and they need re-checking before
  each release. Retatrutide has no prescribing information, so it gets no curve. The numbers are built in and
  can't be edited in the app yet.
- The Shotsy import has only been run on made-up files in Shotsy's format. The real export is on the laptop
  (`samples/`, git-ignored) and hasn't been tried. Day notes come in as notes in History; notes can't be added or
  edited by hand yet (long-press deletes one).
- Progress photos were checked on the iPhone simulator with library photos only. The simulator has no camera, so
  taking a photo has not been tried, and nothing has run on Android. Photos are saved at up to 2400 pixels on the
  long side. They are only backed up when a backup file is saved by hand, so deleting the app without one deletes them. A photo has no note field,
  and a day's photos are grouped by date instead of being stored as a named set.
- Backup and restore were checked on the iPhone simulator only (save to Files, open, add missing, replace). Not
  tried: a real phone, Android, moving a file between iPhone and Android, a backup with hundreds of photos, or
  opening a password-locked file in another zip app. There is no automatic backup yet, and no reminder to make one.
  A forgotten backup password can't be recovered.
- Fonts from the mockups (Plus Jakarta Sans, Inter) aren't in the app yet; it uses the phone's own font.
- App icon isn't wired into the app yet (files are in [brand/](brand/)).
- Shotsy side effects are confirmed as whole numbers 1–10 (Aloft now uses 1–10 too). Pain level is a 0–10 slider that
  starts at 0, in Shotsy and in Aloft.
