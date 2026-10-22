# School Pulse brand pack: Roof beat

Every logo, icon and identity file for School Pulse, built from the parent theme
(`design/tokens/school_pulse_theme.json`): Navy `#0E1B3D`, Royal `#1F4FD1`, Gold `#D4A017`.
The wordmark is set in Plus Jakarta Sans ExtraBold.

The folders are numbered and mirror your repo. Copy each folder's contents over the same path in the repo.
Logos, marks, splash images and state images are **transparent PNGs**. Launcher, store and
favicon icons have their **blue background**, as the platforms require. iOS and store icons are fully opaque (Apple rejects transparency).

| Folder | Copy to | What it is |
|---|---|---|
| `01_logo/` | `design/brand/` | Masters: mark, wordmark, horizontal and stacked lockups (light and dark, transparent), black/white marks, SVG sources |
| `02_replace_current_assets/` | wherever your current files with these names live (e.g. `assets/images/`) | **Same file names as your old logo files.** Delete the old ones and drop these in, no code changes needed |
| `03_flutter_assets/assets/branding/` | `assets/branding/` | In-app logos with `2.0x/` and `3.0x/`, state images, loading animation |
| `04_ios/Runner/Assets.xcassets/` | `ios/Runner/Assets.xcassets/` | `AppIcon.appiconset` (all 19 iPhone/iPad/App Store sizes + `Contents.json`) and `LaunchImage.imageset` |
| `05_android/app/src/main/res/` | `android/app/src/main/res/` | Launcher icons (legacy, round, adaptive with monochrome for Android 13 themed icons), notification icon, splash images including Android 12+ |
| `06_web/` | `web/` | `favicon.png`, `favicon.ico`, `favicon.svg`, `icons/Icon-192/512`, maskable icons, apple-touch icon (Flutter's default names) |
| `07_web_marketing/public/` | `web_marketing/public/` | Favicon, `icon.svg`, apple-touch icon, PWA icons, logos, `og-image.png` (link previews) |
| `08_store/` | App Store Connect / Play Console | 1024 App Store icon, 512 Play icon, 1024×500 Play feature graphic |
| `09_social/` | Social profiles | Profile pictures (blue and navy), X, LinkedIn and Facebook covers, link preview |
| `10_documents/` | Report cards, receipts, letters | High-res print logos and a faint watermark mark |
| `11_fonts/` | `assets/fonts/` (optional) | Plus Jakarta Sans 700/800 (SIL Open Font License) |

## In-app files (`assets/branding/`)

- `logo_mark_light.png` / `logo_mark_dark.png`: the mark for app bars and headers (96 px base, with 2x and 3x).
- `logo_horizontal_light.png` / `_dark.png` and `wordmark_light.png` / `_dark.png`: for the login screen and drawer header.
- `app_icon_rounded.png`: the app icon as an image, for About screens.
- `states/state_<name>_<light|dark>.png`, 160 px base with 2x and 3x. The names are `empty`, `loading`, `success`, `warning`, `error`, `offline`, `no_access` and `not_found`.
- `loading_light.gif` / `loading_dark.gif`: the pulse travels along the line. `loading/<scheme>/loading_00..23.png` holds the same 24 frames if you'd rather animate them in Flutter (about 40 ms per frame).

Add this to `pubspec.yaml` under `flutter:` → `assets:`:

```yaml
    - assets/branding/
    - assets/branding/states/
```

## Android notes

- The adaptive icon is `mipmap-anydpi-v26/ic_launcher.xml` (background, foreground, monochrome).
- Colours are in `values/school_pulse_brand_colors.xml`, which is a separate file, so your `colors.xml` is untouched.
- Use `@drawable/ic_notification` as the FCM default notification icon:
  `<meta-data android:name="com.google.firebase.messaging.default_notification_icon" android:resource="@drawable/ic_notification"/>`
  and `@color/notification_accent` as its colour.

## Regenerating instead of copying (optional)

If you use `flutter_launcher_icons` and `flutter_native_splash`, the two YAML files below produce the same result from the masters.
Put them in the repo root, then run `dart run flutter_launcher_icons` and `dart run flutter_native_splash:create`.

## Colours used

| Use | Hex |
|---|---|
| Launcher tile (gradient) | `#2E62EA` to `#173FB0`, flat fallback `#1F4FD1` |
| Navy tile / dark splash | `#0E1B3D` |
| Mark line on light | `#1F4FD1` |
| Mark line on dark | `#FFFFFF` |
| Bell dot | `#D4A017` |
| Wordmark on light | `#0E1B3D` |
