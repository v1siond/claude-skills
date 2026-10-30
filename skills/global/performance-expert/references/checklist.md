# The checklist: each item a measured yes or no

Pipeline step 6 names the cause of the worst item over budget from this list; the QA player and the builder walk every row and
write yes, no or not measured with the number. Numbers in brackets are `sources.md` rows.

## Contents

- Draw and render loop
- Memory
- Load and switch
- Front end re-renders and network
- Server and database
- How engines do it

## Draw and render loop

1. **Count first.** Objects stored, objects drawn and draw calls a frame, against the budget. A count that grows with
   the content is the defect: one tile map went from 573,440 draw calls at about 10 fps to 36 at more than 130 fps
   by batching alone [3].
2. **Storage merge.** A run of equal cells (same picture, height, depth, layer, tone) is stored as few rectangles,
   each one placement, split back into cells on edit. Greedy meshing: an 8 by 8 by 8 cube is 3,072 quads naive, 384
   with face culling, 6 greedy, and the greedy result has "no more than 8x as many quads than the optimal mesh"
   [36]. The fewest rectangles for a rectilinear shape is solvable in polynomial time, the fewest squares is NP-hard;
   greedy is the practical cut [37] (an encyclopedia, a lead). Godot merges physics shapes per quadrant [1], Unity's composite collider "reduces the number of individual
   Collider shapes" [10]. Report the rectangle count beside the cell count.
3. **Bake once, rebuild dirty.** Static content baked into chunks (Godot quadrant of 16 by 16 cells [1], Defold 32
   tile regions [12]); an edit marks its chunk dirty and dirty chunks rebuild once at frame end [1][2]; animation as
   3 or 4 baked frames swapped, never relaid (RPG Maker advances a frame every 30 updates [4][5]).
4. **No per frame rebuild of what did not change.** Nothing keyed on an unchanged value is rebuilt; an idle editor
   draws only when the camera, the data, the hover or an animation clock moved (Godot low processor mode [E4][E5]).
5. **Cull in grid space.** Walk the visible rows and columns from the camera; a filter over every object is the
   pattern to remove (Phaser's isometric cull walks the whole layer [E21][E22]); Tiled's isometric renderer walks only the
   rows under the exposed rectangle [E29]. A filter applied after the cull walks every visible object: apply it inside the cull.
   Baked occlusion does not fit maps made at runtime: Unity's built in occlusion culling "is not suitable" when a
   project "generates Scene geometry at runtime" [11]; hide a cell behind an opaque one per cell, as LDtk discards
   tiles behind opaque ones [13].
6. **Integer blits, no pixel reads per frame.** Non integer coordinates turn on anti-aliasing [15];
   `willReadFrequently` "will force the use of a software ... 2D canvas" [16]; no `getImageData` on the visible
   canvas per frame. `alpha: false` when the backdrop is opaque [16]. One path per batch of lines drawn with one
   call; state changes "can also incur a performance overhead"; `shadowBlur` "can be very expensive" [15].
   `imageSmoothingEnabled` defaults to `true` and `false` keeps pixel art sharp [17]: a look switch first, measured
   before it is called a speed switch.
7. **devicePixelRatio handled once.** The backing store is `Math.floor(size * scale)` with `ctx.scale` [18]; at a DPR
   of 2 every baked canvas costs 4 times the pixels (arithmetic).
8. **No steady allocation in the hot loop.** The Allocation Timeline shows no steady stream of blue bars in a walk
   [24]; slot objects and spread arrays made per frame are young garbage every frame [23].
9. **WebGL only after canvas fails with a number.** The canvas plan (cache holes, chunk bake, grid cull, allocation)
   is measured first; a move to WebGL is his call with the number that failed.

## Memory

10. **Every cache has a bound or an owner that clears it.** A module level `Map` lives for the page; keyed by a value
    that moves (zoom, a stamp, a tint) it grows without end. Bound it (LRU with a size cap) or clear it on the event
    that stales its keys (a replan, a zoom settle, a screen switch).
11. **Every effect returns its cleanup.** "The cleanup function should stop or undo whatever the setup function was
    doing" [30]: `addEventListener`/`removeEventListener`, `setInterval`/`clearInterval`,
    `requestAnimationFrame`/`cancelAnimationFrame` (a rAF is "one-shot" [22]), `ResizeObserver`/`disconnect`. A
    loop that is never cancelled keeps its closure and the data it reads alive. Counting pairs proves nothing; the
    N opens test does (`measuring.md`).
12. **Nothing closes over a screen's data past that screen.** Heap snapshot retainers name the holder [25];
    "Detached DOM nodes are a common cause of memory leaks" [24]. `ImageBitmap.close()` "Disposes of all graphical
    resources" [20]. The Performance monitor shows "JavaScript event listeners" and DOM nodes live [26]: a
    count that climbs with each open is a leak. `measureUserAgentSpecificMemory` needs a secure, cross-origin
    isolated page [28]; for a test, read the heap through the DevTools protocol (`measuring.md`).

## Load and switch

13. **Pictures decoded ahead and kept across screens** [21][35]; per screen state (chunks, caches, sorted orders)
    dropped on the switch.
14. **Load off the main thread with progress** for anything over 50 ms (a long task [W2]); Godot loads a level with
    `load_threaded_request` [34]. A worker moves work and removes none [19].
15. **Payload scales with the merged count.** A field stored as rectangles sends one row where it sent one per cell.
    A big map loads whole as one file per map (RPG Maker [7]); edits save per 16 cell chunk, the size Tiled fixes for
    its infinite map chunks (`CHUNK_SIZE = 16`) [E27][E28]. Pre-render the map, or big sections of it, off canvas [39].

## Front end re-renders and network

16. **Re-renders counted.** React Profiler `onRender` or why-did-you-render [W8][W9] per action; a component that
    renders on every frame or every keystroke without its props changing is a finding. INP at or under 200 ms [W1].
17. **Requests per screen fixed.** The count does not grow with the content; many small GETs merged into one
    read; HTTP/1.1 opens 6 connections per domain, so request 7 waits [W19].

## Server and database

18. **Query count constant per request**, asserted in a test; preload in place of a per item `Repo.get` [W25][W27];
    `Repo.insert_all` in chunks for batches [W25].
19. **An index on every foreign key a delete or a join uses** [W34]; the top 5 statements of `pg_stat_statements`
    by `total_exec_time` each have a reason [W31].
20. **Unchanged reads cached** with an ETag and a 304 [W21]; ETS with `read_concurrency: true` for read mostly
    lookups [W30].

## How engines do it

| Engine | How | Source |
|---|---|---|
| Godot 4 | 16 by 16 quadrants, one canvas item each; y-sorted layers group by row; edits batched at frame end over dirty quadrants | [1][2][3] |
| RPG Maker MV/MZ | one JSON per map; repaints a cell only when its tiles changed; animation by a shader offset; MZ one draw call per layer | [4][5][6][7] |
| Unity | Tilemap Chunk mode, "the best rendering performance", one Sprite Atlas so tiles sort | [8][9] |
| Defold | 32 tile regions with a dirty bit each | [12] |
| LDtk | auto layers stored pre-sorted, tiles behind opaque ones discarded | [13] |
