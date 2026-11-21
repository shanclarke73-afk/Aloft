# Aloft: product spec (v1)

_Draft 1, November 20, 2026. Planning only; no code yet._

> **Aloft: GLP-1 Shot Tracker**
> *From titration to thriving.*

---

## 1. What Aloft is

Aloft is a private GLP-1 tracker for iPhone and Android. It works for **everyone on a GLP-1**: brand-name pens
(Ozempic, Wegovy, Mounjaro, Zepbound and others) and **compounded vials** with non-standard strengths and added
ingredients.

It started because the leading app (Shotsy) can't describe a compounded vial properly, and because there was no good
way to keep progress photos from day one.

### Who it's for
- **Primary:** people on compounded semaglutide or tirzepatide who draw doses in syringe units and whose vials contain
  extra ingredients (B12, glycine, L-carnitine, etc.).
- **Also:** anyone on a brand-name GLP-1 who wants a simple, private tracker with progress photos.
- Never market it as "compounded only" (name, subtitle or icon). Compounded support is a feature, not the identity.

### What makes it different
| | Aloft | Typical GLP-1 trackers (Shotsy etc.) |
|---|---|---|
| Compounded vials with exact concentration + added ingredients | ✅ | ❌ preset brand doses |
| Units ⇄ mL ⇄ mg conversion, shown with the math | ✅ | Limited or none |
| Vial supply: doses left, reorder reminder, beyond-use date | ✅ | ❌ |
| Scan a vial label or prescription to set up | ✅ | ❌ |
| Progress photos with pose-matching outline + comparison | ✅ | ❌ (Shotsy has none) |
| No Aloft account; we never see your data; backups go to your own iCloud / Google Drive | ✅ | Usually an account + the company's cloud |
| Food, water and calorie tracking | ❌ on purpose | Common |

---

## 2. Principles (apply to every decision)

1. **Log and convert, never advise.** Aloft records what the user's prescription or label says and converts between
   units. It never suggests, recommends, calculates or adjusts a dose. (Apple guideline 1.4.2 restricts dosage
   calculators; see section 9.)
2. **Private, but never lost.** No Aloft account, no Aloft server, no analytics on health data. Data lives on the
   device and is backed up automatically to the user's **own** iCloud (iPhone) or Google Drive (Android), where
   Aloft's developer can't see it. Changing or losing a phone must never mean losing history or photos.
3. **Fast to log.** Logging a shot should take under 10 seconds on a normal week.
4. **Calm, not naggy.** Few notifications, all optional. Positive, body-neutral language ("progress," "change"),
   never "skinny," "fat" or before/after shaming.
5. **The user's data is theirs.** Full export and import (JSON) are always available, Pro or not.

---

## 3. Platforms and technology

| Area | Choice | Notes |
|---|---|---|
| App framework | **Flutter** (Dart) | One codebase for iPhone + Android; same stack as Debt Shredder. iOS builds on the Mac mini. |
| Local database | SQLite via `drift` | Typed queries, migrations. |
| Database encryption | SQLCipher (`sqlcipher_flutter_libs`) | Key stored in iOS Keychain / Android Keystore via `flutter_secure_storage`. The key must travel with the backup (section 6.13), or a restore can't be opened on a new phone. |
| Backup, iPhone | iCloud: CloudKit private database or the app's iCloud container | Needs the iCloud capability; user's own storage quota. |
| Backup, Android | Google Drive `appDataFolder` via `google_sign_in` + `googleapis` | Hidden app folder; `drive.appdata` scope. Android Auto Backup alone is too small (25 MB) for photos. |
| Photos | Files in the app's private documents folder | Never saved to the camera roll. Thumbnails cached. |
| App lock | `local_auth` | Face ID / Touch ID / fingerprint / device passcode. |
| Label scan | `google_mlkit_text_recognition` | On-device, offline, free on both platforms. |
| Health data | `health` package | Apple Health + Android Health Connect; read weight (optional write). |
| Notifications | `flutter_local_notifications` | Local only; no push server. |
| Charts | `fl_chart` | |
| PDF export | `pdf` + `printing` | |
| Zip backup | `archive` | |
| Purchases | RevenueCat (one-time "Pro" non-consumable) | Already set up for Debt Shredder; one-time works on both stores. |
| Crash reporting | Optional, opt-in only, no health data in reports | Decide later (section 12). |

