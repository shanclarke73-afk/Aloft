# Aloft mockups

Static screen designs for Aloft v1 (sample data, not real). Copied from the design canvas on November 20, 2026.

- **Live canvas (source of truth, editable):** https://claude.ai/artifact/Lzbyu8ZRQ8LN998PQqeayh
- **View here:** download or clone the repo and open `index.html` in a browser to see every screen side by side.
  Each `*.dc.html` file also opens on its own (390 × 844, iPhone size).

| File | Screen |
|---|---|
| `Onboarding.dc.html` | 1. Welcome |
| `OnbMedication.dc.html` | 2. What are you taking? |
| `OnbDose.dc.html` | 3. Dose & schedule (brand pens, typed dose) |
| `OnbDosePill.dc.html` | 3. Dose & schedule (pills: strength per pill, how many, wait timer) |
| `OnbWeight.dc.html` | 4. Starting weight |
| `OnbPhotos.dc.html` | 5. Starting photos |
| `OnbFinish.dc.html` | 6. Privacy, reminders, disclaimer |
| `Main.dc.html` | Today |
| `MainTwoMeds.dc.html` | Today with two medications (Zepbound + NAD+, Pro) |
| `LogShot.dc.html` | Log a shot (units ⇄ mL ⇄ mg, injection site) |
| `LogShotTwoMeds.dc.html` | Log a shot with two medications (pick which, shared site rotation, Pro) |
| `VialSetup.dc.html` | New vial from label scan, incl. "Your dose" |
| `VialSetupTwoMeds.dc.html` | Adding NAD+ as a second medication (own dose and Mon & Thu schedule, Pro) |
| `Charts.dc.html` | Medication level + weight |
| `ChartsTwoMeds.dc.html` | Charts with two medications (GLP-1 level, add-on doses taken, side effects by med, Pro) |
| `PhotoCapture.dc.html` | Progress photo capture with outline |
| `PhotoCompare.dc.html` | Progress compare |
| `PhotoCompareTwoMeds.dc.html` | Progress compare with "What you were taking" medication timeline (Pro) |
| `History.dc.html` | History timeline |
| `HistoryTwoMeds.dc.html` | History with two medications (color per medication, filter chips, Pro) |
| `Export.dc.html` | Export & backup (automatic iCloud / Google Drive backup) |
| `ExportTwoMeds.dc.html` | Export & backup with two medications (choose medications for PDF/CSV, Pro) |
| `Paywall.dc.html` | Aloft Pro upgrade ($1.99/mo, $14.99/yr, $29.99 lifetime) |
| `canvas.json` | Canvas layout (positions of the screens) |

These are design references for the Flutter build, not app code. If the canvas changes, copy the files again so
this folder stays in sync.

Colors: ink `#12263A`, primary `#1F5F8F` / `#2F6FA3`, background `#F6F8FB`, accent peach `#E07A4F`,
success `#1E6B3C`. Fonts: Plus Jakarta Sans (headings), Inter (body).
