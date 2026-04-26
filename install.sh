#!/usr/bin/env bash
# install.sh — set up the video studio.
#
# Idempotent: re-running is safe. Each step checks for existing state
# before mutating. Fails fast with a useful error if anything is missing.

set -euo pipefail

# ---------------------------------------------------------------------------
# Logging helpers
# ---------------------------------------------------------------------------
readonly C_RESET='\033[0m'
readonly C_GREEN='\033[0;32m'
readonly C_YELLOW='\033[0;33m'
readonly C_RED='\033[0;31m'
readonly C_BLUE='\033[0;34m'

log()    { printf "${C_BLUE}[install]${C_RESET} %s\n" "$*"; }
ok()     { printf "${C_GREEN}  ✓${C_RESET} %s\n" "$*"; }
warn()   { printf "${C_YELLOW}  ⚠${C_RESET} %s\n" "$*"; }
fail()   { printf "${C_RED}  ✗${C_RESET} %s\n" "$*" >&2; exit 1; }

# ---------------------------------------------------------------------------
# Resolve script directory so the script works from anywhere
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# ---------------------------------------------------------------------------
# Step 1 — verify host tools
# ---------------------------------------------------------------------------
require_cmd() {
  local cmd="$1"
  local hint="$2"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    fail "Missing '$cmd'. Install it: $hint"
  fi
  ok "$cmd: $(command -v "$cmd")"
}

log "Step 1/6 — verifying host tools"
require_cmd ffmpeg  "brew install ffmpeg  (macOS)  |  apt install ffmpeg  (Linux)"
require_cmd ffprobe "ships with ffmpeg"
require_cmd node    "https://nodejs.org/  (need v22+)"
require_cmd npm     "ships with node"
require_cmd python3 "brew install python  (macOS)  |  apt install python3  (Linux)"
require_cmd git     "brew install git  (macOS)  |  apt install git  (Linux)"

# Node version check — hyperframes needs >= 22
node_major=$(node --version | sed 's/v//' | cut -d. -f1)
if (( node_major < 22 )); then
  fail "Node.js v22+ required, found v$(node --version). Upgrade and re-run."
fi
ok "node version >= 22"

# Python version check — video-use needs >= 3.11
python_minor=$(python3 -c 'import sys; print(sys.version_info.minor)')
python_major=$(python3 -c 'import sys; print(sys.version_info.major)')
if (( python_major < 3 || (python_major == 3 && python_minor < 11) )); then
  fail "Python 3.11+ required, found $(python3 --version). Upgrade and re-run."
fi
ok "python version >= 3.11"

# ---------------------------------------------------------------------------
# Step 2 — clone or update video-use
# ---------------------------------------------------------------------------
log "Step 2/6 — installing video-use (cutting layer)"

VIDEO_USE_DIR="$SCRIPT_DIR/skills/video-use"
VIDEO_USE_REPO="https://github.com/browser-use/video-use.git"

if [[ -d "$VIDEO_USE_DIR/.git" ]]; then
  ok "video-use already cloned, pulling latest"
  git -C "$VIDEO_USE_DIR" pull --ff-only
