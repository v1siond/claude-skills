# Sources

Every claim in this skill cites a row here: [n] the performance research of 2026-10-28, [W<n>] the web stack
research of 2026-10-27, [E<n>] the engine research of 2026-10-27 (both research folders sit in the private
workspace). Each row: publisher, title, URL, version, the date it was read.

## Contents

- Engines, canvas, memory, loading, merging ([1] to [39])
- Web stack ([W<n>])
- Engine settings, culling and chunks ([E<n>])

## Engines, canvas, memory, loading, merging ([1] to [39])

- [1] Godot, TileMapLayer class reference, https://docs.godotengine.org/en/4.7/classes/class_tilemaplayer.html, Godot 4.7, read 2026-10-27
- [2] Godot, tile_map_layer.cpp, https://github.com/godotengine/godot/blob/d40e9472f6fb96a7caaf7321f5f24b8ac8f8478b/modules/tilemap/tile_map_layer.cpp, master d40e947, read 2026-10-27
- [3] Godot, PR 92797 batching in RendererCanvasRenderRD, https://github.com/godotengine/godot/pull/92797, 4.4, read 2026-10-27
- [4] RPG Maker MV corescript, Tilemap.js, https://github.com/rpgtkoolmv/corescript/blob/182e31449707ba7e406db0485c44c2a9d11e2dcd/js/rpg_core/Tilemap.js, 182e314, read 2026-10-27
- [5] RPG Maker MV corescript, ShaderTilemap.js, https://github.com/rpgtkoolmv/corescript/blob/182e31449707ba7e406db0485c44c2a9d11e2dcd/js/rpg_core/ShaderTilemap.js, 182e314, read 2026-10-27
- [6] RPG Maker MZ, Tilemap.js source, https://developer.rpgmakerweb.com/rpg-maker-mz/Tilemap.js.html, MZ, read 2026-10-27
- [7] RPG Maker MV corescript, DataManager.js, https://github.com/rpgtkoolmv/corescript/blob/182e31449707ba7e406db0485c44c2a9d11e2dcd/js/rpg_managers/DataManager.js, 182e314, read 2026-10-27
- [8] Unity, TilemapRenderer.Mode, https://docs.unity.com/en-us/engine/current/script-reference/unityengine/tilemaps/tilemaprenderer/mode, 6000.6, read 2026-10-27
- [9] Unity, Isometric Tilemap render modes, https://docs.unity3d.com/2022.3/Documentation/Manual/Tilemap-Isometric-RenderModes.html, 2022.3, read 2026-10-27
- [10] Unity, Tilemap Collider 2D, https://docs.unity3d.com/2022.3/Documentation/Manual/class-TilemapCollider2D.html, 2022.3, read 2026-10-27
- [11] Unity, Occlusion culling, https://docs.unity.com/en-us/engine/current/manual/cameras/occlusion-culling/occlusion-culling, current, read 2026-10-28
- [12] Defold, comp_tilegrid.cpp, https://github.com/defold/defold/blob/589d01cd9505ccc4fe4fc1f46cc76487428ed70f/engine/gamesys/src/gamesys/components/comp_tilegrid.cpp, 589d01c, read 2026-10-27
- [13] LDtk, JSON schema, https://ldtk.io/files/JSON_SCHEMA.json, 1.5.3, read 2026-10-27
- [14] MDN, Optimizing canvas, https://developer.mozilla.org/en-US/docs/Web/API/Canvas_API/Tutorial/Optimizing_canvas, living, read 2026-10-27
- [15] web.dev, Improving HTML5 Canvas performance, https://web.dev/articles/canvas-performance, 2011 article, read 2026-10-28
- [16] MDN, HTMLCanvasElement.getContext, https://developer.mozilla.org/en-US/docs/Web/API/HTMLCanvasElement/getContext, living, read 2026-10-28
- [17] MDN, imageSmoothingEnabled, https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/imageSmoothingEnabled, living, read 2026-10-28
- [18] MDN, Window.devicePixelRatio, https://developer.mozilla.org/en-US/docs/Web/API/Window/devicePixelRatio, living, read 2026-10-28
- [19] web.dev, OffscreenCanvas, https://web.dev/articles/offscreen-canvas, living, read 2026-10-27
- [20] MDN, ImageBitmap, https://developer.mozilla.org/en-US/docs/Web/API/ImageBitmap, living, read 2026-10-28
- [21] MDN, HTMLImageElement.decode, https://developer.mozilla.org/en-US/docs/Web/API/HTMLImageElement/decode, living, read 2026-10-28
- [22] MDN, Window.requestAnimationFrame, https://developer.mozilla.org/en-US/docs/Web/API/Window/requestAnimationFrame, living, read 2026-10-28
- [23] V8, Trash talk: the Orinoco garbage collector, https://v8.dev/blog/trash-talk, blog of the engine team, read 2026-10-28
- [24] Chrome for Developers, Fix memory problems, https://developer.chrome.com/docs/devtools/memory-problems, current, read 2026-10-28
- [25] Chrome for Developers, Record heap snapshots, https://developer.chrome.com/docs/devtools/memory-problems/heap-snapshots, current, read 2026-10-28
- [26] Chrome for Developers, Performance monitor, https://developer.chrome.com/docs/devtools/performance-monitor, current, read 2026-10-28
- [27] MDN, Performance.memory, https://developer.mozilla.org/en-US/docs/Web/API/Performance/memory, living, read 2026-10-28
- [28] MDN, measureUserAgentSpecificMemory, https://developer.mozilla.org/en-US/docs/Web/API/Performance/measureUserAgentSpecificMemory, living, read 2026-10-28
- [29] Meta, memlab README, https://cdn.jsdelivr.net/gh/facebook/memlab@main/README.md, main, read 2026-10-28
- [30] React, useEffect reference, https://react.dev/reference/react/useEffect, React 19 docs, read 2026-10-28
- [31] ChromeDevTools, devtools-protocol JSON (Performance.enable, getMetrics; HeapProfiler.collectGarbage), https://raw.githubusercontent.com/ChromeDevTools/devtools-protocol/master/json/browser_protocol.json, master, read 2026-10-28
- [32] Playwright, CDPSession, https://playwright.dev/docs/api/class-cdpsession, current, read 2026-10-28
- [33] Chrome for Developers, Analyze rendering performance (Frame rendering stats), https://developer.chrome.com/docs/devtools/rendering/performance, current, read 2026-10-28
- [34] Godot, Background loading, https://docs.godotengine.org/en/stable/tutorials/io/background_loading.html, stable, read 2026-10-28
- [35] Godot, ResourceLoader, https://docs.godotengine.org/en/stable/classes/class_resourceloader.html, stable, read 2026-10-28
- [36] Mikola Lysenko, Meshing in a Minecraft Game, https://0fps.net/2012/06/30/meshing-in-a-minecraft-game/, 2012 post, read 2026-10-28
- [37] Wikipedia, Polygon partition, https://en.wikipedia.org/wiki/Polygon_partition, encyclopedia (lead), read 2026-10-28
- [39] MDN, Tiles and tilemaps overview, https://developer.mozilla.org/en-US/docs/Games/Techniques/Tilemaps, living, read 2026-10-27

