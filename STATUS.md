# Aloft: where we stand

_Last updated: November 20, 2026 (planning done; release plan set; no code yet)_

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

## Next time
1. Export your data from Shotsy (CSV or whatever it offers) and save it in `samples/` in this folder.
   That folder is git-ignored, so health data never goes to GitHub. The 1.0 importer is built from it.
2. Decide whether the app screens should switch to the icon's navy + teal palette (icon chosen: Summit trail,
   files in [brand/](brand/)).
3. Mock up the remaining 1.0 screens: Settings, My medications, Log side effect, edit/delete entry,
   late/missed dose and first-day Today, lock screen.
4. Answer the remaining open questions in SPEC section 12 (dose unit on your label, bundle ID, crash reporting).
5. USPTO trademark search for "Aloft" (classes 9 and 44); pick a page (likely peaceofmindapps.com/aloft/).
6. Start 1.0 build step 1 (Flutter project + database + app lock) on the Mac mini.

## Not done / not verified
- No trademark check, no code yet.
- Shotsy's export format is unknown until a real export file is in `samples/`.
- Drug half-life/Tmax defaults in the spec must be checked against prescribing information before release.