No Firebase/Supabase backend and no Aloft server in v1. The only network use is the user's own iCloud / Google
Drive backup, Health sync and purchases.

---

## 4. Data model

All records have `id` (UUID), `createdAt`, `updatedAt`.

**Medication** (what the drug is)
- `name` (e.g. "Tirzepatide", "Zepbound", "NAD+"), `activeIngredient` (semaglutide | tirzepatide | liraglutide |
  dulaglutide | retatrutide | nad | b12 | lcarnitine | glutathione | lipoB | other), `isGlp1` (drives level chart),
  `form` (brandPen | compoundedVial | oral | other)
- `halfLifeHours`, `tmaxHours` (pre-filled from the built-in list for known drugs; editable; used only for the
  level chart)
- **Each medication has its own schedule** (e.g. Zepbound weekly on Thursday, NAD+ Mon/Wed/Fri):
  `scheduleType` (weekly | daysOfWeek | everyNDays | daily | asNeeded), `scheduleDays` (list of weekdays, for
  weekly or several days a week), `scheduleInterval` (for every N days), `times` (one or more times of day),
  `startDate`. Reminders, "due today" on Today, and missed-dose detection all use the medication's own schedule.

**Supply** (a specific vial or pen)
- `medicationId`
- `concentrationMgPerMl` (compounded vials) or `penDoseMg` (brand pens)
- `additives`: list of `{name, amount, unit, perMl}` (e.g. Cyanocobalamin 0.5 mg/mL)
- `volumeMl`, `pharmacy`, `lotNumber`, `dateOpened`, `beyondUseDate`, `cost`
- `labelPhotoIds` (from the scan), `status` (active | finished | discarded)

**Prescription** (optional, what the provider ordered)
- `medicationId`, `prescribedDose` + `unit` (units | mg | mL), `directionsText`, `startDate`, `endDate`

