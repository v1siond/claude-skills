# Web formats, sizes and licences

Open this when choosing a format or a size, and when `media-check.py` fails. Sources are numbered at the
end, read 2026-10-23; the research trail is
`$CLAUDE_WORKSPACE/<project>/research/2026-10-23-blog-skill/notes.md`.
Where a number is a house choice and no source sets it, it says "house".

## Formats

| Media | Ship as | Why |
|---|---|---|
| screenshot, render, photo | WebP (quality 82, house), PNG kept beside it as the source | Google indexes BMP, GIF, JPEG, PNG, WebP, SVG and AVIF [4]; AVIF has no encoder on this box (`avifenc` missing) |
| diagram | SVG, plus a PNG for feeds and the og image | SVG is indexed [4] and stays sharp; feeds and social cards want a raster |
| short clip, a loop that would be a gif | MP4 (H.264, yuv420p, faststart, no audio) and WebM (VP9), webm listed first, a poster WebP | a 3.7 MB gif became a 551 KB mp4 and a 341 KB webm; `<video autoplay loop muted playsinline>` plays it like a gif; the browser takes the first source it supports [1] |
| film with sound | the mp4 from motion-video, a poster, VideoObject data and key moments | a video needs a watch page or prominent embed, a stable thumbnail, VideoObject and Clip data (Google video SEO guide, trends.md source 5) |
| code | a fenced block with its language, from `code-extract.py` | text is searchable and copyable; never a picture of code |
| gif | only when the target cannot play video (a README, an email) | [1] |

The extension matches the type [4].

## Sizes (house unless cited)

- Body images: 1600 px wide master for a 800 px column at 2x, at most 400 KB per WebP. A screenshot of the
  app is taken at 1440x900 CSS pixels with deviceScaleFactor 1, or 2 for a crop that must stay crisp.
- Phone view shots: 390x844.
- Cover and og image: 1200x630 (1.91:1), the size Meta recommends for link shares, minimum 600x315, file
  under 8 MB [6]. It is also the post's first image.
- Clips: at most 15 s and 4 MB per mp4 (house), 30 fps, the width of the body image.
- Every image and video carries width and height (or a CSS aspect-ratio) so the page does not shift [2].
- The first image in the viewport loads eager; every image below it gets `loading="lazy"` [3].

## Alt text, captions, file names

- Alt text is the most important image attribute; say what the image shows for someone who cannot see it,
  no keyword lists [4]. House: one sentence, at most 150 characters, never the file name.
- A caption says what to look at, in his voice, and names the source (a sha, "Example data" for anything
  illustrative).
- File names are short and descriptive (`portal-vortex.webp`), never `image1.png` [4].
- Images sit next to the text they explain [4].

## Licences

- His screens and his code are his. A font, track, icon or image from anyone else carries its licence file
  next to it in `media/licences/` and a line in the media item's `licence` field (name, licence, URL).
- Fonts: local files with their licence (motion-video `assets/fonts/` has Antonio and EB Garamond, SIL OFL).
  Never a network font in a diagram or a frame.
- Music: only through motion-video (its synthesized score, or a track he licensed).
- Never an image found on the web without a licence that allows reuse; a reference image he shared stays
  out of the post.

## Sources

1. web.dev, "Replace animated GIFs with video for faster page loads", updated 2018-11-05. https://web.dev/articles/replace-gifs-with-videos
2. web.dev, "Optimize Cumulative Layout Shift", updated 2025-02-07. https://web.dev/articles/optimize-cls
3. web.dev, "Browser-level image lazy loading", updated 2024-08-13. https://web.dev/articles/browser-level-image-lazy-loading
4. Google Search Central, "Google image SEO best practices", updated 2026-03-02. https://developers.google.com/search/docs/appearance/google-images
5. Google Search Central, "Control your snippets in search results", updated 2026-04-20. https://developers.google.com/search/docs/appearance/snippet
6. Meta for Developers, "Images in Link Shares", read 2026-10-23. https://developers.facebook.com/docs/sharing/webmasters/images/