## Web stack ([W<n>])

- [W1] web.dev, Interaction to Next Paint (INP), https://web.dev/articles/inp, read 2026-10-27
- [W2] web.dev, Optimize long tasks, https://web.dev/articles/optimize-long-tasks, read 2026-10-27
- [W8] React, Profiler reference, https://react.dev/reference/react/Profiler, read 2026-10-27
- [W9] welldone-software, why-did-you-render README, https://github.com/welldone-software/why-did-you-render, read 2026-10-27
- [W15] MDN, Performance.measure(), https://developer.mozilla.org/en-US/docs/Web/API/Performance/measure, read 2026-10-27
- [W16] Chrome for Developers, Long Animation Frames API, https://developer.chrome.com/docs/web-platform/long-animation-frames, read 2026-10-27
- [W17] Playwright, Trace viewer, https://playwright.dev/docs/trace-viewer, read 2026-10-27
- [W19] MDN, Connection management in HTTP/1.x, https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/Connection_management_in_HTTP_1.x, read 2026-10-27
- [W21] MDN, ETag, https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/ETag, read 2026-10-27
- [W25] Ecto (ecto 3.x hexdocs), Ecto.Repo, https://ecto.hexdocs.pm/Ecto.Repo.html, read 2026-10-27
- [W27] Ecto, Ecto.Query (preload), https://ecto.hexdocs.pm/Ecto.Query.html, read 2026-10-27
- [W30] Erlang/OTP, ets (stdlib), https://www.erlang.org/doc/apps/stdlib/ets.html, read 2026-10-27
- [W31] PostgreSQL 18, pg_stat_statements, https://www.postgresql.org/docs/current/pgstatstatements.html, read 2026-10-27
- [W32] PostgreSQL 18, Using EXPLAIN, https://www.postgresql.org/docs/current/using-explain.html, read 2026-10-27
- [W34] PostgreSQL 18, Constraints (foreign keys), https://www.postgresql.org/docs/current/ddl-constraints.html, read 2026-10-27
- [W40] web.dev, Rendering performance, https://web.dev/articles/rendering-performance, read 2026-10-27
- [W42] GoogleChrome, Lighthouse CI configuration, https://github.com/GoogleChrome/lighthouse-ci/blob/main/docs/configuration.md, read 2026-10-27

## Engine settings, culling and chunks ([E<n>])

- [E4] Godot, ProjectSettings.xml, https://github.com/godotengine/godot/blob/d40e9472f6fb96a7caaf7321f5f24b8ac8f8478b/doc/classes/ProjectSettings.xml, master d40e947, read 2026-10-27
- [E5] Godot, EditorSettings.xml, https://github.com/godotengine/godot/blob/d40e9472f6fb96a7caaf7321f5f24b8ac8f8478b/doc/classes/EditorSettings.xml, master d40e947, read 2026-10-27
- [E21] Phaser, IsometricCullTiles.js, https://cdn.jsdelivr.net/npm/phaser@4.1.0/src/tilemaps/components/IsometricCullTiles.js, Phaser 4.1.0, read 2026-10-27
- [E22] Phaser, CullBounds.js and CullTiles.js, https://cdn.jsdelivr.net/npm/phaser@4.1.0/src/tilemaps/components/CullBounds.js, Phaser 4.1.0, read 2026-10-27
- [E27] Tiled, JSON map format, https://doc.mapeditor.org/en/stable/reference/json-map-format/, Tiled stable (1.12), read 2026-10-27
- [E28] Tiled, tilelayer.h, https://github.com/mapeditor/tiled/blob/83e4cfd9faa653e543e64d1af3b1010f8d5794da/src/libtiled/tilelayer.h, master 83e4cfd, read 2026-10-27
- [E29] Tiled, isometricrenderer.cpp, https://github.com/mapeditor/tiled/blob/83e4cfd9faa653e543e64d1af3b1010f8d5794da/src/libtiled/isometricrenderer.cpp, master 83e4cfd, read 2026-10-27
