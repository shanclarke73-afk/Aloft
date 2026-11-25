#!/usr/bin/env python3
"""Turns the raw simulator captures in raw/ into captioned store images.

Run from anywhere:  python3 store/screenshots/compose.py
Needs Google Chrome (used headless to draw each image at its exact pixel size).
Captions live in CAPTIONS below. Output goes to app-store/<device>/ and play/.
It also draws the Google Play feature graphic (play/feature-graphic.png).
"""
import pathlib, subprocess, tempfile

HERE = pathlib.Path(__file__).resolve().parent
FONT = HERE.parent.parent / "app/assets/fonts/PlusJakartaSans.ttf"
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

CAPTIONS = {
    "1-today": "Know when your next shot is due",
    "2-logshot": "Units, mL or mg, with the math shown",
    "3-history": "Every shot, weight and side effect in one place",
    "4-charts": "See how far you’ve come",
    "5-pro": "Tracking stays free. Pro adds the extras.",
}

# width/height: the store's required size. shot_w: how wide the app is drawn.
# crop: (left, width, top) of the raw capture to keep: the iPad's centred column, without
# the status bar, whose clock and app name would be cut in half by the column's edges.
DEVICES = {
    # Google Play: at most twice as tall as wide, so the tall phone capture goes on a 9:16 image.
    "android-phone": dict(prefix="android", out="play/phone", width=1080, height=1920, raw_w=1280, raw_h=2856, font=88,
                          pad=72, top=400, shot_w=880, radius=64, crop=None),
    "iphone-6.9": dict(prefix="iphone", width=1320, height=2868, font=112, pad=96, top=560, shot_w=1080, radius=84, crop=None),
    "ipad-13": dict(prefix="ipad", width=2064, height=2752, font=132, pad=160, top=560, shot_w=1500, radius=64, crop=(392, 1280, 44)),
}

PAGE = """<!doctype html><meta charset="utf-8"><style>
@font-face {{ font-family: Jakarta; src: url('{font}'); font-weight: 200 800; }}
html, body {{ margin: 0; width: {width}px; height: {height}px; overflow: hidden; }}
body {{ background: linear-gradient(165deg, #1E3557 0%, #1B4D63 55%, #217A80 100%); font-family: Jakarta, sans-serif; }}
h1 {{ position: absolute; left: {pad}px; right: {pad}px; top: 0; height: {top}px; margin: 0; display: flex;
     align-items: center; justify-content: center; text-align: center; color: #fff; font-weight: 800;
     font-size: {size}px; line-height: 1.12; letter-spacing: -0.02em; text-wrap: balance; }}
.shot {{ position: absolute; top: {top}px; left: {left}px; width: {shot_w}px; height: {shot_h}px; overflow: hidden;
        border-radius: {radius}px; box-shadow: 0 40px 120px rgba(0,0,0,.35); background: #F6F8FB; }}
.shot img {{ display: block; width: {img_w}px; margin-left: {img_left}px; margin-top: {img_top}px; }}
</style><h1>{caption}</h1><div class="shot"><img src="{src}"></div>"""


def main():
    for device, d in DEVICES.items():
        out = HERE / d.get("out", f"app-store/{device}")
        out.mkdir(parents=True, exist_ok=True)
        for key, caption in CAPTIONS.items():
            raw = HERE / "raw" / device / f"{d['prefix']}-{key}.png"
            if not raw.exists():
                continue  # not every screen is captured on every device
            raw_w, raw_h = d.get("raw_w", d["width"]), d.get("raw_h", d["height"])
            scale = d["shot_w"] / (d["crop"][1] if d["crop"] else raw_w)
            html = PAGE.format(
                font=FONT.as_uri(), size=d["font"], width=d["width"], height=d["height"], pad=d["pad"], top=d["top"],
                caption=caption, left=(d["width"] - d["shot_w"]) // 2, shot_w=d["shot_w"],
                shot_h=round(raw_h * scale), radius=d["radius"], img_w=round(raw_w * scale),
                img_left=-round(d["crop"][0] * scale) if d["crop"] else 0,
                img_top=-round(d["crop"][2] * scale) if d["crop"] else 0, src=raw.as_uri(),
            )
            with tempfile.NamedTemporaryFile("w", suffix=".html", delete=False) as f:
                f.write(html)
            target = out / f"{d['prefix']}-{key}.png"
            draw(f.name, target, d["width"], d["height"])
    feature_graphic()


def draw(html_file, target, width, height):
    subprocess.run(
        [CHROME, "--headless=new", "--disable-gpu", "--hide-scrollbars", "--force-device-scale-factor=1",
         f"--window-size={width},{height}", f"--screenshot={target}", pathlib.Path(html_file).as_uri()],
        check=True, capture_output=True,
    )
    pathlib.Path(html_file).unlink()
    print("wrote", target.relative_to(HERE))


FEATURE = """<!doctype html><meta charset="utf-8"><style>
@font-face {{ font-family: Jakarta; src: url('{font}'); font-weight: 200 800; }}
html, body {{ margin: 0; width: 1024px; height: 500px; overflow: hidden; }}
body {{ background: linear-gradient(120deg, #1E3557 0%, #1B4D63 55%, #217A80 100%); font-family: Jakarta, sans-serif;
       display: flex; align-items: center; justify-content: center; gap: 56px; color: #fff; }}
img {{ width: 220px; height: 220px; border-radius: 48px; box-shadow: 0 20px 60px rgba(0,0,0,.35); }}
h1 {{ margin: 0; font-size: 104px; font-weight: 800; letter-spacing: -0.02em; line-height: 1; }}
p {{ margin: 18px 0 0; font-size: 36px; font-weight: 500; opacity: .92; }}
</style><img src="{icon}"><div><h1>Aloft</h1><p>From titration to thriving.</p></div>"""


def feature_graphic():
    out = HERE / "play"
    out.mkdir(parents=True, exist_ok=True)
    icon = HERE.parent.parent / "brand/ios-appstore-1024.png"
    with tempfile.NamedTemporaryFile("w", suffix=".html", delete=False) as f:
        f.write(FEATURE.format(font=FONT.as_uri(), icon=icon.as_uri()))
    draw(f.name, out / "feature-graphic.png", 1024, 500)

if __name__ == "__main__":
    main()
