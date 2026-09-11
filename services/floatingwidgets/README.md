# Floating widget placement

The floating-widget code is intentionally split into three layers.

## 1. `FloatingWidgetPlacementService.qml`

Owns side effects only:

- queues placement requests per screen;
- asks ImageMagick for a tiny RGB copy of the wallpaper;
- caches that wallpaper analysis;
- retries failed analysis;
- emits the final placement.

If a bug involves processes, retries, or stale requests, start here.

## 2. `WallpaperAnalysis.js`

Owns image math only. It converts RGB pixels into integral images for:

- luminance;
- luminance variance;
- local detail/edges.

`score()` answers one question: is a rectangle a good place for a widget?
The floating clock also considers text/background contrast because it has no
card background.

If placement avoids or prefers the wrong parts of a wallpaper, start here.

## 3. `OverviewPlacement.js`

Owns geometry only. It:

1. creates horizontal/vertical groups;
2. tries eight named edge anchors;
3. rejects collisions;
4. scores the remaining placements using `WallpaperAnalysis`;
5. returns normalized x/y positions.

This deliberately avoids a dense pixel-by-pixel search. To add another anchor,
edit `ANCHORS` and `positionAtAnchor()`. To add another card, edit
`createCards()` and the corresponding UI card in `DesktopOverview.qml`.

## UI

`widgets/overview/DesktopOverview.qml` requests a placement and applies the
returned positions. `OverviewMovableResourceCard.qml` owns the repeated x/y
animation and wallpaper-background wiring for resource cards.
