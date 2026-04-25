# Brand Reference — Udemy Course Series

**This file is the single source of truth for visual identity across every
episode.** Both the cutting layer (`video-use`) and the motion graphics
layer (`hyperframes`) read values from here. If something isn't in this
file, it isn't part of the brand — ask before adding it.

> ⚠️ Sections marked `<!-- TODO -->` need your input before the first
> episode. Sections without it are sensible defaults you can override.

---

## 1. Identity

| Field | Value |
|---|---|
| Course name | <!-- TODO: e.g. "Production-Grade Engineering Management" --> |
| Tagline | <!-- TODO: one short line, used on intro card --> |
| Instructor name | <!-- TODO --> |
| Instructor title | <!-- TODO: e.g. "Engineering Manager, 15 years building software" --> |
| Course URL | <!-- TODO: udemy.com/course/... --> |
| Logo (light bg) | `templates/_assets/logo-light.svg` <!-- TODO: place file --> |
| Logo (dark bg) | `templates/_assets/logo-dark.svg` <!-- TODO: place file --> |

---

## 2. Color palette

These are exposed as CSS custom properties in every Hyperframes composition
and as RGB tuples for any PIL/Manim animation built by the cutting layer.

```css
:root {
  /* Primary — used for accent, calls to action, key emphasis */
  --brand-primary:      #2563EB;   /* TODO: confirm — default = strong blue */
  --brand-primary-rgb:  37, 99, 235;

  /* Background — the canvas color for cards, lower-thirds */
  --brand-bg:           #0A0A0A;   /* TODO: confirm — default = near-black */
  --brand-bg-rgb:       10, 10, 10;

  /* Surface — slightly lighter than bg, for layered cards */
  --brand-surface:      #161616;
  --brand-surface-rgb:  22, 22, 22;

  /* Text — primary on dark bg */
  --brand-text:         #F5F5F5;
  --brand-text-rgb:     245, 245, 245;

  /* Text dim — labels, captions, secondary info */
  --brand-text-dim:     #9CA3AF;
  --brand-text-dim-rgb: 156, 163, 175;

  /* Code accent — used in syntax-highlighted overlays */
  --brand-code-bg:      #1E1E2E;
  --brand-code-string:  #A6E3A1;
  --brand-code-keyword: #CBA6F7;
  --brand-code-fn:      #89B4FA;
  --brand-code-comment: #6C7086;

  /* Status colors — used sparingly for emphasis frames */
  --brand-success:      #10B981;
  --brand-warn:         #F59E0B;
  --brand-error:        #EF4444;
}
```

**Rules:**
- Maximum **2 accent colors** in any single frame. Default to primary only.
- Use `--brand-text-dim` for labels and timestamps, `--brand-text` for
  the actual content.
- Status colors are for callouts only — never as backgrounds.

---

## 3. Typography

| Use | Font | Weight | Size (1080p) | Notes |
|---|---|---|---|---|
| Episode title (intro card) | Inter | 700 | 96px | Tight letter-spacing -0.02em |
| Chapter card | Inter | 600 | 64px | |
| Lower-third — name | Inter | 600 | 36px | |
| Lower-third — title | Inter | 400 | 24px | `--brand-text-dim` |
| Subtitle / caption | Inter | 600 | 38px | UPPERCASE, max 2 words/line |
| Body / generic overlay | Inter | 400 | 32px | |
| Code | JetBrains Mono | 500 | 28px | Monospaced |

<!-- TODO: confirm Inter + JetBrains Mono, or swap. Both are free Google Fonts. -->

**Asset paths:**
- `templates/_assets/fonts/Inter-*.woff2`
- `templates/_assets/fonts/JetBrainsMono-*.woff2`

The `install.sh` script downloads these on setup.

---

## 4. Subtitle style (video-use `SUB_FORCE_STYLE`)

Udemy delivery doesn't require burned-in subtitles (Udemy auto-generates
them), but they're useful for clip exports to LinkedIn/Twitter. We
maintain two styles:

### `udemy-master` — soft, low-distraction (default for Udemy delivery)

Don't burn subtitles into the master. Generate `master.srt` only and
attach to the Udemy upload.

### `social-bold` — for short-form clip exports

```
FontName=Inter,FontSize=22,Bold=1,
PrimaryColour=&H00F5F5F5,OutlineColour=&H00000000,BackColour=&H80000000,
BorderStyle=1,Outline=3,Shadow=0,
Alignment=2,MarginV=120
```

