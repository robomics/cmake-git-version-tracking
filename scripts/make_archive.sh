#!/usr/bin/env bash

# Copyright (C) 2022 Roberto Rossini <roberros@uio.no>
#
# SPDX-License-Identifier: MIT

set -e
set -o pipefail
set -u

scratch="$(mktemp -d)"
trap 'rm -rf "$scratch"' EXIT

current_date="$(date '+%s')"
printf -v current_date_short '%(%Y%m%d)T' "$current_date"
printf -v current_date_long '%(%Y-%m-%d %H:%M:%S)T' "$current_date"

git_root="$(git rev-parse --show-toplevel)"
wd="$scratch/$(basename "$git_root")-$current_date_short"

mkdir -p "$git_root/archives" "$wd"

rsync -a "$git_root/git_watcher.cmake" "$git_root/LICENSE" "$wd/"

printf 'Archive created on %s.\nCode hosted on "%s".\nNote: code forked from "%s".\n' \
  "$current_date_long" \
  'https://github.com/robomics/cmake-git-version-tracking' \
  'https://github.com/andrew-hardin/cmake-git-version-tracking' > "$wd/README.txt"

archive_dir="$git_root/archives/"
archive_name="$(basename "$git_root").$current_date_short.tar.xz"

tar -cf - -C "$(dirname "$wd")" "$(basename "$wd")" |
  xz -9 --extreme |
  tee "$archive_dir/$archive_name" > /dev/null

(cd "$archive_dir/" && shasum -a512 "$archive_name" | tee "$archive_name.sha512")
