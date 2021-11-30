# flutter_ads_fd_test

Demo App to understand the impact of loading ads, on File Descriptor usage on
Android.

Ads are loaded through the `google_mobile_ads` plugin.

# Getting Started

No setup is required. After installing the dependencies, just run the app just
like any other Flutter app and interact with the UI:

```
flutter pub get
flutter run -d <device>
```

# Observations

Each loaded interstitial ad keeps ~3 file descriptors open. Each loaded
interstitial video ad keeps ~80 file descriptors open.

After disposing a loaded ad, file descriptors are not immediately closed. Only
after loading another ad, of the same type, are the file descriptors of
previously disposed ads closed. This could be related to the AdMob SDK doing
some kind of caching.
