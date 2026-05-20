---
name: html-slideshow
description: >
  Creates self-contained HTML/JavaScript slideshows and presentations as a single file with no external dependencies.
  Use this skill whenever the user asks for a presentation, slideshow, slides, pitch deck, HTML presentation,
  talk slides, or wants to present information visually — even if they don't say "HTML" or "slideshow" explicitly.
  Also trigger for requests like "make slides about X", "create a deck on Y", "I need to present Z".
  The output is always one standalone .html file that opens directly in any browser.
---

## What this skill does

Generates a polished, self-contained HTML slideshow: one `.html` file, no CDN links, no external fonts, no dependencies. The user opens it in a browser and presents immediately. Keyboard navigation is built in.

The guiding principle: **less is more**. Each slide communicates one idea. Minimal text, maximal clarity.

---

## Output requirements

- **Single file**: all CSS and JS inline in one `.html` file
- **No external dependencies**: no CDN, no Google Fonts, no external images
- **Keyboard navigation**: left/right arrows and space bar advance slides; left arrow or backspace goes back
- **Slide counter**: show current/total (e.g. `3 / 8`) somewhere unobtrusive
- **Fullscreen-friendly**: layout works at any browser window size, content centered

Save the file as `<topic-slug>.html` in the current directory (or wherever the user asks).

---

## Slide content rules

These rules exist because audiences don't read slides — they glance at them while listening to the speaker. Dense slides lose the room.

- **One idea per slide** — if you're tempted to add a second point, make a second slide
- **Max ~5 bullet points per slide** — and each bullet is a fragment, not a sentence
- **Title slides**: just a title and optional subtitle — no body text
- **No walls of text**: if a slide has a paragraph, rewrite it as bullets or split it
- **Use numbers and data visually**: "3x faster" in large type beats a table
- **Code slides**: show only the essential snippet, syntax-highlighted with a `<pre><code>` block

---

## Visual design

Clean, professional, readable from 3 meters away. The default palette is dark-on-light (white/light gray background, dark text), but adapt if the user specifies a theme.

**Typography**
- Use system fonts: `font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif`
- Title: 2.5–3.5rem, bold
- Body text / bullets: 1.4–1.8rem
- Never go below 1.2rem — unreadable on a projector

**Layout**
- Slides are full-viewport: `width: 100vw; height: 100vh`
- Content centered vertically and horizontally with flexbox
- Generous padding (5–8% of viewport width)
- One slide visible at a time; others are `display: none` or off-screen

**Accent color**
- Pick one accent color that fits the topic (tech → blue, nature → green, finance → navy, etc.)
- Use it for headings, bullet markers, or the slide counter — not everywhere

**Slide types to vary the rhythm**
- Title slide (large centered text)
- Bullet-list slide
- Big-stat slide (one number or quote, enormous font)
- Two-column slide (concept vs. example, before vs. after)
- Code slide

---

## JavaScript structure

```html
<script>
  let current = 0;
  const slides = document.querySelectorAll('.slide');

  function show(n) {
    slides.forEach(s => s.style.display = 'none');
    slides[n].style.display = 'flex';
    document.getElementById('counter').textContent = `${n + 1} / ${slides.length}`;
  }

  document.addEventListener('keydown', e => {
    if (e.key === 'ArrowRight' || e.key === ' ') {
      if (current < slides.length - 1) show(++current);
    } else if (e.key === 'ArrowLeft' || e.key === 'Backspace') {
      if (current > 0) show(--current);
    }
  });

  show(0);
</script>
```

Also add clickable prev/next buttons for mouse users. On mobile, add swipe support with a simple `touchstart`/`touchend` listener.

---

## Process

1. **Understand the topic**: read the user's request and identify the subject, intended audience, and any content they provide (bullet points, notes, outline)
2. **Outline the slides**: decide the slide sequence — typically: title → agenda (optional) → main content slides → closing/summary. Aim for 6–15 slides unless told otherwise.
3. **Write content**: apply the "one idea per slide" rule ruthlessly. Distill, don't dump.
4. **Choose a color accent** that fits the topic
5. **Generate the HTML file** with all CSS and JS inline
6. **Tell the user** the filename and that they can open it directly in any browser. Mention keyboard shortcuts (arrows / space).

---

## Example slide HTML structure

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Presentation Title</title>
  <style>
    /* ... all styles inline ... */
  </style>
</head>
<body>
  <div id="counter">1 / N</div>

  <div class="slide" style="display:flex">
    <h1>Title Slide</h1>
    <p class="subtitle">Subtitle here</p>
  </div>

  <div class="slide">
    <h2>Slide Title</h2>
    <ul>
      <li>Point one</li>
      <li>Point two</li>
    </ul>
  </div>

  <!-- nav buttons -->
  <button id="prev">←</button>
  <button id="next">→</button>

  <script>/* ... navigation JS ... */</script>
</body>
</html>
```
