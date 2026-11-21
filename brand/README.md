# Aloft brand: app icon

Chosen Nov 20, 2026: **J · Summit trail**. A teal peak on navy with a dotted trail climbing to a peach flag:
a journey, step by step, toward a goal. (Concepts and earlier rounds are on the design canvas:
https://claude.ai/artifact/Lzbyu8ZRQ8LN998PQqeayh)

| File | Use |
|---|---|
| `icon-master.svg` | Master artwork, full-bleed square (the OS rounds the corners). Edit this one. |
| `ios-appstore-1024.png` | iOS app icon / App Store (1024×1024, no transparency) |
| `play-store-512.png` | Google Play listing icon (512×512, no transparency) |
| `android-foreground.svg` / `-432.png` | Android adaptive icon foreground layer (108dp canvas, transparent; flag and peak sit inside the 72dp visible area) |
| `android-background.svg` / `-432.png` | Android adaptive icon background layer (solid navy) |
| `icon-rounded.svg` / `-1024.png` | Rounded version for the website, store screenshots and documents |

Colors: navy `#1D3557` (background), teal `#3E8E8A` / shade `#2F6F6C` (mountain), sand `#F4E3CC` (trail),
off-white `#F4EDE4` (flag pole), peach `#E8956B` (flag).

In Flutter, generate all platform sizes from these with `flutter_launcher_icons`
(`image_path: brand/ios-appstore-1024.png`, `adaptive_icon_background: "#1D3557"`,
`adaptive_icon_foreground: brand/android-foreground-432.png`).
