# Kasim Coffee

Kasim Coffee is a Flutter coffee shop app for browsing drinks, choosing sizes, milk and syrups, saving favorites, rating drinks, placing orders, and collecting loyalty stamps.

## Theme

The app uses a bright yellow and graphite palette, white cards, soft backgrounds, rounded corners, and large drink photos. Yellow highlights the main actions, with graphite text for readability.

- Primary yellow: `#F9E532`
- Soft yellow: `#FFF4A8`
- Graphite: `#222222`
- Secondary text: `#444444`
- White: `#FFFFFF`
- Background: `#F5F5F2`
- Borders: `#E6E6E2`

## Lab 10

Start Docker Desktop, then run `docker compose up -d` from the project root.
Start the Flutter app with Chrome selected in Android Studio. The web app
loads `http://localhost:8080/products`. To use another API origin, pass
`--dart-define=API_URL=http://localhost:8080`.

For the offline demo, load the catalog, select **Offline** in Chrome DevTools
under **Network**, then drag the list down with the mouse. Switch back to
**No throttling** and click **Retry Connection**. Keep the app tab open.
