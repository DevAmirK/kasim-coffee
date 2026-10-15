# Kasim Coffee project instructions

## Product identity

- The product name is **Kasim Coffee**. Do not rename it to another brand.
- Kasim Coffee is a modern coffee shop app designed to support future franchise expansion.
- The current product scope is drinks only. Hot food and desserts are planned for a later phase.
- The main differentiator is the loyalty system: phone-linked loyalty accounts, bonus accumulation, stamps or streaks, and free drinks.

## Fixed visual system

Do not change the brand palette unless the user explicitly requests a new brand direction:

- Primary yellow: `#F9E532`
- Soft yellow: `#FFF4A8`
- Graphite: `#222222`
- Secondary gray: `#444444`
- White: `#FFFFFF`
- Soft background: `#F5F5F2`
- Border gray: `#E6E6E2`

Use the named tokens in `lib/theme/app_theme.dart`. Do not add arbitrary brown, purple, blue, or red colors for ordinary UI states. Keep cards white, rounded, clean, and high-contrast with yellow accents.
- Use graphite `#222222` for text and icons on the primary yellow. Never place white primary text on `#F9E532`.
- Keep the downloaded drink photos local in `assets/drinks/` during Milestone 1; do not replace them with `Image.network` unless the user explicitly requests remote images.
- Display all drink prices in Kazakhstani tenge using the `₸` symbol, not dollars.
- Keep user-adjustable drink ratings bounded between `1.0` and `5.0`.
- A user has one active rating per drink, but may change it later. Tapping the active rating resets it to the catalog rating.
- After a cart item is added, use quantity controls with minus, count, and plus instead of leaving a single Add button.

## Engineering constraints

- Use Flutter SDK and Material 3 only unless the user explicitly changes this requirement.
- Keep milestone state management based on `StatefulWidget` and `setState`; do not introduce Provider, Riverpod, or BLoC before the planned architecture migration.
- Preserve the existing folder structure and reusable widgets.
- Keep layouts responsive for narrow phones, landscape, and tablet widths using `SafeArea`, `Wrap`, `Flexible`, `Expanded`, and scrollable containers.
- Run `dart format lib test`, `flutter analyze`, and targeted tests after Dart changes.
- Do not remove or weaken form validation, favorites, cart, rating controls, loyalty stamps, or quick login behavior while changing visual details.

## Product roadmap boundary

The next planned phases are phone-based account linking, persistent local storage, REST API integration, real bonus balances and streaks, then BLoC for auth, menu, cart, favorites, and orders. Do not present mock in-memory state as persistent storage.
