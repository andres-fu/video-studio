# Video Studio — Udemy Course Production Pipeline

A Claude Code-driven studio for producing a Udemy course series end-to-end.
Drop raw footage in, get polished episodes out. The pipeline is two open-source
skills wired together with a brand reference file:

```
raw footage  ─┐
              │   ┌─ video-use ─┐    ┌─ hyperframes ─┐
              ├──►│ cut filler  │ ──►│ motion graphics│ ──► final.mp4
BRAND.md ─────┤   │ color grade │    │ lower-thirds   │
              │   │ subtitles   │    │ code overlays  │
              │   │ self-eval   │    │ chapter cards  │
              │   └─────────────┘    └────────────────┘
```

## What this is

A repository structure plus instructions that teach Claude Code how to:

1. **Cut** a raw episode — remove filler words (`umm`, `uh`, false starts), dead air, retake the best of multiple takes, color grade, burn subtitles. (Powered by [`browser-use/video-use`](https://github.com/browser-use/video-use).)
2. **Decorate** the cut — add lower-thirds, animated code callouts, chapter markers, intro/outro cards in your brand. (Powered by [`heygen-com/hyperframes`](https://github.com/heygen-com/hyperframes).)
3. **Stay consistent** across every episode by reading from a single `BRAND.md`.

You drive it from your terminal with Claude Code:

```
cd episodes/01-intro
claude
> edit this raw footage into a 12-minute intro episode using the brand
```

## What this is *not*

- A timeline-based GUI editor. There's no scrubbing.
- A black box. Every cut decision is logged in plain English in `project.md` per episode.
- Tied to any one cloud service. ElevenLabs Scribe is the only paid dependency.

## Prerequisites

- macOS or Linux (Windows works via WSL)
- Node.js 22+
- Python 3.11+
- FFmpeg + ffprobe on PATH
- Claude Code (`npm install -g @anthropic-ai/claude-code`)
- An [ElevenLabs API key](https://elevenlabs.io/app/settings/api-keys) — used by video-use for transcription

## Setup (one time)

Work through **`SETUP.md`** — it's the consolidated pre-flight checklist
covering accounts, local installs, and brand inputs. The blocking items
(🔴) must be done before the pipeline runs; the rest can be filled in
later. Then:

```bash
./install.sh           # idempotent — re-running is safe
$EDITOR .env           # paste in ELEVENLABS_API_KEY
$EDITOR BRAND.md       # fill in the TODOs
```

## Usage — one episode at a time

```bash
# 1. Make a working directory for the episode
cp -R episodes/_template episodes/01-intro

# 2. Drop raw recordings in episodes/01-intro/raw/

# 3. Open Claude Code in that directory
cd episodes/01-intro
claude

# 4. Inside Claude Code, prompt:
> Read CLAUDE.md and ../../BRAND.md, then edit my raw footage in raw/
> into a Udemy intro episode. Target 8–12 minutes. Use the brand template
> for lower-thirds, intro card, and chapter markers.
```

Claude Code will:

1. Inventory and transcribe the raw files
2. Propose a cut strategy in plain English — **wait for your OK**
3. Build the cut, generate motion graphics in parallel, compose, self-eval
4. Drop `final.mp4` in `episodes/01-intro/final/`

Iteration is conversational: *"cut the intro tighter"*, *"swap the chapter
card font to Inter"*, *"add a code overlay at 4:32 showing the manifest.json"*.

## Project layout

```
video-studio/
├── README.md                ← you are here
├── CLAUDE.md                ← master instructions Claude Code reads on startup
├── BRAND.md                 ← single source of truth for brand identity
├── install.sh               ← one-shot dependency setup
├── .env.example             ← API key template
├── skills/
│   ├── video-use/           ← cutting skill (vendored SKILL.md for reference)
│   └── hyperframes/         ← motion graphics skill (installed via npx)
├── episodes/
│   ├── _template/           ← copy this for each new episode
│   └── 01-intro/            ← example episode (you create these)
├── templates/               ← reusable Hyperframes compositions per brand
│   ├── lower-third/
│   ├── code-overlay/
│   ├── chapter-card/
│   └── intro-outro/
└── docs/
    ├── PIPELINE.md          ← the full process, end to end
    └── PROMPTS.md           ← copy-pasteable prompt patterns
```

## Cost estimate per episode

- **ElevenLabs Scribe transcription:** ~$0.40 per 10 minutes of audio
- **Claude Code tokens:** typically $1–$3 per episode depending on iteration
- **Compute (rendering):** local FFmpeg + headless Chrome. Free.

A 12-minute Udemy episode usually lands at **under $5 all-in**.

## Where this comes from

This studio is a thin layer over two open-source projects:

- [`browser-use/video-use`](https://github.com/browser-use/video-use) (Apache 2.0) — handles the cut
- [`heygen-com/hyperframes`](https://github.com/heygen-com/hyperframes) (Apache 2.0) — handles the motion graphics

The integration glue, brand spec, episode template, and Udemy-specific
prompts are this repo's contribution.
