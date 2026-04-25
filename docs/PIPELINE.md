# The Pipeline — End to End

This is the full process from raw footage to Udemy-ready MP4. It runs in
three stages. Each stage has a defined input, a defined output, and a
self-evaluation gate before the next stage starts.

```
┌────────────┐    ┌────────────┐    ┌────────────┐    ┌────────────┐
│ raw/*.mp4  │ ─► │ STAGE 1    │ ─► │ STAGE 2    │ ─► │ STAGE 3    │ ─► final.mp4
│ .mov etc.  │    │ Cut        │    │ Decorate   │    │ Composite  │
└────────────┘    └────────────┘    └────────────┘    └────────────┘
                  video-use         hyperframes        ffmpeg
                  ElevenLabs        + BRAND.md         + delivery spec
                  Scribe
```

## Stage 1 — Cut (`video-use`)

**Input:** `episodes/<n>/raw/*.{mp4,mov,MP4,MOV}` — one or more takes,
unedited, plus optional B-roll.

**Output:** `episodes/<n>/edit/preview.mp4` — clean cut with filler words
removed, audio fades at every boundary, color graded, master.srt produced.

**Process:**

1. **Inventory.** Run `ffprobe` on every source. Confirm resolution, fps,
   audio sample rate, duration. Flag any mismatched sources.
2. **Transcribe.** `transcribe_batch.py` runs with 4 parallel workers.
   One JSON per source in `edit/transcripts/`. Cached forever — never
   re-transcribe an unchanged source.

   **Transcription backends** (configure in `.env`):
   - **ElevenLabs Scribe** (`ELEVENLABS_API_KEY`) — default; best cut-point
     detection. ~$0.40 per 10 min audio.
   - **OpenAI Whisper** (`OPENAI_API_KEY`) — accurate, lower cost; good
     alternative if you already have an OpenAI key.
   - **Local Whisper** — free, on-device, no API cost. Slower. Ask Claude
     Code to install it.
   Priority: ElevenLabs > OpenAI > local. Missing keys fall back automatically.
3. **Pack.** `pack_transcripts.py` produces `edit/takes_packed.md`. This
   is the LLM's primary reading view: phrase-level timestamps, speaker
   diarization, audio events. ~12KB for an entire 30-minute multi-take.
4. **Strategy.** Read `takes_packed.md`. Note verbal slips and mis-speaks,
   then propose the cut in 4–8 sentences:
   - Episode shape (HOOK → CONTEXT → DEMO → GOTCHAS → RECAP → NEXT)
   - Take selection per beat (call out specific slips to avoid)
   - Pacing direction (tight tutorial vs. cinematic explainer)
   - Color grade preset (`warm_cinematic`, `neutral_punch`, or `none`)
   - Subtitle direction
   - Length estimate
   - **WAIT for user confirmation.**
5. **Build EDL.** Spawn the editor sub-agent. It outputs `edit/edl.json` — a
   list of (source, start, end, beat, quote, reason) ranges, all snapped to
   word boundaries.
6. **Render preview.** `render.py edit/edl.json -o edit/preview.mp4 --preview`.
   720p, fast.
7. **Self-evaluate.** Run `timeline_view` on `preview.mp4` at every cut
   boundary (±1.5s window). Check for:
   - Visual jumps
   - Audio pops (waveform spike at cut)
   - Hidden subtitles
   - Misaligned overlays (none yet at this stage, but format-check anyway)
   - Grade drift
   Fix → re-render → re-eval. Cap at 3 passes; flag remaining issues.
8. **Final cut render.** `render.py edit/edl.json -o edit/preview.mp4`
   (full quality). Produces `master.srt` alongside.

**Hard rules (non-negotiable):**

1. Subtitles applied LAST in the filter chain
2. Per-segment extract → lossless `-c copy` concat
3. 30ms audio fades at every boundary
4. Overlays use `setpts=PTS-STARTPTS+T/TB` for PTS shifting
5. Master SRT uses output-timeline offsets
6. Never cut inside a word
7. Pad cut edges 30–200ms
8. Word-level verbatim ASR only
9. Cache transcripts per source
10. Parallel sub-agents for animations
11. Strategy confirmation before execution
12. All session outputs in `<videos_dir>/edit/`

## Stage 2 — Decorate (Hyperframes)

**Input:** `episodes/<n>/edit/preview.mp4` + `BRAND.md` + a list of overlay
positions chosen during the strategy phase.

**Output:** `episodes/<n>/motion-graphics/*.mp4` — one transparent-background
MP4 per overlay (lower-third, chapter card, code overlay, intro/outro).

**Process:**

**Step 0 — Plan mode (do this before writing any HTML).**

Describe desired beats in natural language: what graphic, what anchor word
triggers it, what timestamp, what layout, what color. Claude produces a
beat timeline:

| Beat | Anchor word | Timestamp | Layout | Color |
|---|---|---|---|---|
| A — intro card | "example" | 0.0s | Left-half card | Teal |
| B — mistake callout | "mistakes" | 8.4s | Bottom bar | Orange |

Cross-check anchor timestamps against `edit/takes_packed.md`. Review the
plan against `docs/MOTION_PHILOSOPHY.md`. Approve (or iterate) before any
HTML is written. **A wrong plan costs one round-trip. Wrong HTML costs ten.**

For every overlay needed:

1. **Pick a template** from `templates/`:
   - `templates/lower-third/` — instructor name + title, slides in from left
   - `templates/chapter-card/` — full-screen between chapters
   - `templates/code-overlay/` — syntax-highlighted code block
   - `templates/intro-outro/` — episode title and end card
