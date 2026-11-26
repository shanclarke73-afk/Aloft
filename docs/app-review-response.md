# App Review: reply to "Guideline 2.1 - Information Needed" (Nov 26, 2026)

Apple rejected the Aloft 1.0 submission (ID d9aee207-bdcc-4dbf-a8e0-bd7e75323245, sent Nov 25) under
**2.1 Information Needed**. They found no bug. They want a screen recording plus answers to six questions in
the **App Review Information → Notes** field, and then a resubmission. The same build (7) can be resubmitted.

## 1. Screen recording (Shannon, on the iPad)

Record on the iPad with TestFlight **build 8**, updated to the latest iPadOS:
Settings → Control Center → add **Screen Recording**. Then swipe down from the top-right corner and tap the
record button. To start clean, delete Aloft and reinstall it from TestFlight first.

Apple wants the recording to **begin with launching the app**. Show, in order (aim for 3–5 minutes):
1. Tap the Aloft icon on the home screen.
2. Getting started: the welcome screen → "Bringing your history?" → **No, start fresh** → add a medication
   (for example, a compounded vial: type the concentration and dose) → starting weight → skip photos →
   app lock, shot-day reminder, and tick the medical disclaimer.
3. Today → **Log shot** → save. Then log a weight and a side effect.
4. History, then Charts (the estimated-level chart and its "estimate" label).
5. Progress: add a photo.
6. **Paid features:** More → Aloft Pro → show the three plans → buy one with a **sandbox / TestFlight**
   account (it costs nothing) → "You have Aloft Pro". Then show what Pro unlocks: More → Report for your
   provider (make the PDF), Backup and restore → Export as CSV, and adding a second medication.
7. More → Backup and restore → Save a backup file, then More → **Delete all my data** (it shows that the
   person can erase everything; there is no account to delete).

Upload the video somewhere that gives a link anyone can open without signing in. Apple doesn't take video
files in the Notes field. Google Drive with "Anyone with the link can view" works, as does an unlisted
YouTube video. Put the link at the top of the notes.

## 2. Notes text to paste (replaces the current review notes, under 4,000 characters)

```
SCREEN RECORDING (iPad, latest iPadOS, TestFlight build of 1.0 (8)): <PASTE LINK HERE>
It starts at launch and shows getting started, logging, charts, progress photos, buying Aloft Pro (sandbox) and the Pro features.

1. PURPOSE AND AUDIENCE
Aloft is a private, personal record-keeping app for adults who have been prescribed a GLP-1 medication (brand-name pens such as semaglutide or tirzepatide, compounded vials, or pills). It lets them log each dose, the injection site, weight, side effects and progress photos, and get reminders for shot days and refills. It solves a common problem for people on compounded vials: other trackers can't record a non-standard concentration or added ingredients. Users can also make a PDF summary to bring to their own healthcare provider.
Aloft does not calculate, recommend or adjust doses. The person types in what their prescriber and label say, and the app records what they logged. It does not sell or supply medication.

2. HOW TO USE IT (no login, no sample files needed)
- There is no account or sign-in. Open the app and follow "Getting started": choose "No, start fresh", add a medication by typing it in, enter a starting weight, then accept the medical disclaimer. Every other step can be skipped.
- Today: Log shot / Log dose, weight, side effects.
- History: all entries, with edit and delete.
- Charts: weight over time and an estimated medication level (clearly labelled as an estimate).
- Progress: progress photos, stored only inside the app, never in the photo library.
- More: My medications, reminders, app lock, Backup and restore, Delete all my data, About.
- Paid features (Aloft Pro): More > Aloft Pro. Plans: $1.99/month, $14.99/year (14-day free trial for new subscribers) or $29.99 lifetime. A sandbox purchase unlocks a second active medication, the PDF report (More > Report for your provider) and CSV export (More > Backup and restore). Restore purchases is on the same screen.
- The app has no user-generated content shared with others, no social features and no accounts, so there is nothing to report, block or delete beyond the person's own data (More > Delete all my data).

3. EXTERNAL SERVICES
- Apple App Store in-app purchases, handled through RevenueCat (purchase validation and entitlement only; it receives purchase history, not health data).
- No other services: no Aloft server, no login or authentication service, no analytics or crash reporting, no ads, no AI services, no third-party data providers. Health records, photos and reminders stay on the device (encrypted with SQLCipher and excluded from iCloud Backup). Backups are files the person saves themselves.
- The privacy policy, terms and support pages are at https://peaceofmindapps.com/aloft/

4. REGIONAL DIFFERENCES
The app works the same in every region where it is offered. Prices are Apple's local equivalents of the US prices. It is not offered in France at launch only because the French encryption declaration has not been filed yet.

5. REGULATED INDUSTRY / THIRD-PARTY MATERIAL
Aloft is a personal log, not a medical device, and it does not diagnose, treat, prescribe, dispense or give dosing advice. The disclaimer must be accepted during setup and is in More > About. Medication names are used only so people can identify what they take. The app is not affiliated with any drug manufacturer and shows no third-party logos. The estimated-level chart uses published half-life and time-to-peak figures from each medication's US prescribing information, with the source shown under the chart.
```

## 3. Then

1. App Store Connect → Aloft → version 1.0 → **App Review Information → Notes**: paste the text above
   with the link filled in, and save.
2. In the rejection message under App Review, reply briefly ("The requested information and screen recording
   have been added to the App Review notes."), swap the build to **8** in the version's Build section, then
   **Resubmit to App Review**.
