# Store forms: answers

_Shannon approved these answers, with the recommended option on all four decisions, on November 25, 2026. The table below says what has been entered so far. Where a form's own wording differed from the draft, the closest matching option was chosen and is noted._

## What has been entered (November 25, 2026)

| Store | Form | State |
|---|---|---|
| App Store | Age rating questionnaire | Entered through the API. Result: 12+ |
| App Store | Price | Free |
| App Store | Availability | 174 countries and regions; France off |
| App Store | Content rights | Does not use third-party content |
| App Store | Privacy labels | Published (Nov 25), entered in the browser: collects data; one type, Purchases (purchase history), used for Analytics and App Functionality, not linked to the user's identity, not used for tracking. Product page shows "Data Not Linked to You: Purchases" |
| App Store | Review contact | Entered by Shannon (Nov 25); sign-in required left off |
| Google Play | Privacy policy | Saved |
| Google Play | Ads | Saved: no ads |
| Google Play | Advertising ID | Saved: not used |
| Google Play | Government apps | Saved: no |
| Google Play | Financial features | Saved: none |
| Google Play | Health apps | Saved: "Nutrition and weight management" and "Medication and treatment management". Play asked for no regional details |
| Google Play | Trader status and Terms of Service | Saved: trader status applies; terms link added |
| Google Play | Sign in details | Saved by Shannon (Nov 25): restricted access, with the reviewer access code (kept in `~/AppStoreKeys/aloft-review-code.txt`, not in git) and the "full access" tick box, which is true now that build 6 accepts the code |
| Google Play | Target audience and content | Saved (Nov 25): 18 and over only. With only that age group chosen, Play asked no further questions. The optional "restrict users Google determines to be minors" box was left unticked |
| Google Play | Content ratings | Saved (Nov 25). Shannon agreed to IARC's Terms of Use; contact email is the business address. Category: All Other App Types. Every answer No except "users can purchase digital goods" (Yes; no random items). Ratings given: ESRB Everyone, PEGI 3, USK all ages, Brazil 14+, 3+ elsewhere. The questionnaire did not ask about references to medication |
| Google Play | Data safety | Saved (Nov 25), no longer a draft: purchase history collected (not shared, not ephemeral, required; App functionality and Analytics), encrypted in transit, no accounts, deletion can be requested at `https://peaceofmindapps.com/aloft/#support`. The store preview shows "No data shared with third parties" |

Play's App content page shows nothing left needing attention (Nov 25). Everything saved on Google Play is "saved, ready to send for review" in Publishing overview. Nothing has been sent for review.

### The Sign in details question

The draft said "all functionality is available without special access". The form words it differently: it asks whether **any part of the app is restricted**, and lists payments, subscriptions and biometric authentication as reasons to answer Yes. Aloft Pro is a paid tier, so the accurate answer is **Yes**. The form then wants instructions for reaching the restricted parts, and says Google's reviewers can't make purchases or use free trials.

Shannon chose to answer Yes and explain (Nov 25). When the explanation was entered, the form refused to save: it has a required tick box reading "Sign in details in this declaration provide full access to all the features and content within this app, including premium or paid content". That would be untrue, because the explanation gives no way into Pro without paying, so it was not ticked and nothing was saved.

What would make the tick box true:
1. **A reviewer code in the app** that switches Pro on for review, given in these instructions. Needs a new build. The code can be set per build (kept out of git, like the store keys) so it can be changed if it leaks.
2. **Make nothing paid at launch on Android**, which isn't the plan.

Shannon chose option 1. Build 6 accepts the code, and she saved the form on Nov 25; Target audience and the final Data safety save followed the same day.

## The facts the answers rest on

Checked against the code and the built app on November 25, 2026 (build 5):

- **No account, no sign-in, no ads, no analytics or crash-reporting library.**
- **What stays on the device:** medications, doses, weights, side effects, notes, photos and settings, in an encrypted database. Aloft has no server.
- **The one thing that leaves the device:** purchase information. RevenueCat (our service provider) gets an anonymous app ID and the store's purchase receipts, to tell whether Pro is active. Apple or Google handle the payment itself.
- **Android permissions in the built app:** internet, network state, notifications, start at boot (to re-set reminders), exact alarms (`SCHEDULE_EXACT_ALARM`, which the person switches on themselves), biometrics, vibrate, and Google Play billing. No advertising ID, no location, no contacts, no camera or photo-library permission (photos come through the system camera and photo picker).
- **iPhone:** camera, photo library (chosen photos only) and Face ID, each with its reason shown.
- **Audience:** adults prescribed a GLP-1 medication. Not directed at children.

## The four decisions (all approved as recommended, Nov 25)

1. **"Analytics" as a purpose for purchase history.** RevenueCat's own guidance says to tick both *App functionality* and *Analytics* for purchase history on both stores, because its dashboard shows charts of purchases. Aloft's privacy policy says "no third-party analytics or tracking tools", and the iPhone privacy manifest lists App functionality only. Recommended: tick both on the forms, add Analytics to the iPhone manifest, and add a sentence to the privacy policy ("RevenueCat also shows us totals of purchases, such as how many subscriptions are active"). The alternative is App functionality only.
2. **Data deletion request (Google Play).** Play asks whether people can ask for their data to be deleted. Aloft holds none of their records, and "Delete all my data" in the app removes everything on the device. The only data elsewhere is the anonymous purchase record at RevenueCat. Recommended: answer that deletion can be requested, and give the support page as the way to ask.
3. **Age.** Recommended: 18 and over on Google Play. On the App Store the questionnaire decides the rating; the answers below should give 12+ or higher because of the medical subject.
4. **Contact details for Apple's reviewer** (name, phone, email). These are Shannon's to type in.

