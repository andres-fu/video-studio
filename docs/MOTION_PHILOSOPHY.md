# Motion Philosophy — Udemy Course Videos

Eleven laws for premium motion design adapted for technical course content.
Read this before planning any Stage 2 beat. These laws are the difference
between a timeline full of "nice overlays" and a video that actually teaches.

---

## Law 1 — Narrative economy

One idea per beat. A beat's motion graphics should carry a single concept,
not two or three. If you're tempted to put two messages on screen at once,
split it into two beats.

Beat duration for course content: ~2–5s visible. Don't rush a concept that
takes 8s to say. Don't linger past the moment.

## Law 2 — Negative space dominance

The frame is mostly dark. Brand background is `#0A0A0A` — trust it. Motion
graphics are accents on darkness, not wallpaper. If a composition feels
busy, remove elements until it breathes.

**The speaker is always the primary element.** Every overlay must coexist
with the talking head, not compete with it.

## Law 3 — Light over color

Chrome gradients, glassmorphism, glows, and halos read as premium. Flat
color blocks read as slides. Default to glass/light effects over solid fills.
Two accent colors maximum per frame (see Law 7).

## Law 4 — No dead frames

Every frame in a motion graphic has motion — even a "hold" state should
have a subtle pulse, shimmer, or breathing scale. Static = dead. If a
composition has no animation loop during its hold phase, add one.

This does not mean constant movement. It means no frame looks identical
to the previous frame.

## Law 5 — Motion blur as transition

Scene transitions use kinetic energy: streaks, wipes, scale-ups, slide-ins.
Hard cuts between overlay states look amateurish. Every composition entry
and exit has an easing curve — never `linear`. See `BRAND.md` Section 5
for the studio's timing values.

## Law 6 — Symbolic object language

Show the concept visually, not just textually. A beat about "cutting
mistakes" gets scissors or a waveform with a cut mark. A beat about "raw
file becomes finished video" gets a progression graphic. Text alone is a
slide. Text plus a visual metaphor is motion design.

For code overlays: syntax-highlighted snippets are the visual element.
Don't add decoration for its own sake — the code *is* the symbol.

## Law 7 — One hue per concept

Assign colors intentionally. If teal means "what we're building," use teal
every time that concept appears. If orange means "warning / gotcha," use it
only for warnings. Never reassign a hue mid-episode.

Default to `--brand-primary` for the first concept. Introduce a second hue
only when a genuinely distinct concept needs differentiation.

## Law 8 — Typography carries the lesson

On-screen text drives most of the learning impact — treat it like a design
element, not a label. Use the typographic hierarchy in `BRAND.md` Section 3.
Chapter titles are large and confident. Captions are small and subordinate.
Never let label text compete with title text.

Karaoke-style word-by-word reveal is high engagement for key phrases. Use
it sparingly — only for the line you want students to remember.

## Law 9 — Strategic stillness

Hero frames — the moment a key concept lands — hold for 2–5 seconds minimum.
Don't cut away the instant the animation finishes. Let the student read it.

The HOOK and RECAP moments of a Udemy lesson deserve the most stillness.
Students re-watch these sections.

## Law 10 — Consistency across beats

Every beat in an episode shares a visual family: same corner radius, same
glassmorphism style, same base typography. Individual beats differ by color
(Law 7) and content, not by structural style. An episode where Beat A looks
like iOS glass and Beat B looks like flat Material design is broken.

Before building Beat 2, render Beat 1 and use it as the visual reference.

## Law 11 — Timeline integrity

No black frames. No flash frames. Compositions must:

- Start visibly (opacity > 0 at `data-start`)
- End visibly (hold opacity until after `data-start + data-duration`)
- Have PTS shifting applied (`setpts=PTS-STARTPTS+T/TB` in the ffmpeg overlay)

A black flash at an overlay boundary means the composition duration is
shorter than the ffmpeg `between(t,IN,OUT)` window. Fix the composition
duration, not the ffmpeg command.
