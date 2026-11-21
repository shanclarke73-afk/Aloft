# Aloft: where we stand

_Last updated: November 21, 2026 (planning done; 1.0 build step 1 of 8 in review)_

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
- [x] **Step 1, foundation** (pull request open, Nov 21): Flutter project in [app/](app/), encrypted database,
      settings (units, appearance), app lock, app-switcher cover, the five tabs (only More has content).
      Bundle ID decided: `com.shannonsonlinebookkeeping.aloft`.
- [x] **Step 2, medications and logging** (pull request open, Nov 21): add a compounded vial, brand-name pen or
      pill by typing it in; units ⇄ mL ⇄ mg with the math shown and added ingredients; Log shot / Log dose with
      mismatch notes, skip, pain 0–10 and site rotation across all medications; simple Today and My medications.
- [ ] Step 3: full Today screen, quick-add, History (edit/delete), schedules and reminders, supply tracking

## Next time
1. Shotsy export received (Nov 20) and its format documented in [docs/shotsy-import.md](docs/shotsy-import.md).
   Side-effect values are 1–10 whole numbers (confirmed Nov 21). Keep real exports out of git
   (`samples/` is git-ignored). General CSV import moved to Release 1.5.
2. Done: app screens use the icon's navy + teal palette (icon: Summit trail, files in [brand/](brand/)).
3. All 1.0 screens are mocked up, including Settings, My medications, side effects, edit/delete, late shot, day 1, Shotsy import preview, restore on a new phone, typed vial setup
   and the lock screen. Widgets (Release 1.5) mocked up; suggested split: small + Lock Screen free, medium Pro (confirm).
4. Answer the remaining open questions in SPEC section 12 (dose unit on your label, crash reporting).
5. USPTO trademark search for "Aloft" (classes 9 and 44); pick a page (likely peaceofmindapps.com/aloft/).
6. Build step 3 (Today, History, reminders, supply tracking).

## Not done / not verified
- No trademark check.
- Step 1 was run on the iPhone simulator only. Not yet tried: Face ID on a real iPhone, the lock on a real Android
  phone, and moving the encrypted data to a new phone.
- Left out of step 2, to pick up in later steps: the body-map picture for injection sites (it's a list for now),
  "Something else" medications, the pill wait timer, changing the usual dose, starting a new vial, pausing, and
  the "second medication is Pro" limit (any number can be added until Pro is built in step 7).
- Half-life and Tmax are left empty for every medication until checked against prescribing information.
- Fonts from the mockups (Plus Jakarta Sans, Inter) aren't in the app yet; it uses the phone's own font.
- App icon isn't wired into the app yet (files are in [brand/](brand/)).
- Shotsy side effects are confirmed as whole numbers 1–10 (Aloft now uses 1–10 too). Pain level is a 0–10 slider that
  starts at 0, in Shotsy and in Aloft.
- Drug half-life/Tmax defaults in the spec must be checked against prescribing information before release.
