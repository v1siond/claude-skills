# Sources

His list, 10-24, kept whole. The long dashes of his paste are written as colons (no dashes rule).

The style references we built from:
- https://github.com/AbubakrChan/product-launch-motion: the product-launch film structure we followed: title, screen in a frame, captions that snap in, cuts on the beat.
- https://github.com/charlie947/motion-graphics-skills: motion-graphics skills for agents: springs, easing, kinetic type.
- https://github.com/howseen-ai/claude-motion-design: motion-design guidance for Claude: camera moves, blur swaps, pacing.

The tools the pipeline runs on:
- https://playwright.dev/python/: drives headless Chromium. It renders every frame of the film page, and it captured Trivium.
- https://chromedevtools.github.io/devtools-protocol/tot/Page/#method-startScreencast: the Chrome screencast used to record Trivium at 30 fps.
- https://ffmpeg.org/: frame extraction, encoding, blending subframes, loudness normalising and the QA checks.
- https://numpy.org/ and https://scipy.org/: the synthesized score and sound effects.

Fonts (both free to use, SIL OFL):
- https://github.com/googlefonts/antonioFont: Antonio, the LCARS-style titles.
- https://github.com/georgd/EB-Garamond: EB Garamond, the italic captions.
- https://openfontlicense.org: the licence both use.

Music, if you'd rather use stock than synthesize:
- https://mixkit.co/free-stock-music/ and its licence at https://mixkit.co/license/: earlier cuts used Mixkit's "Uplifting Bass"; the final one has an original synthesized score.

Note: the font files in `assets/fonts/` were downloaded from octaviopardo/EBGaramond12 (see `assets/fonts/SOURCES.txt`, with hashes); georgd/EB-Garamond is the project his list names. Both are EB Garamond under the OFL.
