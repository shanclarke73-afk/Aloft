# Shotsy import (Release 1.0)

Based on a real Shotsy CSV export examined Nov 20, 2026 (owner's own data; the file itself is never committed).
Examples below are made up and only show the format.

## File format

- CSV, UTF-8, comma separated, header row, a blank line at the end.
- Text columns are quoted (`"2025-05-06"`); the symptom columns are unquoted and can be empty (`,,,`).
- **One row per calendar date.** A row can hold a shot, a weight, notes, or any mix. No duplicate dates.
- Rows are in date order, oldest first.

| Column | Example | Meaning |
|---|---|---|
| `Date` | `2025-05-06` | ISO date, no time zone |
| `Shot` | `Tirzepatide 5.0 mg` | Medication name + dose in **mg**. Empty when no shot that day. |
| `Time` | `20:40` | 24-hour local time of the shot. Empty when no shot. |
| `Site` | `Left Thigh`, `Stomach - Upper Right` | Injection site (values below) |
| `Shot Notes` | free text | Note on the shot |
| `Pain Level` | `0` | Injection pain. Only `0` seen so far, so the scale's maximum is unknown. |
| `Recorded Weight (lbs)` | `187.80` | Weight in pounds, 2 decimals. Empty when not weighed. Can appear on shot rows too. |
| `Calories`, `Protein`, `Water` | | Food and water tracking (Aloft doesn't track these) |
| `Day Notes` | `felt great today ` | Free-text note for the day (may have trailing spaces) |
| 15 symptom columns | | `Nausea, Heartburn, Food Noise, Suppressed Appetite, Constipation, Diarrhea, Belching, Injection Site Reaction, Mood Swings, Indigestion, Metallic Taste, Stomach Pain, Hair Loss, Fatigue, Migraine`. **All empty in the sample**, so the value format (severity number? yes/no?) is not confirmed yet. |

Example (made up):
```
Date,Shot,Time,Site,Shot Notes,Pain Level,Recorded Weight (lbs),Calories,Protein,Water,Day Notes,Nausea,...,Migraine
"2025-01-06","Tirzepatide 2.5 mg","19:00","Right Arm","","0","210.00","","","","",,,...,
"2025-01-08","","","","","","209.20","","","","",,,...,
```

### Site values seen → Aloft site
| Shotsy | Aloft |
|---|---|
| `Left Arm` / `Right Arm` | Back of upper arm, left / right |
| `Left Thigh` / `Right Thigh` | Thigh, left / right |
| `Stomach - Upper Left` / `Upper Right` | Abdomen, upper left / upper right |
| `Stomach - Lower Left` / `Lower Right` | Abdomen, lower left / lower right |
| `Stomach - Upper Mid` | Abdomen, upper middle (**new site needed in Aloft**) |
| anything else | Custom site with the original text |

## How each row is imported

1. **Detect Shotsy** by the header (`Date,Shot,Time,Site,...,Recorded Weight (lbs)`); otherwise fall back to the
   general CSV column-matching screen.
2. **Shot** (when `Shot` is not empty):
   - Parse `"<name> <number> mg"` → medication name + dose in mg. Unknown formats become a note, not an error.
   - Ask once per medication name found: *"Tirzepatide: brand pen (Mounjaro / Zepbound) or compounded vial?"*
     For a compounded vial, optionally ask its strength (mg/mL) so units can be shown; otherwise store mg only
     and mark the shots "imported (mg only)".
   - Date + `Time` → local date-time. Site → mapping above. `Shot Notes` → dose note.
     `Pain Level` → injection pain (store the number as-is).
3. **Weight** (when `Recorded Weight (lbs)` is not empty): weight entry on that date (no time; date-only),
   converted from lb. A row with both a shot and a weight creates both.
4. **Day Notes** → a note on that date (trim spaces).
5. **Symptoms** → side-effect entries on that date once the value format is confirmed (see open items).
6. **Calories / Protein / Water** → skipped (Aloft doesn't track food); the preview says how many were skipped.
7. **Dose history**: dose changes found in the shots (e.g. 2.5 → 5 → 7.5 → 5 mg) become the medication's
   dose-change history, and the most recent dose becomes the usual dose (user confirms).
8. **Gaps** between shots are not turned into "missed" entries; history before import is shown as-is.

## Preview screen (before anything is saved)

- Summary: date range, number of shots, weights, notes and side effects to import, and what's skipped.
- Medication question(s) from step 2.
- Duplicates: a shot on the same date with the same medication and dose, or a weight on the same date with the
  same value, is skipped and counted.
- Import → History, charts and the level curve fill in from the first imported shot.

## Robustness checklist (unit tests)
- BOM at file start, quoted and unquoted fields, empty trailing columns, blank last line, trailing spaces
- `5.0 mg` and `5 mg`, decimal comma in other locales, other medication names (Semaglutide, brand names)
- Rows with only notes; rows with a shot and weight; unknown site text
- Re-importing the same file twice adds nothing

## Open items
- [ ] Get a Shotsy export with **side effects** filled in to confirm the symptom value format.
- [ ] Confirm the `Pain Level` scale (0–10?) and how Shotsy exports **brand vs compounded** medications and
      other drugs (semaglutide, pills, multiple medications).
- [ ] Check whether Shotsy exports photos or measurements in another file.
