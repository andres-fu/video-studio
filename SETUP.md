# Pre-Flight Checklist

Everything you need to do once before producing your first episode.
Items marked **🔴 blocking** must be done before the pipeline runs at all.
Items marked **🟡 nice-to-have** can be deferred and added per-episode.

---

## Accounts & API keys

- [ ] **🔴 ElevenLabs Scribe API key** — used by `video-use` for word-level transcription.
  - Sign up: <https://elevenlabs.io/sign-up>
  - Generate key: <https://elevenlabs.io/app/settings/api-keys>
  - **Plan needed:** the free tier (10k credits/month) is enough for ~30 minutes of audio
    per month. For a real Udemy course, the **Starter plan ($5/month, 30k credits)** or
    **Creator ($22/month, 100k credits)** is more realistic.
  - **Cost reality check:** Scribe charges roughly $0.40 per 10 minutes of audio.
    A typical 30-episode Udemy course at 12 min/episode ≈ 6 hours total ≈ ~$15 in transcription.
  - Where it goes: paste into `.env` as `ELEVENLABS_API_KEY=...`

- [ ] **🟡 Anthropic API key** — only if you want to call Claude outside Claude Code itself.
  Claude Code uses its own auth via `claude login`. Skip unless you have a specific reason.

---

## Local installs (one-time)

- [ ] **🔴 Node.js 22+** — `node --version` must be ≥ v22. <https://nodejs.org/>
- [ ] **🔴 Python 3.11+** — `python3 --version` must be ≥ 3.11
- [ ] **🔴 FFmpeg + ffprobe** on PATH — `brew install ffmpeg` (macOS) or `apt install ffmpeg` (Linux)
- [ ] **🔴 Git** — for cloning the video-use repo
- [ ] **🔴 Claude Code** — `npm install -g @anthropic-ai/claude-code` then `claude login`
- [ ] **🟡 yt-dlp** — only if you want to pull example footage from YouTube. `brew install yt-dlp`

After these are in place, `./install.sh` from the studio root handles the rest
(clones video-use, registers it as a Claude Code skill, installs Hyperframes,
downloads brand fonts).

---

## Brand inputs (BRAND.md TODOs)

These are the values I left as `<!-- TODO -->` placeholders in `BRAND.md`.
Fill them in before the first episode — every overlay reads from here.

- [ ] **🔴 Course name** — appears on intro card every episode
- [ ] **🔴 Course tagline** — one line under the title on the intro card
- [ ] **🔴 Instructor name** — for lower-thirds
- [ ] **🔴 Instructor title** — appears under your name in lower-thirds
- [ ] **🟡 Course URL** — for outro card / end screen
- [ ] **🟡 Logo, light variant** — `templates/_assets/logo-light.svg`
- [ ] **🟡 Logo, dark variant** — `templates/_assets/logo-dark.svg`
- [ ] **🟡 Color palette confirmation** — defaults are blue on near-black; confirm or override
- [ ] **🟡 Font confirmation** — defaults are Inter + JetBrains Mono; confirm or override

---

## Audio assets

The chapter cue, intro sting, and outro sting in `BRAND.md` Section 9 are
optional but make the course feel polished. Easiest path: license a track
from Epidemic Sound, Artlist, or Musicbed and trim to spec.

- [ ] **🟡 Intro sting** — 2–3s, ends on tonic, -18 LUFS → `templates/_assets/audio/intro-sting.wav`
- [ ] **🟡 Chapter cue** — 0.4s soft tone → `templates/_assets/audio/chapter-cue.wav`
- [ ] **🟡 Outro sting** — 3–4s, resolves → `templates/_assets/audio/outro-sting.wav`

If you skip these, Claude Code will use silence and flag it in the session memory.

---

## Verification

After completing the blocking items, run:

```bash
./install.sh
```

You should see "all checks passed". If not, the script prints exactly what's missing.

Then drop a short test clip into `episodes/_template/raw/` (any 30-second video file
works — even a phone recording) and run:

```bash
cp -R episodes/_template episodes/00-smoke-test
cd episodes/00-smoke-test
claude
```

Inside Claude Code:

> Read CLAUDE.md and BRAND.md, then run a smoke test on the raw footage:
> just transcribe, propose a basic 15-second cut, and render a preview.
> No motion graphics needed — I just want to confirm the pipeline works.

If that produces `episodes/00-smoke-test/edit/preview.mp4`, the studio is live.
