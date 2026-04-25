# Claude Code Instructions — Video Studio

You are operating inside a video production studio for a Udemy course series.
Your job is to turn raw footage in `episodes/<n>/raw/` into a polished
Udemy-ready `final.mp4` in `episodes/<n>/final/`.

## Read these on startup (read in parallel — no ordering dependency)

1. `BRAND.md` — colors, fonts, logo, lower-third style, animation timing,
   subtitle style. **Single source of truth.** If anything else conflicts
   with `BRAND.md`, `BRAND.md` wins.
2. `docs/PIPELINE.md` — the full operational spec: stages, steps, hard rules,
   commands, cost budget. Source of truth for how to execute.
3. `docs/MOTION_PHILOSOPHY.md` — eleven creative laws for motion graphics.
   Read before any Stage 2 work.
4. The current episode's `project.md` if it exists — prior session memory.

## The pipeline

Three stages: **Cut** (`video-use`) → **Decorate** (Hyperframes) → **Composite** (ffmpeg).

Full spec — steps, commands, hard rules, self-eval gates, cost budget — is in
`docs/PIPELINE.md`. Load and follow it. What follows here is what PIPELINE.md
does not cover: brand constraints, studio hard rules, and session memory.

The `/hyperframes` slash command is available in this terminal for composition
authoring (installed via `npx skills add heygen-com/hyperframes`).

## Hard rules for THIS studio (in addition to video-use rules)

1. **Brand consistency before cleverness.** Every motion graphic reads its
   palette, fonts, and timing from `BRAND.md`. No drift across episodes.
2. **Udemy delivery spec.** Final output is `1920x1080 @ 30fps, H.264, AAC
   192kbps, MP4`. Lock this in `final/`.
3. **Confirm strategy before any cut or render.** No exceptions, even for
   "small" edits. The user runs the green light.
4. **One episode = one working directory.** Never let outputs from one
   episode leak into another.
5. **Persist memory per episode.** Append a session block to the episode's
   `project.md` after each work session — strategy, decisions, rationale,
   outstanding items.
6. **Self-evaluate before presenting.** Run `timeline_view` on the rendered
   output at every cut boundary AND at every overlay in/out point. Cap
   self-eval at 3 passes; flag remaining issues to the user rather than
   looping.
7. **Never write outside the current episode's `edit/`, `motion-graphics/`,
   and `final/` directories.** The studio root, `templates/`, `BRAND.md`,
   and other episodes are read-only in a working session unless the user
   explicitly asks you to modify them.

## Udemy-specific cut craft

Udemy course videos have a stable structure. Treat this as the default
archetype unless the user says otherwise:

```
HOOK (5–15s)      — the question or problem this lesson answers
CONTEXT (10–30s)  — why it matters, what they'll know by the end
DEMO/STEPS        — the actual teaching, broken into chapters
GOTCHAS (~30s)    — common pitfalls, where students get stuck
RECAP (10–20s)    — the takeaway, one-sentence-per-step summary
NEXT (5–10s)      — what they learn in the next lesson
```

Per-chapter: write a chapter card beat composition using the `/hyperframes`
skill, with the chapter title styled per `BRAND.md` typography.
Lower-third on the speaker's first appearance only — not every cut.

## When you don't know

Ask the user. Specifically:
- Brand values not in `BRAND.md` → ask, then suggest adding to `BRAND.md`
- Cut ambiguity (two takes both work) → present both, let user pick
- Pacing taste (tight vs cinematic) → ask once at strategy, then commit

Never silently make creative decisions about brand or pacing that the user
hasn't confirmed.

## Memory format

After each session, append to `episodes/<n>/project.md`:

```
## Session N — YYYY-MM-DD

**Strategy:** one paragraph.
**Decisions:** take choices, cuts, overlays, rationale.
**Brand calls:** anything resolved that isn't in BRAND.md (flag for backport).
**Outstanding:** deferred items.
```

Read `project.md` on startup. Summarize the last session in one sentence
before asking the user how to continue.

After an episode's motion graphics clear review, flag any style decisions
worth promoting to `docs/LESSON_STYLE.md`. Once that file has entries,
the per-episode style prompt becomes: "build like LESSON_STYLE.md says."
