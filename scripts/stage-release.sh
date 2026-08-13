#!/usr/bin/env bash
#
# stage-release.sh — build the Typst Universe submission directory from source.
#
# Produces release/preview/fubell/<version>/, which typst-publish.sh then copies
# into a clone of typst/packages.
#
# The repo keeps `#import "../lib.typ"` in template/main.typ so the example can be
# compiled in place during development. `typst init` copies only the template
# directory, so that path cannot resolve in a scaffolded project — this script
# rewrites it to `@preview/fubell:<version>` in the staged copy.
#
# Usage: scripts/stage-release.sh [--keep-old]

set -euo pipefail

C_RESET=$'\033[0m'
C_GREEN=$'\033[0;32m'
C_RED=$'\033[0;31m'
C_BLUE=$'\033[0;34m'
C_DIM=$'\033[2m'

info() { echo "${C_BLUE}==>${C_RESET} $1"; }
ok() { echo "${C_GREEN} ok${C_RESET} $1"; }
die() {
    echo "${C_RED}error:${C_RESET} $1" >&2
    exit 1
}

KEEP_OLD=false
for arg in "$@"; do
    case "$arg" in
        --keep-old) KEEP_OLD=true ;;
        -h | --help)
            sed -n '2,14p' "$0" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        *) die "unknown argument: $arg" ;;
    esac
done

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$REPO_ROOT"

command -v typst >/dev/null 2>&1 || die "typst not found in PATH"
[[ -f typst.toml ]] || die "typst.toml not found in $REPO_ROOT"

# Same parsing idiom as typst-publish.sh.
PKG_NAME=$(grep '^name' typst.toml | sed 's/.*= *"\([^"]*\)".*/\1/')
VERSION=$(grep '^version' typst.toml | sed 's/.*= *"\([^"]*\)".*/\1/')
THUMBNAIL=$(grep '^thumbnail' typst.toml | sed 's/.*= *"\([^"]*\)".*/\1/')

[[ -n "$PKG_NAME" ]] || die "could not parse name from typst.toml"
[[ -n "$VERSION" ]] || die "could not parse version from typst.toml"

STAGE="release/preview/$PKG_NAME/$VERSION"

info "Staging $PKG_NAME $VERSION → $STAGE"

# ---------------------------------------------------------------------------
# 1. Verify the package compiles from source before shipping it.
# ---------------------------------------------------------------------------
info "Compiling template/main.typ from source"
typst compile --root . --format pdf template/main.typ /dev/null ||
    die "source template does not compile — fix that before staging"
ok "source compiles"

# ---------------------------------------------------------------------------
# 2. Rebuild the staging directory.
# ---------------------------------------------------------------------------
if [[ -d "$STAGE" ]]; then
    rm -rf "$STAGE"
fi
mkdir -p "$STAGE"

# Files and directories that make up the published package.
rsync -a \
    --exclude '.DS_Store' \
    --exclude '*.pdf' \
    lib.typ src template typst.toml README.md LICENSE CHANGELOG.md ROADMAP.md \
    "$STAGE/"

ok "copied package files"

# ---------------------------------------------------------------------------
# 3. Rewrite the template import for the published package.
# ---------------------------------------------------------------------------
MAIN="$STAGE/template/main.typ"
[[ -f "$MAIN" ]] || die "$MAIN missing after copy"

python3 - "$MAIN" "$PKG_NAME" "$VERSION" <<'PY'
import re
import sys

path, pkg, version = sys.argv[1], sys.argv[2], sys.argv[3]
with open(path, encoding="utf-8") as f:
    text = f.read()

header = f'''// Thesis entry point — edit this file to write your thesis.
//
// Compile with:
//   typst compile main.typ
'''

# Drop the development-oriented header comment and replace it with one that is
# accurate for a scaffolded project.
text = re.sub(
    r"\A(//[^\n]*\n)+\n?",
    header + "\n",
    text,
    count=1,
)