else
  # Don't clobber the vendored SKILL.md reference — clone into a temp dir
  # then move .git and source files into place.
  if [[ -f "$VIDEO_USE_DIR/SKILL.md" ]]; then
    log "Preserving vendored SKILL.md, cloning fresh repo alongside"
    rm -f "$VIDEO_USE_DIR/.SKILL.md.vendored" 2>/dev/null || true
    mv "$VIDEO_USE_DIR/SKILL.md" "$VIDEO_USE_DIR/.SKILL.md.vendored"
  fi
  git clone --depth 1 "$VIDEO_USE_REPO" "$VIDEO_USE_DIR.tmp"
  # Merge clone over our directory
  shopt -s dotglob
  mv "$VIDEO_USE_DIR.tmp"/* "$VIDEO_USE_DIR/"
  rmdir "$VIDEO_USE_DIR.tmp"
  shopt -u dotglob
  ok "video-use cloned"
fi

# Register video-use as a Claude Code skill via symlink
CLAUDE_SKILLS_DIR="$HOME/.claude/skills"
mkdir -p "$CLAUDE_SKILLS_DIR"
if [[ -L "$CLAUDE_SKILLS_DIR/video-use" ]]; then
  ok "video-use already registered as Claude Code skill"
elif [[ -e "$CLAUDE_SKILLS_DIR/video-use" ]]; then
  warn "$CLAUDE_SKILLS_DIR/video-use exists but isn't a symlink — leaving it alone"
else
  ln -s "$VIDEO_USE_DIR" "$CLAUDE_SKILLS_DIR/video-use"
  ok "registered video-use at $CLAUDE_SKILLS_DIR/video-use"
fi

# Install Python deps for video-use inside a venv
log "  installing video-use Python dependencies"
if [[ -f "$VIDEO_USE_DIR/pyproject.toml" ]]; then
  VENV_DIR="$VIDEO_USE_DIR/.venv"
  if [[ ! -d "$VENV_DIR" ]]; then
    python3 -m venv "$VENV_DIR"
    ok "created venv at $VENV_DIR"
  fi
  "$VENV_DIR/bin/pip" install --quiet -e "$VIDEO_USE_DIR"
  ok "video-use deps installed (venv: $VENV_DIR)"
else
  warn "no pyproject.toml in video-use — skipping pip install"
fi

# ---------------------------------------------------------------------------
# Step 3 — install Hyperframes skills (interactive TUI — must run on a TTY)
# ---------------------------------------------------------------------------
log "Step 3/6 — installing Hyperframes (motion graphics layer)"
# The skills installer is interactive: it shows a skill-picker TUI.
# Run it directly so it gets a real TTY; pipe-based approaches break it.
npx --yes skills add heygen-com/hyperframes
ok "Hyperframes skills installed (select all skills when prompted)"

# ---------------------------------------------------------------------------
# Step 4 — fonts
# ---------------------------------------------------------------------------
log "Step 4/6 — downloading brand fonts"
FONTS_DIR="$SCRIPT_DIR/templates/_assets/fonts"
mkdir -p "$FONTS_DIR"

download_font() {
  local url="$1"
  local dest="$2"
  if [[ -f "$dest" ]]; then
    return 0
  fi
  if curl -fsSL "$url" -o "$dest"; then
    ok "  downloaded $(basename "$dest")"
  else
    warn "  failed to download $(basename "$dest") — fetch manually if needed"
  fi
}

# Inter + JetBrains Mono via jsDelivr / @fontsource (stable, versioned)
download_font "https://cdn.jsdelivr.net/npm/@fontsource/inter@5/files/inter-latin-400-normal.woff2" \
              "$FONTS_DIR/Inter-Regular.woff2"
download_font "https://cdn.jsdelivr.net/npm/@fontsource/inter@5/files/inter-latin-600-normal.woff2" \
              "$FONTS_DIR/Inter-SemiBold.woff2"
download_font "https://cdn.jsdelivr.net/npm/@fontsource/inter@5/files/inter-latin-700-normal.woff2" \
              "$FONTS_DIR/Inter-Bold.woff2"
download_font "https://cdn.jsdelivr.net/npm/@fontsource/jetbrains-mono@5/files/jetbrains-mono-latin-500-normal.woff2" \
              "$FONTS_DIR/JetBrainsMono-Medium.woff2"

# ---------------------------------------------------------------------------
# Step 5 — environment file
# ---------------------------------------------------------------------------
log "Step 5/6 — environment file"
if [[ -f "$SCRIPT_DIR/.env" ]]; then
  ok ".env already exists — leaving it alone"
else
  cp "$SCRIPT_DIR/.env.example" "$SCRIPT_DIR/.env"
  warn "Created .env from .env.example — edit it now to add ELEVENLABS_API_KEY"
fi

# ---------------------------------------------------------------------------
# Step 6 — sanity check
# ---------------------------------------------------------------------------
log "Step 6/6 — sanity check"
errors=0

[[ -f "$SCRIPT_DIR/BRAND.md" ]]                      || { warn "missing BRAND.md";              errors=$((errors+1)); }
[[ -f "$SCRIPT_DIR/CLAUDE.md" ]]                     || { warn "missing CLAUDE.md";             errors=$((errors+1)); }
[[ -d "$SCRIPT_DIR/skills/video-use" ]]              || { warn "missing skills/video-use";      errors=$((errors+1)); }
[[ -d "$SCRIPT_DIR/episodes/_template" ]]            || { warn "missing episodes/_template";    errors=$((errors+1)); }
[[ -L "$CLAUDE_SKILLS_DIR/video-use" ]]              || { warn "video-use not symlinked into ~/.claude/skills/"; errors=$((errors+1)); }

if (( errors > 0 )); then
  fail "$errors issue(s) found — review warnings above"
fi

ok "all checks passed"
echo
log "Setup complete."
echo
echo "Next steps:"
echo "  1. Edit .env and add your ELEVENLABS_API_KEY"
echo "  2. Edit BRAND.md — fill in TODOs (course name, instructor, etc.)"
echo "  3. Drop logo files into templates/_assets/"
echo "  4. Create your first episode:  cp -R episodes/_template episodes/01-intro"
echo "  5. cd episodes/01-intro && claude"