**Dose** (a logged shot)
- `supplyId`, `takenAt`, `amountEntered` + `unitEntered` (units | mL | mg)
- Calculated and stored at log time: `volumeMl`, `drugMg`, `additiveAmounts` (frozen so later edits to the supply
  don't rewrite history)
- `injectionPain` (optional number; Shotsy exports a "Pain Level")
- `injectionSite` (abdomen upper/lower × left/middle/right, thigh L/R, **back of upper arm** L/R, buttock L/R, custom),
  `syringeType` (U-100 default). Body map shows front sites plus the back-of-arm sites (drawn dashed, since they're
  on the back); rotation spans **all** medications so two shots never land on the same spot.
- `notes`, `skipped` (bool, for "skipped this week")

**Weight**: `measuredAt`, `kg` (displayed in user's unit), `source` (manual | appleHealth | healthConnect)

**Measurement**: `measuredAt`, `type` (waist | hips | chest | neck | upperArm | thigh | custom), `side`
(left | right | none), `customName`, `cm`

**SideEffect**: `occurredAt`, `type` (nausea, constipation, diarrhea, fatigue, headache / migraine, heartburn,
indigestion, stomach pain, belching / sulfur burps, injection-site reaction, low appetite, food noise, mood swings,
metallic taste, hair shedding, custom; covers every symptom Shotsy exports), `severity` 1–5, `medicationId`
(optional, "after which medication"), `notes`

**PhotoSet**: `takenAt`, `weightAtTime` (linked if logged that day), `photos`: list of
`{pose: front | side | back | custom, filePath, width, height}`, `notes`

**Reminder**: `type` (shot | weighIn | photo | reorder | beyondUseDate), `schedule`, `enabled`

**Settings**: units (lb/kg, in/cm), default syringe, app-lock on/off, goal weight (optional), start weight, start date

---

## 5. Dose math (core logic, must be unit-tested)

Insulin syringes in the US are **U-100**: 100 units = 1 mL, whatever the barrel size (0.3, 0.5 or 1 mL).

```
volumeMl  = units / 100
drugMg    = volumeMl × concentrationMgPerMl
units     = (drugMg / concentrationMgPerMl) × 100
additive  = volumeMl × additivePerMl      (for each additive)
```

Example: tirzepatide 10 mg/mL + cyanocobalamin 0.5 mg/mL, user draws 25 units
→ 0.25 mL → **2.5 mg tirzepatide** + 0.125 mg B12.

- The user can enter the dose in **units, mL or mg**; the other two are shown instantly with the math visible
  ("25 units = 0.25 mL = 2.5 mg").
- Brand pens: the dose is the pen's setting (e.g. Zepbound 5 mg); no conversion.
- Rounding: mg to 2 decimals, mL to 3, units to 1. Never round silently in stored values.
- **Mismatch warnings** (shown, never blocking):
  - Entered dose differs from the last dose by more than 50% → "This is different from your last dose (20 units).
    Double-check your label and prescription."
  - Entered dose differs from the saved prescription → same style of message.
  - Concentration changed between vials → when the user starts a new vial, show "Same mg dose is now X units" as
    information, worded as a conversion, not an instruction.
- Wording rule: say "X units **equals** Y mg," never "you should take" or "draw X units."

---

## 6. Features (v1)

### 6.1 Onboarding (≤ 2 minutes)
1. Welcome + privacy promise ("No account. We never see your data. Backed up to your own iCloud / Google Drive.").
   "Restore from iCloud / Google Drive" link for a new phone.
2. Medication: pick brand pen from a list, or "Compounded vial" → vial setup (6.2). Option to scan.
3. Schedule: day and time of shot (weekly default).
4. Starting weight (or import from Apple Health / Health Connect), optional goal.
5. Optional: take first progress photos now ("You'll be glad you did.").
6. Optional: turn on app lock and reminders.
7. Medical disclaimer acknowledgement (one screen, plain language).

### 6.2 Vial / pen setup
- **Brand pen:** choose the medication from a list, then **type the dose** (mg, units or mL). Never limit doses to
  preset buttons: split, micro and in-between doses must be as easy as standard ones (core reason the app exists).
- **Pill (oral GLP-1):** medication, **strength per pill** (typed, mg), **how many** (stepper, halves allowed),
  how often (daily default) and time. Never use "units" for pills: in Aloft "units" always means U-100 syringe
  units. Optional **wait timer** after taking (user sets the minutes from their own label; off by default), and
  **pills left** for reorder reminders. Logging a pill is one tap ("Took it"), editable for skipped/half doses.
- **Something else:** typed amount + user-chosen unit (mg, mcg, units, mL, tablets) + schedule. No level chart.
- **Compounded vial:** medication from a **picker** (below), concentration (mg/mL), additives (add rows: name +
  amount per mL, with common ones suggested), vial size, pharmacy, lot, opened date, beyond-use date, cost.
- **Compounded medication picker:**
  - GLP-1 (gets a level chart): semaglutide, tirzepatide, retatrutide, liraglutide
  - Add-on injections (logging + reminders, no level chart): NAD+, B12 (cyanocobalamin), L-carnitine,
    glutathione, lipo-B / MIC
  - Other: type any name
- **Same syringe vs separate shot:**
  - Ingredients **mixed in one vial** (e.g. tirzepatide + B12) = one medication; extras go in "Other ingredients"
    and are logged with every shot automatically.
  - A **separate injection** (e.g. Zepbound + an NAD+ vial, or Zepbound + B12 shots) = a second medication with its
    own setup, dose, schedule and reminders. Today lists each; "Log shot" asks which (or logs both the same day).
  - A second active medication is **Pro** (decided Nov 20, 2026; deliberate upgrade reason). Adding one shows the Pro
    screen with a line like "Track NAD+ alongside Zepbound with Pro."
- **Your dose** card (saved as the Prescription record): amount + unit switch (units / mL / mg), live conversion
  ("= 0.25 mL = 2.5 mg + 0.125 mg B12"), how often (weekly / every N days / daily) and shot day/time. Filled from the
  label or prescription scan when the directions are found. Pre-fills Log shot and drives doses-left and reorder.
  Note on the card: "Enter what your prescriber ordered. Aloft converts it but never suggests a dose."
- When the user logs a different amount twice in a row, ask "Update your usual dose?" (never change it silently).
- Shows: total mg in the vial and "about N doses at your dose."
- Multiple supplies per medication; one marked active. Starting a new vial asks whether the old one is finished.

### 6.3 Label / prescription scan
- Camera or photo library; multiple photos allowed (labels wrap around vials).
- On-device text recognition → parser looks for:
  - drug names (semaglutide, tirzepatide, brand names, common misspellings)
  - strength patterns: `\d+(\.\d+)?\s?mg\s?/\s?(1\s?)?ml`, `mg per ml`, `mcg/mL`, `units`
  - additive names (cyanocobalamin/B12, glycine, L-carnitine, pyridoxine/B6, NAD+, niacinamide)
  - volume (`\d+\s?mL`), lot (`LOT`), dates (`BUD`, `EXP`, `Use by`), pharmacy name line
  - directions ("inject X units / X mg … weekly")
- Fills the setup form; every scanned field is highlighted until the user confirms it. Nothing saves without review.
- Label photos are kept with the supply (viewable later, e.g. for recalls).
- Parser built and tested against real labels (need sample photos, see section 12).

### 6.4 Log a shot
- Home screen shows "Next shot: Thursday" or "Shot day!" with a big **Log shot** button.
- Pre-filled with: active supply, last dose amount, suggested next injection site (rotation), now as time.
- User can change amount (units/mL/mg), site (body map), time, add note.
- Live conversion line + mismatch warnings (section 5).
- "Skip this week" option (records a skipped dose, keeps the schedule).
- After saving: supply remaining updates; brief confirmation; optional "How are you feeling?" side-effect prompt.

### 6.5 Supply tracking and reorder
- Remaining volume = vial volume − sum of logged doses (with a manual "adjust remaining" for spills/priming).
- "About N doses left at your current dose."
- Reminders: reorder when ≤ N doses left (default 2); beyond-use date approaching (7 days before).

### 6.6 Medication level chart
- Estimated drug amount in the body over time from logged doses, using a one-compartment model with first-order
  absorption and elimination (half-life + Tmax per drug).
- Built-in defaults (editable): semaglutide t½ ≈ 7 days, Tmax ≈ 1–3 days; tirzepatide t½ ≈ 5 days, Tmax ≈ 8–72 h;
  liraglutide t½ ≈ 13 h; dulaglutide t½ ≈ 5 days. **Verify against prescribing information before release.**
- Shows past + projected curve to the next scheduled dose; overlays weight and side effects.
- Clearly labelled "Estimate for illustration only, not a blood level."
- Handles switching drugs (e.g. Zepbound → compounded tirzepatide): same active ingredient continues one curve.
- **Oral and injected doses are never combined** on one curve (oral semaglutide absorbs only a small fraction, so
  7 mg by mouth ≠ 7 mg injected). Pills get their own curve or a simple "taken daily" streak; "something else"
  medications get no curve.

### 6.7 Weight and measurements
- Manual entry or sync from Apple Health / Health Connect (read; writing back is optional).
- Charts: weight over time with dose changes marked, moving average, total change, change since last dose increase.
- Measurements: **waist** (the suggested main one, shown first with a "where to measure" figure), hips, chest,
  neck, upper arm and thigh (each with a left/right choice that's remembered), plus custom ones the user names
  (e.g. under bust, calf). Every field is optional. Each shows change since the comparison date. An "i" button
  explains where to measure so it's the same spot each time. Optional reminder every 4 weeks, on the same day as
  the photo reminder. Units follow the in/cm setting.
- Logging: a **+ button on Today** opens a quick-add menu (shot or dose, weight, side effect, measurements, progress
  photos, note); tapping the Weight card opens weight entry directly. Weight entry shows change since the last
  weigh-in and since starting, and can save to Apple Health / Health Connect.
- Optional goal weight and BMI (BMI shown only if the user enables it).

### 6.8 Side effects
- Quick-log chips + severity 1–5 + notes.
- Timeline view; overlay on the level chart (e.g. nausea vs. days after the shot).

### 6.9 Progress photos
- Poses: front, side, back (+ custom). Guided capture with a **faint outline of the previous photo** in that pose
  for consistent framing; optional 3- or 10-second timer for hands-free.
- Import existing photos with their original date (from EXIF or a date the user picks), so people can backfill
  their start.
- Gallery by date; each set shows weight on that day.
- **Compare:** pick two dates → side-by-side or swipe slider.
- **Timelapse (Pro):** builds a short video or GIF from one pose over time; saved only when the user exports it.
- Photos live only in the app's private storage, behind app lock; never in the camera roll unless the user exports.
- Optional photo reminder (e.g. every 4 weeks).

### 6.10 Reminders
- Shot reminders **per medication**, following each one's own schedule (e.g. NAD+ Mon/Wed/Fri 9 AM and
  Zepbound Thu 8 PM); weigh-in (optional), photo day (optional), reorder and beyond-use date per supply.
- All local notifications, all off-able, none about water/food.

### 6.11 Export and import
| Format | Contents | Free / Pro |
|---|---|---|
| **JSON** | Complete data (everything except photo files), versioned schema | Free |
| **Backup zip** | JSON + photos folder + manifest; optional password (AES) | Free |
| **CSV** | Separate files: doses, weights, measurements, side effects | Pro |
| **PDF report** | Date range; meds/doses table, weight chart, side-effect summary, optional photos | Pro |

Import:
- Backup zip or JSON → full restore (choose: replace all, or merge and skip duplicates).
- **Shotsy (1.0):** its CSV export is detected by its header and imported directly (shots with mg dose, time and
  site; weights; notes; side effects), with a preview and duplicate check. Full mapping:
  [docs/shotsy-import.md](docs/shotsy-import.md).
- **Any CSV (1.5):** column-mapping screen (date, dose, unit, weight, etc.), preview, duplicate detection.
- All imports are free.
- **Import check:** after a Shotsy import, the totals Aloft shows (number of shots, date range, weight change) should
  match the "Shotsy Summary" PDF the user can export from Shotsy. Use that as an acceptance test.

**PDF report for your provider (Pro)**, designed after reviewing Shotsy's 2-page summary PDF (Nov 20, 2026). Shotsy's
is a picture of a chart, saved as images, so it can't be searched, copied or read by screen readers; it has no
dose table, injection sites or side effects, and it spends half a page on an empty nutrition chart. Aloft's report:
- **Real text, not images**, so it's searchable, copyable and accessible; Letter and A4.
- **Page 1 summary:** date range and length of treatment; current medication(s) and dose, including concentration
  and units for compounded vials and added ingredients; doses logged and missed; weight change (lb or kg and %),
  average per week, current BMI if enabled.
- **Chart:** estimated level curve with dose steps marked, plus the weight line, like Shotsy's but with labeled axes
  and dose-change markers.
- **Dose history table:** date, medication, dose (mg, and units/mL for compounded), injection site, notes; grouped
  by dose step so titration up and down is easy to see.
- **Side effects by medication** (counts and average severity) and **measurements** when logged.
- **Notes**, and optional progress photos (off by default).
- **Sections with no data are left out** (no empty charts). The user picks the date range and medications.
- Footer on every page: "Created with Aloft · personal tracking record, not medical advice."
- Manual exports go through the system share sheet (Files, Drive, email, etc.). The backup zip is also how to move
  between iPhone and Android, since iCloud and Google Drive backups don't cross platforms.

### 6.12 Privacy and security
- App lock (biometric/passcode) with optional "lock immediately" vs. "after 1 minute."
- Database encrypted at rest; photos in app-private storage.
- App switcher / recent apps view shows a blurred screen.
- No ads, no third-party analytics SDKs touching health data.
- Settings → "Delete all my data" (confirm twice), with a separate choice to also delete the cloud backup.

### 6.13 Automatic backup (free)
- **On by default** after onboarding (user can turn it off). iPhone → user's iCloud; Android → user's Google Drive
  hidden app folder (one-time "Sign in with Google" for Drive only; not an Aloft account).
- **Contents:** everything, including photos and label photos. **Excludes weights read from Apple Health / Health
  Connect** (they restore through Health itself), which also keeps Apple guideline 5.1.3 happy.
- **When:** shortly after changes (debounced), at most daily for photos on cellular; Wi-Fi preferred for photos.
  Incremental: each photo is uploaded once and shared by every snapshot.
- **All photos are always kept** in the app and in the backup. Nothing is ever removed unless the user deletes it.
  (Snapshot rotation below applies only to the data snapshot, never to photos.)
- **Snapshots** (a snapshot = a full copy of the data at one backup): keep copies spread over time so a mistake
  noticed later can still be undone:
  - **Latest** backup
  - one about **1 day** old
  - one about **1 week** old
  - one about **1 month** old
  Several backups in one day replace only the "latest" copy. The restore screen lists them by date
  ("Nov 20, 8:05 PM", "Nov 19", "Nov 13", "Oct 20"), with latest as the default.
- A photo the user deletes is removed from the backup only once no kept snapshot still includes it, so restoring an
  older snapshot also brings back photos deleted after it.
- **UI:** More → Export & backup: toggle, "Last backup: today, 8:05 PM," size, **Back up now**, **Restore**.
  Warn on Today screen if no successful backup in 7 days.
- **Restore:** onboarding "Restore from iCloud / Google Drive" → finds the latest snapshot → restores data + photos.
- **Optional backup password** (off by default): encrypts the backup end-to-end before upload so Apple/Google can't
  read it. Clear warning: "If you forget this password, your backup can't be opened. We can't reset it."
- **Encryption key:** without a backup password, the database key is stored in iCloud Keychain (iOS, synchronizable
  item) / included in the Drive backup wrapped by the user's Google account; with a password, the key is derived from
  the password. Must be tested by restoring onto a second device on both platforms before release.
- Cross-platform moves (iPhone ↔ Android) use the manual backup zip (6.11).

---

## 7. Screens and navigation

Bottom tabs:
1. **Today**: next shot countdown, Log shot button, current estimated level, latest weight, supply status.
2. **History**: chronological log of shots, weights, side effects, photos (filterable).
3. **Progress**: photos (gallery, capture, compare, timelapse).
4. **Charts**: level chart, weight, measurements, side effects.
5. **More**: medications and vials, reminders, export/import, app lock, units, Pro, about, disclaimer, support.

---

## 8. Free vs. Pro (proposal)

**Pricing (decided Nov 20, 2026):** three ways to get the same Pro, no ads ever:

| Plan | Price | Notes |
|---|---|---|
| Monthly | **$1.99/mo** | Auto-renews; $23.88 over a year |
| Yearly | **$14.99/yr** | Auto-renews; ~37% less than monthly; shown as the default/highlighted plan |
| Lifetime | **$29.99 once** | Same as 2 years of yearly; non-consumable |

- Set up in RevenueCat (already used for Debt Shredder): one "pro" entitlement, two auto-renewing subscriptions in
  one subscription group + one non-consumable. Lifetime buyers must never be shown subscription upsells.
- Positioning vs market (section 8.1): yearly is well under the usual $39.99/yr; lifetime is about a third of the
  $90–100 lifetime options.
- Store requirements for subscriptions: price, length and auto-renew terms on the paywall, links to Terms and
  Privacy, a Restore Purchases button, and "Manage subscription" in More.
- Family Sharing on for the lifetime purchase (and subscriptions if supported); enrol in Apple's Small Business
  Program / Google's 15% tier.
- Open: free trial on yearly (e.g. 7 days)?

**Feature split (decided Nov 20, 2026):**

| Free | Pro (monthly, yearly or lifetime) |
|---|---|
| Unlimited shot logging, units ⇄ mL ⇄ mg conversion, site rotation | Multiple active medications (e.g. GLP-1 + another injectable) |
| One active medication, unlimited vials, added ingredients, supply/reorder | Photo compare **slider** + **timelapse** |
| **Label / prescription scan** | PDF report for your provider |
| Medication level chart | CSV **export** |
| Weight, measurements, side effects, Health sync | Custom poses, unlimited photo sets per day |
| Progress photos: capture with outline, gallery, **side-by-side compare** | Future Pro features (widgets, watch, etc.) |
| Reminders, app lock | |
| Automatic iCloud / Google Drive backup, JSON export, backup zip | |
| **Imports**: backup, JSON, CSV, Shotsy | |

Rationale: the whole everyday tracker is free, including the things competitors charge for (level chart, photos,
backup) and the things that win switchers (label scan, Shotsy import, side-by-side compare). Pro is for sharing
with a provider, power users, and progress videos.

### 8.1 Competitor pricing (US App Store listings, checked Nov 20, 2026)
| App | Model | Prices | Notable |
|---|---|---|---|
| Shotsy (4.8, 35K) | Subscription | $9.99–14.99/mo, $39.99–59.99/yr | No account, iCloud; PDF + CSV; level chart reportedly paid |
| MeAgain (4.8, 41K) | Subscription | ~$10/mo, up to $119.99 | Compounded, progress photos, doctor PDF |
| Glapp (4.8, 1.1K) | Subscription | $4.99/wk, $9.99/mo, $39.99/yr | Level chart free; 3 free doctor reports |
| Pep (4.7, 984) | Subscription | ~$10/mo, ~$40/yr | Compounded, side-by-side progress photos |
| Glippy (4.8, 480) | **Completely free** | — | Compounded, PDF + CSV, no paywall |
| GLPeak (4.7, 162) | Subscription | $4.99/mo, $39.99/yr | Compounded vial math; photos paid |
| Pokii (4.7, 826) | Subscription | $2.99–10.99/mo, $24.99–59.99/yr | Compounded, photos, iCloud |
| Dozify | Subscription | $6.99/mo, $39.99/yr | No account; level chart, vials, photos all paid |
| Steady | Sub **or lifetime** | $4.99/mo or **$99.99 lifetime** | Photos free; compounded + reconstitution calculator |
| Simple GLP | Sub **or lifetime** | $9.99/mo, $39.99/yr, **$89.99 lifetime** | No account; CSV free |
| Easy GLP-1 Tracker | **One-time only** | **$4.99** | Free = 2 shots / 2 weeks |
| Cadence | Subscription | $1.99/mo, $12.99/yr | Level chart, PDFs paid |

Takeaways:
- **$39.99/yr is the going rate**; lifetime unlocks are rare and priced $90–100.
- Usually free: dose log, reminders, site rotation, weight, side effects. Usually paid: level chart, doctor PDF,
  multiple meds, vial/supply tracking, photos (varies), cloud sync.
- **Compounded support and progress photos are NOT unique** (MeAgain, Pep, Glippy, GLPeak, Pokii, Steady, Simple
  GLP). Aloft's edge has to be the combination: per-vial added ingredients, label scan (not seen elsewhere), free
  level chart + photos + backup, and a fair one-time price with no subscription.
- Free/paid split for Shotsy, MeAgain, Pep and Pokii isn't itemized on their listings; Google Play prices not checked.

---

## 9. Compliance and store requirements

**Apple**
- **1.4.2 (drug dosage calculators):** Aloft records and converts what the label/prescription says. No dose
  suggestions, titration plans or "increase to" prompts. Copy reviewed against this before submission.
- **5.1.3 (health data):** HealthKit data must not be stored in iCloud or used for advertising. The automatic iCloud
  backup therefore excludes anything read from Apple Health (it restores through Health itself); the user's own
  entries (shots, vials, photos, manual weights) are backed up, as other GLP-1 trackers do. Re-check the current
  guideline text before submission.
- HealthKit: request only weight (read, optional write); purpose strings in Info.plist; privacy policy URL.
- App Privacy label: "Data Not Collected" (if no analytics/crash reporting), otherwise declare accurately.

**Google Play**
- Health apps declaration + Health Connect permission declaration (weight read/write) with justification.
- Data safety form: no data collected or shared (if true at release).
- Health Connect requires a privacy policy explaining data use.

**Both**
- Medical disclaimer in onboarding, About, and store description: "Aloft is a personal tracking tool, not a medical
  device. It does not provide medical advice or tell you how much to take. Always follow your prescriber."
- Trademarks: brand names (Ozempic®, Wegovy®, Mounjaro®, Zepbound®) used only descriptively, with an "is a
  registered trademark of…; Aloft is not affiliated with…" line in the store listing and About screen.
- Pages on peaceofmindapps.com: `/aloft/`, `/aloft/privacy`, `/aloft/terms`.

---

## 10. Out of scope for all three planned releases

- Food, water, protein, calories, steps
- Aloft accounts, live sync between devices (backup/restore only), sharing with a provider portal
- AI (cloud) label scanning (possible opt-in later)
- Community, coaching, content articles
- Non-GLP-1 peptides as a focus (the "other" medication type allows them, but no marketing)

---

## 11. Releases and build plan

Decided Nov 20, 2026. Goal: get 1.0 into the owner's hands quickly (the owner is switching from Shotsy), then two
major releases.

### Release 1.0, MVP: "Track it right"
- Onboarding (all 6 steps; pen, compounded vial and pill paths), Today (incl. late/missed dose and first-day states),
  quick-add menu
- Log shot / log dose: units ⇄ mL ⇄ mg, added ingredients, site rotation incl. back of arm, typed doses only
- Vial/pen/pill setup **typed in (no scanning yet)**, compounded medication picker, supply + reorder reminders
- Per-medication schedules and reminders
- Weight (manual + Apple Health / Health Connect), side effects
- Progress photos: capture with outline, gallery, side-by-side compare
- History (with edit/delete), medication level chart
- **Import from Shotsy** (its CSV export, auto-detected; preview and duplicate check; see
  [docs/shotsy-import.md](docs/shotsy-import.md)), plus backup zip / JSON restore. **Moved into 1.0 at the owner's
  request** so the owner's Shotsy history comes over on day one.
- App lock, automatic iCloud / Google Drive backup + restore (tested on a second device), JSON + backup-zip export
- Settings (units, lock, reminders, Manage subscription, Restore purchases, Delete all data, disclaimer, terms,
  privacy, support) and My medications (change usual dose, finish/start vial, pause)
- **Pro at launch** ($1.99/mo, $14.99/yr, $29.99 lifetime): second medication + PDF report for your provider

### Release 1.5: "Smarter"
- Label / prescription scanning (on-device), built and tested against real labels
- **General CSV import** from any app or spreadsheet: column-matching screen, preview, duplicate check
  (Shotsy-specific import ships in 1.0; this is the "any CSV" version, decided Nov 20, 2026)
- Measurements screen + Charts Body and Effects tabs
- Dose-change history and "Update your usual dose?" prompt
- Pro additions: CSV export, compare slider

### Release 2.0: "Delight"
- Pro: timelapse, custom poses
- Home-screen widgets; possibly Apple Watch / Wear OS quick-log
- Optional backup password (end-to-end encrypted backups)
- Insights (e.g. side effects vs. level curve), iPad layout, more languages

### Build order for 1.0
1. **Foundation:** Flutter project, drift database + encryption, theme, settings, app lock.
2. **Medications + supplies + dose math** (unit tests for section 5), log shot / log dose, site rotation.
3. **Today, quick-add, History (edit/delete), schedules, reminders, supply tracking.**
4. **Weight, side effects, Health integration, level chart.**
5. **Progress photos:** capture with outline, gallery, side-by-side compare.
6. **Shotsy import and export/backup:** Shotsy CSV import per [docs/shotsy-import.md](docs/shotsy-import.md)
   (test against the owner's real export, kept out of git); JSON, zip, iCloud / Google Drive backup and restore.
7. **Pro + RevenueCat** (second medication, PDF report), store listings, privacy/terms pages, screenshots.
8. **Testing:** owner's own daily use (real shots, imported Shotsy history), TestFlight + Play closed testing,
   then submit.

---

## 12. Open questions

1. **Real label + prescription photos** (personal info blurred) to design and test the scanner.
2. Is the user's dose prescribed in **units, mg or mL**?
3. **Shotsy export:** does it have one, and in what format? (Sample file needed for the import preset.)
4. Pricing decided ($1.99/mo, $14.99/yr, $29.99 lifetime). Still open: exactly which features are Pro, and a trial.
5. Bundle ID / developer account: same as Debt Shredder (`com.shannonsonlinebookkeeping.aloft`) or a Peace of Mind
   Apps identity?
6. Crash reporting: none, or opt-in (e.g. Sentry with health data scrubbed)?
7. Trademark search for "Aloft" (USPTO classes 9 and 44; Marriott's Aloft hotels, aloft.ai) — not yet done.
8. Icon/brand direction: feather, balloon, upward curve? Colors?
9. Google Drive `drive.appdata` scope: confirm whether Google's OAuth app verification is needed before launch.