text, n = re.subn(
    r'#import\s+"\.\./lib\.typ"',
    f'#import "@preview/{pkg}:{version}"',
    text,
    count=1,
)
if n != 1:
    sys.exit(f"expected exactly one '../lib.typ' import in {path}, replaced {n}")

with open(path, "w", encoding="utf-8") as f:
    f.write(text)
PY

grep -q "@preview/$PKG_NAME:$VERSION" "$MAIN" ||
    die "import rewrite did not take effect in $MAIN"
ok "rewrote import → @preview/$PKG_NAME:$VERSION"

# ---------------------------------------------------------------------------
# 4. Generate the thumbnail (first page of the example thesis).
# ---------------------------------------------------------------------------
if [[ -n "$THUMBNAIL" ]]; then
    info "Rendering $THUMBNAIL"
    typst compile --root . --format png --ppi 120 --pages 1 \
        template/main.typ "$STAGE/$THUMBNAIL" ||
        die "thumbnail render failed"
    thumb_bytes=$(wc -c <"$STAGE/$THUMBNAIL" | tr -d ' ')
    ok "thumbnail rendered (${thumb_bytes} bytes)"
fi

# ---------------------------------------------------------------------------
# 5. Smoke-test the staged package the way a user would consume it.
# ---------------------------------------------------------------------------
# typst resolves @preview packages through the platform cache directory
# (dirs::cache_dir()), checking it before hitting the network. Seeding the
# staged build there lets us exercise the exact `typst init` path a user takes
# for a version that is not published yet.
case "$(uname -s)" in
    Darwin) CACHE_BASE="$HOME/Library/Caches" ;;
    *) CACHE_BASE="${XDG_CACHE_HOME:-$HOME/.cache}" ;;
esac
CACHE_ROOT="$CACHE_BASE/typst/packages/preview/$PKG_NAME"
CACHE_DIR="$CACHE_ROOT/$VERSION"
SMOKE_DIR=$(mktemp -d)
CACHE_PREEXISTING=false
[[ -d "$CACHE_DIR" ]] && CACHE_PREEXISTING=true

cleanup() {
    rm -rf "$SMOKE_DIR"
    if [[ "$CACHE_PREEXISTING" == false && -d "$CACHE_DIR" ]]; then
        rm -rf "$CACHE_DIR"
        # Prune directories we created, stopping at anything still in use.
        rmdir "$CACHE_ROOT" 2>/dev/null || true
        rmdir "$CACHE_BASE/typst/packages/preview" 2>/dev/null || true
        rmdir "$CACHE_BASE/typst/packages" 2>/dev/null || true
        rmdir "$CACHE_BASE/typst" 2>/dev/null || true
    fi
}
trap cleanup EXIT

info "Smoke-testing 'typst init @preview/$PKG_NAME:$VERSION'"
mkdir -p "$CACHE_DIR"
rsync -a "$STAGE"/ "$CACHE_DIR"/

rmdir "$SMOKE_DIR"
typst init "@preview/$PKG_NAME:$VERSION" "$SMOKE_DIR" >/dev/null ||
    die "typst init failed"
(cd "$SMOKE_DIR" && typst compile main.typ) ||
    die "scaffolded project does not compile — the staged package is broken"
ok "scaffolded project compiles"

# ---------------------------------------------------------------------------
# 6. Report older staged versions.
# ---------------------------------------------------------------------------
if [[ "$KEEP_OLD" == false ]]; then
    for old in "release/preview/$PKG_NAME"/*/; do
        old_version=$(basename "$old")
        if [[ "$old_version" != "$VERSION" && -d "$old" ]]; then
            rm -rf "$old"
            ok "removed stale staging dir $old_version"
        fi
    done
fi

echo
echo "${C_GREEN}Staged $PKG_NAME $VERSION${C_RESET} → $STAGE"
echo "${C_DIM}Next: ./typst-publish.sh${C_RESET}"