Chunking: 2 words per line, UPPERCASE, break on punctuation.

---

## 5. Animation timing

These are reads in every overlay we build. Hyperframes compositions and
PIL/Manim sequences both reference these.

| Event | Duration | Easing |
|---|---|---|
| Title card fade-in | 0.6s | `easeOutCubic` |
| Title card hold | 2.5s | — |
| Title card fade-out | 0.4s | `easeInCubic` |
| Lower-third slide-in | 0.5s | `easeOutCubic` |
| Lower-third hold | 4.0s | — |
| Lower-third slide-out | 0.4s | `easeInCubic` |
| Chapter card | 1.0s in / 2.0s hold / 0.5s out | cubic |
| Code overlay reveal | 0.8s | `easeOutCubic` |
| Generic accent | 0.4s | `easeOutCubic` |

**Universal rules:**
- Never `linear` easing — looks robotic
- Hold the final frame ≥ 1s before any cut
- Over voiceover: total duration ≥ `narration_length + 1s`
- Never reveal two new elements in parallel — eye can't track them

---

## 6. Lower-third layout

```
┌────────────────────────────────────────────┐
│                                            │
│                                            │
│                                            │
│  ┌──── 4px primary stripe ────┐            │
│  │                            │            │
│  │   INSTRUCTOR NAME          │            │
│  │   Title / role             │            │
│  │                            │            │
│  └────────────────────────────┘            │
│  ↑ 8% from bottom                          │
│  ↑ 6% from left                            │
└────────────────────────────────────────────┘
```

- Background: `--brand-surface` at 90% opacity
- Left edge: 4px solid `--brand-primary`
- Padding: 24px vertical, 32px horizontal
- Slide-in from left, slide-out to left
- Appears once per episode on instructor's first speaking moment, lasts 4s

---

## 7. Chapter card layout

Full-screen card between chapters. Used at every chapter boundary in a
Udemy lecture (typically 2–4 per episode).

- Background: solid `--brand-bg`
- Centered: chapter number in `--brand-primary` (small, 32px), then
  chapter title in title typography (white, 96px)
- Subtle horizontal line under the title: 2px, `--brand-primary`, 25% width
- Duration: 3.5s total (1.0s in / 2.0s hold / 0.5s out)
- Audio: brand-cue sting (see Section 9)

---

## 8. Code overlay style

For Udemy programming courses, code overlays are critical. Style:

- Background: `--brand-code-bg` at 95% opacity
- Border-radius: 12px
- Padding: 24px
- Drop shadow: `0 8px 24px rgba(0,0,0,0.5)`
- Syntax theme: Catppuccin Mocha (matches our code-* color tokens)
- Font: JetBrains Mono 500 / 28px
- Reveal: line-by-line at 80ms per line, `easeOutCubic`

The overlay can be positioned anywhere; default is top-right at 60% width.

---

## 9. Audio identity

| Asset | Path | Use |
|---|---|---|
| Intro sting | `templates/_assets/audio/intro-sting.wav` | <!-- TODO: 2–3s, ends on tonic --> |
| Chapter cue | `templates/_assets/audio/chapter-cue.wav` | <!-- TODO: 0.4s, soft --> |
| Outro sting | `templates/_assets/audio/outro-sting.wav` | <!-- TODO: 3–4s, resolves --> |

All stings: -18 LUFS integrated, peak -3 dBFS. Tucked under voiceover at -24 LUFS.

---

## 10. Output spec (Udemy delivery)

| Setting | Value |
|---|---|
| Resolution | 1920×1080 |
| Frame rate | 30 fps |
| Video codec | H.264 (libx264) |
| CRF | 18 |
| Pixel format | yuv420p |
| Audio codec | AAC |
| Audio bitrate | 192 kbps |
| Audio sample rate | 48 kHz |
| Container | MP4 |
| Min duration | 2 minutes (Udemy minimum per lecture) |
| Max file size | 4 GB (Udemy limit) |

`render.py` and the final composite step both read from this section.

---

## 11. Tone — voice and copy

When Claude generates overlay text (titles, lower-thirds, chapter cards),
follow this voice:

- **Concise.** No filler. "Setting up the database" not "Now we're going to set up the database".
- **Active voice.** "Run this" not "This should be run".
- **Specific.** "Update line 47" not "Update the file".
- **No exclamation marks.** The course is technical, not promotional.
- **Title case for chapter titles.** "Building the Auth Layer" not "building the auth layer".

<!-- TODO: tweak this section to match your delivery style. -->
