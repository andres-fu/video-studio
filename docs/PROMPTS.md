# Prompt Patterns

Copy-pasteable prompts for common pipeline tasks. Customize the bracketed
placeholders before sending.

---

## Smoke test (first-time setup check)

```
Read CLAUDE.md and BRAND.md, then run a smoke test on the raw footage in
raw/: just transcribe, propose a basic 15-second cut, and render a preview.
No motion graphics needed — I just want to confirm the pipeline works.
```

---

## Stage 1 — Start a new episode cut

```
Read CLAUDE.md, BRAND.md, and docs/PIPELINE.md. Then:
1. Inventory raw/ with ffprobe
2. Transcribe and pack the transcript
3. Propose a cut strategy for a [target length]-minute Udemy [episode type:
   intro / demo / lecture / recap] episode

Wait for my approval before building the EDL.
```

---

## Stage 1 — Approve strategy and build

```
That strategy looks good. Build the EDL and render a preview. Flag any
taste calls before rendering the final cut.
```

---

## Stage 1 — Tighten pacing

```
The cut feels [too slow in the intro / too rushed through the demo / padded
in the recap]. Tighten it: [specific instruction, e.g. "cut the intro from
45s to under 20s, keep the hook question"].
```

---

## Stage 2 — Start motion graphics (plan mode)

```
Enter plan mode. Read docs/MOTION_PHILOSOPHY.md and the transcript at
edit/takes_packed.md. Then propose a beat timeline for the motion graphics:
what graphic appears at what timestamp, what layout, what color assignment.

Reference docs/LESSON_STYLE.md if it has entries for this episode type.
Wait for my approval before writing any HTML.
```

---

## Stage 2 — Approve beat plan and build

```
Beat plan looks good. Build the compositions and render each overlay.
Take a screenshot of every beat's key frame before moving on — store them
in motion-graphics/verify/. Show me the screenshots before proceeding to
the composite.
```

---

## Stage 2 — Iterate on a specific beat

```
Beat [A / B / name]: [what's wrong, e.g. "the card is covering my face —
scale it down and shift it left" / "wrong color, should be orange not teal"
/ "the hold is too short, extend it by 1.5s"]. Fix this beat and re-render.
Show me the updated verify frame.
```

---

## Stage 3 — Composite and deliver

```
The overlays look good. Run the final composite and verify the output:
ffprobe to confirm 1920×1080 / 30fps / H.264 / AAC, then timeline_view at
every overlay in/out point. Drop the result in final/final.mp4.
```

---

## After the episode — update style reference

```
The motion graphics for this episode are locked. Review what worked and
append an entry to docs/LESSON_STYLE.md for a [episode type] episode.
Flag any style decisions worth backporting to BRAND.md.
```

---

## Troubleshooting — audio pop at a cut

```
There's an audio pop at [timestamp]. Check whether the 30ms fade is applied
at that boundary. Re-render that segment with the fade and show me the
waveform at ±1.5s.
```

---

## Troubleshooting — overlay appears at wrong time

```
The [beat name] overlay is appearing at [wrong time] instead of [correct
time]. The anchor word is "[word]" — check its timestamp in
edit/takes_packed.md and correct the composition's data-start value.
```
