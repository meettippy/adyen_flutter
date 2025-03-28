<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 90 30" width="100">
  <path d="M27.7851 18.5234H26.0557C25.555 18.5234 25.1454 18.1138 25.1454 17.6131V6.622H21.7093C19.957 6.622 18.5234 8.05563 18.5234 9.80784V19.3198C18.5234 21.0721 19.957 22.5057 21.7093 22.5057H34.4071V0H27.7851V18.5234ZM12.6978 6.6221H0.22756V10.5816H8.35145C8.85209 10.5816 9.26169 10.9913 9.26169 11.4919V18.5235H7.53224C7.0316 18.5235 6.622 18.1139 6.622 17.6132V12.5614H3.18584C1.43363 12.5614 0 13.995 0 15.7473V19.2972C0 21.0494 1.43363 22.483 3.18584 22.483H15.8837V9.78518C15.8837 8.05573 14.4501 6.6221 12.6978 6.6221ZM44.6018 18.5235H46.3313V6.6221H52.9533V25.9419C52.9533 27.6942 51.5196 29.1278 49.7674 29.1278H37.2971V24.4856H46.3313V22.5058H40.2554C38.5032 22.5058 37.0696 21.0722 37.0696 19.3199V6.6221H43.6916V17.6132C43.6916 18.1139 44.1012 18.5235 44.6018 18.5235ZM68.2908 6.6221H55.593V19.32C55.593 21.0722 57.0266 22.5058 58.7788 22.5058H71.2491V18.5462H63.1252C62.6246 18.5462 62.215 18.1366 62.215 17.636V10.5816H63.9444C64.4451 10.5816 64.8547 10.9913 64.8547 11.4919V16.5437H68.2908C70.043 16.5437 71.4767 15.1101 71.4767 13.3579V9.80794C71.4767 8.05573 70.043 6.6221 68.2908 6.6221ZM74.1163 6.6221H86.8141C88.5891 6.6221 90 8.05573 90 9.78518V22.483H83.378V11.4919C83.378 10.9913 82.9684 10.5816 82.4677 10.5816H80.7383V22.5058H74.1163V6.6221Z" fill="#0ABF53"/>
</svg>

# Adyen Flutter Plugin (`adyen_flutter`)

This Flutter plugin is a **bridge** to the **Adyen POS Mobile SDK** for iOS and Android. It allows your Flutter app to **integrate with Adyen payment terminals**, such as the **NYC1** and **S1F2**, and process **in-person card-present payments**.

...

---

# 📜 Changelog

All notable changes to this project will be documented in this file.

## [0.0.1] - 2025-03-14
### Added
- Initial release of `adyen_flutter` plugin.
- Support for initializing the Adyen POS Mobile SDK.
- Discovery of payment terminals over Bluetooth/LAN.
- Connection to a selected terminal.
- Payment transaction initiation and result handling.
- Event channel support for terminal connection status (`connected`, `disconnected`, `connection_failed`).

### Notes
- Refunds and payment cancellations are not handled in-app (dashboard only).
- Reader provisioning (WiFi) requires Adyen's official provisioning tools.

[Unreleased]: https://github.com/your-org/adyen_flutter/compare/v0.0.1...HEAD
[0.0.1]: https://github.com/your-org/adyen_flutter/releases/tag/v0.0.1

