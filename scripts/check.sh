#!/usr/bin/env bash

set -euo pipefail

script_dir=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
repo_root=$(CDPATH= cd -- "$script_dir/.." && pwd -P)
cd "$repo_root"

printf '%s\n' 'Checking patch whitespace...'
git diff --check

if ! command -v qsb >/dev/null 2>&1; then
    printf '%s\n' 'ERROR: qsb is required to validate committed shader packs.' >&2
    exit 1
fi

shader_sources=(
    "shaders/sdf-liquid.frag"
    "shaders/wallpaper-reveal.frag"
)

printf '%s\n' 'Inspecting committed shader packs...'
for source in "${shader_sources[@]}"; do
    pack="$source.qsb"
    git ls-files --error-unmatch -- "$pack" >/dev/null
    qsb -d "$pack" >/dev/null
done

tmp_dir=$(mktemp -d "${TMPDIR:-/tmp}/quickshell-check.XXXXXX")
trap 'rm -rf -- "$tmp_dir"' EXIT

printf '%s\n' 'Checking reproducible shader packs...'
for source in "${shader_sources[@]}"; do
    generated="$tmp_dir/${source##*/}.qsb"
    qsb --qt6 -o "$generated" "$source"
    cmp "$source.qsb" "$generated"
done

qml_files=()
while IFS= read -r -d '' file; do
    if [[ -f "$file" ]]; then
        qml_files+=("$file")
    fi
done < <(git ls-files --cached --others --exclude-standard -z -- '*.qml')

if command -v qmlformat >/dev/null 2>&1; then
    printf '%s\n' 'Checking QML formatting...'
    if ((${#qml_files[@]} > 0)); then
        qmlformat --check "${qml_files[@]}"
    fi
else
    printf '%s\n' 'SKIP: qmlformat not found; QML formatting was not checked.'
fi

if command -v qmllint >/dev/null 2>&1; then
    printf '%s\n' 'Linting QML files...'
    if ((${#qml_files[@]} > 0)); then
        qmllint "${qml_files[@]}"
    fi
else
    printf '%s\n' 'SKIP: qmllint not found; QML files were not linted.'
fi

printf '%s\n' 'Validation completed successfully.'