## Google Play: the 11 declarations under App content

| # | Declaration | Draft answer |
|---|---|---|
| 1 | Privacy policy | `https://peaceofmindapps.com/aloft/privacy` |
| 2 | Ads | No, the app does not contain ads. |
| 3 | Sign in details (app access) | All functionality is available without special access. No sign-in exists. Note for the reviewer: Aloft Pro features are unlocked by an in-app purchase; everything else is free. |
| 4 | Content ratings | See the questionnaire below. |
| 5 | Target audience and content | Target age: 18 and over only. Not designed to appeal to children. |
| 6 | Data safety | See the section below. |
| 7 | Advertising ID | No, the app does not use an advertising ID. (The built app has no `AD_ID` permission.) |
| 8 | Government apps | No. |
| 9 | Financial features | None. The app offers no financial features. (In-app purchases through Google Play are not a "financial feature" in this form.) |
| 10 | Health apps | See the section below. |
| 11 | Trader status and Terms of Service | Trader status applies to this app, as for the account. Terms of Service: `https://peaceofmindapps.com/aloft/terms` |

### Content ratings questionnaire

- Category: **Utility, productivity, communication or other** (not a game, not social).
- Violence, blood, fear: **No**.
- Sexuality or nudity: **No**. (Progress photos are the person's own, stay on their device and are never shared by the app.)
- Language, humour: **No**.
- Controlled substances: **No** illegal drugs, alcohol or tobacco. The app is about prescription medication the person has already been prescribed. If the form has a question on references to medication or drugs, answer yes to **references to prescription medication, for record-keeping**, with no encouragement to use.
- Gambling: **No**.
- User-generated content, messaging between users, sharing location, buying digital goods: **No** to all except **digital purchases: Yes** (Aloft Pro).
- Is it a web browser or search engine, or mainly news or education: **No**.

### Data safety

- Does the app collect or share any of the required user data types? **Yes.**
- Is all of the user data collected encrypted in transit? **Yes.**
- Account creation: **the app does not let people create an account.**
- Can people ask for their data to be deleted? **Yes**, through the support page (decision 2).

Data types:

| Data type | Collected | Shared | Processed only in passing | Required or optional | Purposes |
|---|---|---|---|---|---|
| Financial info → **Purchase history** | Yes | No (RevenueCat is a service provider) | No | Required | App functionality, Analytics (decision 1) |

Everything else is **not collected**, because it never leaves the device: health info, fitness info, photos, files, personal info, location, contacts, messages, app activity, device or other IDs. Google's form defines "collected" as sent off the device, and Aloft's records are only stored locally.

### Health apps

- **Health features the app has:** medication and treatment management (logging doses, schedules, reminders), and nutrition and weight management (weight log and chart). The exact labels will follow the form.
- **Not selected:** medical device, clinical decision support, disease diagnosis, health research, anything involving a healthcare provider or health records.
- **If asked whether it is a regulated medical device:** No. Aloft records what the person enters and never recommends, calculates or adjusts a dose. The unit conversion shows arithmetic on the numbers printed on their own label.
- **If asked about Health Connect:** not used in 1.0.

### Not asked for, so nothing to do

- **Exact alarms.** Play's separate declaration is for `USE_EXACT_ALARM`. Aloft uses `SCHEDULE_EXACT_ALARM`, which people switch on themselves in Android settings, and Play is not asking for a declaration.
- **Photo and video permissions, location, foreground services, all-files access:** none of these are in the app.

## App Store

### App privacy ("nutrition labels")

- Do you or your third-party partners collect data from this app? **Yes.**
- Data type: **Purchases → Purchase History.**
  - Used for: **App Functionality**, and **Analytics** (decision 1).
  - Linked to the person's identity? **No** (RevenueCat's ID is anonymous and nothing ties it to a name or email).
  - Used for tracking? **No.**
- Nothing else is collected: no health data leaves the device, and there are no identifiers, usage data or diagnostics.

The result on the store page should read "Data Not Linked to You: Purchases".

### Age rating questionnaire

- Medical or treatment information: **Infrequent/Mild**. (It is a tracker for a prescribed medication; it gives no treatment advice.)
- Health or wellness topics, if asked: **Yes**.
- Alcohol, tobacco or drug use or references: **None**.
- Violence, sexual content, nudity, profanity, horror, gambling, contests: **None**.
- Unrestricted web access: **No** (links open in the browser).
- User-generated content, messaging, advertising: **No**.
- In-app purchases: handled separately by Apple, not part of the rating.

### Other App Store items

| Item | Draft answer |
|---|---|
| Price | Free, with in-app purchases |
| Availability | All countries and regions except France (decided Nov 23) |
| Content rights | Does not contain, show or access third-party content |
| Encryption (each build) | Standard encryption algorithms; not available in France |
| Regulated medical device, if asked | No |
| Copyright line | © 2026 Shannon's Online Bookkeeping (to confirm the exact legal name) |
| Review contact | Shannon to enter (decision 4) |
| Sign-in required for review | No |