2. **Parameterize.** Write `episodes/<n>/motion-graphics/<name>.params.json`
   with the episode-specific text values (chapter title, code snippet, etc.).
   Brand values (palette, typography, timing) are injected from `BRAND.md`
   at render time — do not copy or hard-code them in a template duplicate.
3. **Preview.** `cd templates/<name> && npx hyperframes preview` to verify
   in the browser (`localhost:3002`). Use the Hyperframes timeline editor
   to adjust beat timing by dragging — changes write back to the composition
   HTML. Iterate here before rendering.
4. **Render.** `npx hyperframes render --output episodes/<n>/motion-graphics/<name>.mp4`
   from the template directory. Hyperframes produces a deterministic MP4
   with alpha channel where the template uses transparency.
5. **Verify frames.** Capture a screenshot of each beat's key frame and
   inspect it before proceeding to Stage 3. Check: correct text, no clipping,
   brand values applied, no black frames, composition fits the 1920×1080
   frame. If anything is wrong, fix the composition and re-render here —
   don't carry broken overlays into the composite step. Store screenshots
   in `episodes/<n>/motion-graphics/verify/`.

**Spawn animations in parallel sub-agents** when more than one overlay
is needed for the episode. Each sub-agent gets a self-contained brief:
template path, episode-specific values, output path, BRAND.md reference.
Total wall time ≈ slowest animation.

**Hyperframes-specific rules to remember:**

- Root element must have `data-composition-id`, `data-width`, `data-height`
- Timed elements need `class="clip"` plus `data-start`, `data-duration`,
  `data-track-index`
- GSAP timelines must be created `{ paused: true }` and registered on
  `window.__timelines[<id>]`
- Use the `/hyperframes` slash command for composition help — it loads the
  full skill context

## Stage 3 — Composite (`ffmpeg`)

**Input:** `edit/preview.mp4` + every `motion-graphics/*.mp4` + their
in/out timestamps from the strategy.

**Output:** `episodes/<n>/final/final.mp4` — Udemy-ready delivery.

**Process:**

For each overlay, build an `overlay` filter with `enable='between(t,IN,OUT)'`.
Chain them all together in one ffmpeg call:

```bash
ffmpeg -i edit/preview.mp4 \
       -i motion-graphics/lower-third.mp4 \
       -i motion-graphics/chapter-1.mp4 \
       -i motion-graphics/chapter-2.mp4 \
       -filter_complex "
         [0:v][1:v] overlay=enable='between(t,4.2,8.2)' [v1];
         [v1][2:v]  overlay=enable='between(t,120,123.5)' [v2];
         [v2][3:v]  overlay=enable='between(t,420,423.5)' [vout]
       " \
       -map "[vout]" -map 0:a \
       -c:v libx264 -crf 18 -pix_fmt yuv420p \
       -c:a aac -b:a 192k -ar 48000 \
       final/final.mp4
```

Output settings come from `BRAND.md` Section 10. Don't deviate — Udemy
rejects non-conforming uploads.

**Self-evaluate the composite:**

- `ffprobe` → confirm 1920x1080, 30fps, H.264 + AAC, MP4
- `timeline_view` on `final.mp4` at every overlay in/out point — confirm
  the overlay actually appears, isn't hidden, isn't misaligned
- Spot-check 3 random points for color grade consistency
- Listen to the first 10s and last 10s for audio level consistency

## Naming convention

| File | Path |
|---|---|
| Raw takes | `episodes/<n>/raw/<camera>-<take>.MP4` |
| Cached transcripts | `episodes/<n>/edit/transcripts/<source>.json` |
| Packed transcript | `episodes/<n>/edit/takes_packed.md` |
| EDL | `episodes/<n>/edit/edl.json` |
| Cut preview | `episodes/<n>/edit/preview.mp4` |
| Master subtitles | `episodes/<n>/edit/master.srt` |
| Per-overlay render | `episodes/<n>/motion-graphics/<name>.mp4` |
| Overlay verify frames | `episodes/<n>/motion-graphics/verify/<name>-frame.png` |
| Final delivery | `episodes/<n>/final/final.mp4` |
| Session memory | `episodes/<n>/project.md` |

## When something goes wrong

| Symptom | Likely cause | Fix |
|---|---|---|
| Audio pop at every cut | Missing 30ms fade (Hard Rule 3) | Re-render with `--build-subtitles` |
| Subtitle hidden at 0:14 | Overlay applied after subtitles (Hard Rule 1 violated) | Reorder filter chain |
| Animation shows mid-frame at start | Missing `setpts=PTS-STARTPTS+T/TB` (Hard Rule 4) | Update overlay filter |
| Caption drifts after segment N | Master SRT not using output-timeline offsets (Hard Rule 5) | Rebuild SRT from EDL |
| Cut sounds choppy mid-word | Cut not on word boundary (Hard Rule 6) | Re-snap to nearest word boundary |
| Re-runs cost ElevenLabs $$ | Re-transcribing cached sources (Hard Rule 9) | Verify cache check by hash |
| Hyperframes render shows wrong colors | Brand vars not read from `BRAND.md` | Inject palette as CSS custom properties at composition root |

## Cost & time budget per episode

| Stage | Time | Cost |
|---|---|---|
| Stage 1 — transcribe + pack | 2–4 min | ~$0.40 / 10 min audio |
| Stage 1 — strategy + EDL | 5–10 min (LLM) | ~$0.50–$1 in tokens |
| Stage 1 — render preview | 1–3 min | local compute |
| Stage 2 — beat planning + HTML build | 10–20 min (LLM) | ~$1.50–$4 in tokens |
| Stage 2 — render (parallel) | 1–2 min | local compute |
| Stage 3 — composite | 30–60 sec | local compute |
| **Total per 12-min episode** | **~20–30 min wall time** | **~$3–$7** |
