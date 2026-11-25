# Store listing text (draft)

_Draft of November 24, 2026. Nothing here has been entered into either store yet. Shannon approves the wording first._

Rules this draft follows:
- No brand names of medications (Ozempic, Wegovy, Zepbound, Mounjaro and so on) anywhere. Both stores reject other companies' trademarks in titles and keywords, and they are risky in descriptions. Generic names (semaglutide, tirzepatide) are used instead.
- No medical claims. Aloft tracks; it never advises a dose and never promises weight loss.
- Only features that are in 1.0. No Apple Health, no automatic cloud backup, no widgets.

## Both stores

| Field | Text | Limit |
|---|---|---|
| App name | Aloft: GLP-1 Tracker | 30 |
| Support page | https://peaceofmindapps.com/aloft/ | |
| Privacy policy | https://peaceofmindapps.com/aloft/privacy | |
| Category | Health & Fitness (second choice: Medical) | |

## App Store

**Subtitle** (30): `Shots, weight & progress pics`

**Promotional text** (170): `A private tracker for your GLP-1 shots, weight and progress photos. No account, and your records stay on your device.`

**Keywords** (100, comma-separated, no spaces):
`semaglutide,tirzepatide,shot,injection,weight,log,dose,compounded,vial,pen,peptide,reminder,photo`

**Description**

```
Aloft is a private tracker for people taking a GLP-1 medication. Log each shot or pill, watch your weight, and see how far you've come, all in one place.

WORKS WITH HOW YOU TAKE IT
• Brand-name pens, compounded vials and pills
• Type in your own vial: strength, added ingredients, and the dose in units, mL or mg, with the math shown
• Weekly, daily or your own schedule

LOG IN SECONDS
• One tap to log a shot, with the injection site and how it felt
• Site rotation so you can see where you injected last
• Late or skipped a dose? Record what happened so your history stays right

SEE YOUR PROGRESS
• Weight in lb or kg, with your change since last time and since the start
• Goal weight and BMI
• Progress photos, kept inside Aloft and never in your camera roll
• Compare two days side by side
• An estimated medication level chart for semaglutide, tirzepatide, liraglutide and dulaglutide

STAY ON TRACK
• Reminders for shot days
• Reorder reminder when you are down to two doses, and a use-by date reminder for each vial
• Track side effects and see them in your history

PRIVATE BY DESIGN
• No account and no sign-up
• Your records are encrypted and stay on your device. We never see them.
• Lock Aloft with Face ID, Touch ID or your passcode
• Save your own backup file whenever you like, with an optional password

MOVING FROM ANOTHER APP?
Bring in your history from a Shotsy CSV export.

ALOFT PRO
Tracking, photos, reminders and backup are free. Aloft Pro adds:
• More than one medication at the same time
• A PDF report for your provider
• Spreadsheet (CSV) export

Pro is $1.99 a month, $14.99 a year with a 14-day free trial for new subscribers, or $29.99 once for lifetime. Prices are in US dollars and vary by country. Subscriptions renew automatically until cancelled. Cancel any time in your App Store account settings, at least 24 hours before the renewal date.

Aloft is a tracking tool, not medical advice. It never tells you how much to take. The medication level chart is an estimate from published averages, not a measurement of your body. Always follow your prescriber's instructions.

Terms of use: https://peaceofmindapps.com/aloft/terms
Privacy policy: https://peaceofmindapps.com/aloft/privacy
```

**Review notes** (for Apple's reviewer)

```
Aloft is a record-keeping app for people prescribed a GLP-1 medication. It does not calculate, recommend or adjust doses: the person types in what their prescriber told them, and the app records what they logged.

No account or sign-in is needed. All records are stored encrypted on the device (SQLCipher) and are excluded from iCloud Backup.

The "estimated level" chart uses half-life and time-to-peak figures from each medication's US prescribing information and is labelled as an estimate everywhere it appears.

To try Aloft Pro: More > Aloft Pro. The yearly plan has a 14-day free trial for new subscribers.
```

## Google Play

**Short description** (80): `Private tracker for GLP-1 shots, weight and progress photos. No account needed.`

**Full description** (4000): the App Store description above, with two changes:
- "Lock Aloft with Face ID, Touch ID or your passcode" becomes "Lock Aloft with your fingerprint, face or screen lock"
- "Cancel any time in your App Store account settings" becomes "Cancel any time in Google Play under Payments & subscriptions"

## Still to decide or check

- **"this phone" wording.** The app says "phone" in about 68 places. On an iPad that reads oddly. Options: leave it for 1.0, or change it to say "iPad" or "tablet" on those devices.
- The free trial line assumes the App Store trial is set up the same as Play's (it is: 2 weeks, new subscribers only).
- Trademark search for "Aloft" before the name goes public.
- Screenshots need made-up data. There is no demo mode yet: either add one for screenshot builds, or load a made-up backup file.
