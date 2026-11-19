#!/usr/bin/env bash
set -euo pipefail

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
skills_source="$repo_root/skills"
skills_destination="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
mode=install
dry_run=false

usage() {
  printf 'Usage: %s [--dry-run] [--uninstall]\n' "$(basename "$0")"
}

main() {
  parse_arguments "$@"
  case "$mode" in
    install)
      link_every_skill
      prune_dangling_links
      ;;
    uninstall)
      remove_every_link
      ;;
  esac
}

parse_arguments() {
  while (($#)); do
    case "$1" in
      --dry-run) dry_run=true ;;
      --uninstall) mode=uninstall ;;
      -h | --help) usage; exit 0 ;;
      *) usage >&2; exit 2 ;;
    esac
    shift
  done
}

link_every_skill() {
  run mkdir -p "$skills_destination"
  local skill_dir link_path
  for skill_dir in "$skills_source"/*/; do
    skill_dir=${skill_dir%/}
    link_path="$skills_destination/$(basename "$skill_dir")"
    if [[ -L "$link_path" && "$(readlink "$link_path")" == "$skill_dir" ]]; then
      report OK "$link_path"
    elif [[ -e "$link_path" || -L "$link_path" ]]; then
      report SKIP "$link_path exists and is not this repo's link"
    else
      run ln -s "$skill_dir" "$link_path"
      report LINK "$link_path -> $skill_dir"
    fi
  done
}

prune_dangling_links() {
  local link_path
  for link_path in $(links_into_this_repo); do
    if [[ ! -e "$link_path" ]]; then
      run rm "$link_path"
      report PRUNE "$link_path"
    fi
  done
}

remove_every_link() {
  local link_path
  for link_path in $(links_into_this_repo); do
    run rm "$link_path"
    report REMOVE "$link_path"
  done
}

links_into_this_repo() {
  [[ -d "$skills_destination" ]] || return 0
  local link_path
  for link_path in "$skills_destination"/*; do
    if [[ -L "$link_path" && "$(readlink "$link_path")" == "$skills_source/"* ]]; then
      printf '%s\n' "$link_path"
    fi
  done
}

run() {
  if "$dry_run"; then
    return 0
  fi
  "$@"
}

report() {
  local prefix=""
  "$dry_run" && prefix="[dry-run] "
  printf '%s%-7s %s\n' "$prefix" "$1" "$2"
}

main "$@"
