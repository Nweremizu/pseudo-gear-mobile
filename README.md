# Pseudo Gear mobile app

Native Android shopping app built with Expo, React Native and TypeScript. Includes the Pseudo Gear logo, catalogue, product options, saved items, shared bag, Google sign-in, account and pay-on-delivery checkout.

## Setup

1. Run `npm ci`.
2. Copy `.env.example` to `.env` and configure the existing shop API and Supabase project. Use only the public publishable key, never a service-role key.
3. In Supabase Authentication redirect URLs, allow `pseudo-gear://auth/callback` and enable the existing Google provider.
4. Apply `supabase/mobile-cart-sync.sql` to the shop database to enable live bag revision notifications.

The mobile app uses the website's `/api/catalog`, `/api/account` and `/api/checkout` endpoints and the same customer accounts. Cart updates use Supabase Realtime, with refresh on resume and a 15-second recovery poll.

## Development

Run `npm start`, or `npm run android` with an Android emulator/device available.

## Build an APK

```sh
npm ci
npx expo prebuild --platform android
cd android
```

On Windows, run `gradlew.bat assembleRelease`; on macOS/Linux, run `./gradlew assembleRelease`.
The APK is generated at `android/app/build/outputs/apk/release/app-release.apk`.
Use a short physical checkout path on Windows to avoid native CMake/Ninja path-length limits. The generated Android project is ignored. Configure a production signing key separately before publishing to Google Play.

## Verification

The app has been built, installed and launched on the Pixel 6 emulator. Native Google login and shared-cart updates were exercised during development. The latest APK also includes Android status-bar/notch spacing. Physical-device testing has not been performed.
