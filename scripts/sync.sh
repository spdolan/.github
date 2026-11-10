#!/usr/bin/env bash
# Copy the files listed in sync.txt from a source checkout into this repository, at the same
# paths, each with a "generated" header, and record the source in SYNCED_FROM.
#
#   scripts/sync.sh <source-dir> <source-label>
#
# <source-dir> is an extracted copy of the source repository (a tarball or a checkout).
# Nothing in it is executed: files are only copied. <source-label> names what was synced,
# for example "v0.1.0 (3f2c1ab)". SOURCE_REPO names the source (default spdolan/project-standards).
#
# Portable to bash 3.2 (macOS) and needs only cp, find and mkdir. Exits non-zero if sync.txt
# names a path the source doesn't have, so a rename upstream is noticed rather than skipped.

set -euo pipefail

src="${1:?usage: sync.sh <source-dir> <source-label>}"
label="${2:?usage: sync.sh <source-dir> <source-label>}"
repo="${SOURCE_REPO:-spdolan/project-standards}"
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
manifest="$root/sync.txt"

[ -d "$src" ] || { echo "sync: not a directory: $src" >&2; exit 2; }
[ -f "$manifest" ] || { echo "sync: no sync.txt in $root" >&2; exit 2; }

# copy_file <relative path>: source file to the same path here, with a header the format allows.
copy_file() {
  local rel="$1" from="$src/$1" to="$root/$1"
  local note="Generated from $repo ($rel). Edit it there: the sync workflow overwrites changes made here."
  mkdir -p "$(dirname "$to")"
  case "$rel" in
    *.md) { printf '<!-- %s -->\n' "$note"; cat "$from"; } > "$to" ;;
    *.yml | *.yaml) { printf '# %s\n' "$note"; cat "$from"; } > "$to" ;;
    *) cp "$from" "$to" ;;
  esac
  echo "synced  $rel"
}

status=0
while IFS= read -r line || [ -n "$line" ]; do
  path="${line%%#*}"
  path="$(printf '%s' "$path" | tr -d '[:space:]')"
  [ -n "$path" ] || continue
  case "$path" in
    /* | *..*) echo "sync: refusing path outside the repository: $path" >&2; status=1; continue ;;
  esac
  case "$path" in
    */)
      dir="${path%/}"
      if [ ! -d "$src/$dir" ]; then echo "sync: source has no directory $dir/" >&2; status=1; continue; fi
      rm -rf "${root:?}/$dir"
      while IFS= read -r f; do
        copy_file "${f#"$src"/}"
      done < <(find "$src/$dir" -type f ! -name .DS_Store | LC_ALL=C sort)
      ;;
    *)
      if [ ! -f "$src/$path" ]; then echo "sync: source has no file $path" >&2; status=1; continue; fi
      copy_file "$path"
      ;;
  esac
done < "$manifest"

[ "$status" -eq 0 ] || exit "$status"
printf '%s %s\n' "$repo" "$label" > "$root/SYNCED_FROM"
echo "recorded SYNCED_FROM: $repo $label"
