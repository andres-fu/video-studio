# Episode 01 — Intro

**Target length:** TBD (current raw is a 30s pipeline smoke test)
**Udemy section:** TBD
**Raw sources:** `andres1.mov` (real speech, 720p/15fps), `test.mp4` (silent placeholder)

---

<!-- Append a session block after each work session using this format:

## Session 1 — YYYY-MM-DD

**Strategy:** One paragraph describing the cut approach, take selection,
pacing direction, and overlay plan.

**Decisions:** Specific take choices, cut calls, overlay timestamps, color
assignments, anything that required a judgment call.

**Brand calls:** Any visual or copy decisions not explicitly covered by
BRAND.md — flag these for potential backport.

**Outstanding:** Anything deferred to the next session.

-->

## Session 1 — 2026-04-25

**Strategy:** Pipeline smoke test only — not content editing. Transcribed `andres1.mov` via ElevenLabs Scribe (123 words, 9 phrases, 30s). `test.mp4` is a silent placeholder detected as Polish audio event. Built a 3-range EDL covering the cleanest 13s of test speech, rendered a `neutral_punch` preview at 1920×1080 to confirm the full chain runs end to end.

**Decisions:** Used `andres1.mov` as the sole source. Chose ranges [0.30-2.18], [2.74-5.96], [18.40-26.44] — cleanest speech, includes dog bark in the WRAP segment intentionally (smoke test, not content). Grade: `neutral_punch`. No subtitles, no overlays.

**Brand calls:** None — this session was pipeline verification, not content work.

**Outstanding:** ~~(1) `render.py` hardcodes `-r 24`~~ — fixed in Session 2. (2) Real course footage not yet recorded. (3) `test.mp4` can be deleted once confirmed it's not needed.

## Session 2 — 2026-04-25

**Strategy:** Completed the full Stage 2 → Stage 3 pipeline. Built both Hyperframes compositions (lower-third glass card + chapter card), composited overlays, and burned subtitles. Resolved ffmpeg/libass installation blocker from Session 1 by replacing core Homebrew ffmpeg with the `homebrew-ffmpeg` tap build (includes libass).

**Decisions:**
- Lower-third redesigned with liquid glass effect: black canvas + colorkey, gradient bg min opacity 0.28 to survive `similarity=0.15` colorkey, iridescent shimmer layer, Inter 26px/16px, GSAP slide-in/out per BRAND.md timing.
- Chapter card: full-bleed `--brand-bg`, sequential reveal (01 → title → rule), 3.5s total.
- Overlay timing: lower-third `0.3s → 5.2s`, chapter card `9.0s → 12.5s`.
- Subtitles: `social-bold` style from BRAND.md, Inter Bold TTF downloaded to `templates/_assets/fonts/Inter-Bold.ttf`, burned via libass `subtitles` filter. `MarginV=40` for cinema bottom positioning.
- Easter egg: Zapfino "megan i love you" in pink (`#FFB6C1`), top-right corner, baked into `final.mp4`.
- `render.py` line 189 fixed: `-r "24"` → `-r "30"`.

**Brand calls:** Inter Bold TTF added to `templates/_assets/fonts/` — `install.sh` should download this alongside woff2 files for future episodes so libass subtitle rendering works out of the box.

**Outstanding:** (1) Real course footage not yet recorded — all content is smoke-test material. (2) `install.sh` needs `brew install homebrew-ffmpeg/ffmpeg/ffmpeg` instead of `brew install ffmpeg` — core Homebrew tap lacks libass, subtitles will break on a fresh clone. (3) `install.sh` needs to download `Inter-Bold.ttf` (TTF format, not just woff2) for libass subtitle rendering. (4) `test.mp4` in `raw/` safe to delete.
