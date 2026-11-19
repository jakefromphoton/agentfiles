# agentfiles

Personal Claude Code skills for drafting outbound writing and reviewing it line by line in
[Hunk](https://hunk.dev) inside [Herdr](https://herdr.dev) before anything is posted.

| Skill | Does |
| --- | --- |
| `draft-review` | Writes a draft to a file, opens it in a Hunk pane beside the chat, revises from line notes, and posts only on approval |
| `linear-ticket` | Drafts a Linear ticket as a Gherkin scenario plus Developer Context, reviews it with `draft-review`, then files it |
| `pr-description` | Drafts a PR body from the branch diff, reviews it above the diff in Hunk, then posts it with `gh` |

## Requirements

```sh
brew install hunk herdr gh jq
```

Run Claude Code inside `herdr` so review panes open beside the chat. Outside Herdr, the
skills print the `hunk patch` command to run in another terminal.

## Install

```sh
./install.sh --dry-run
./install.sh
```

Each `skills/<name>` is symlinked into `~/.claude/skills/<name>`. Existing files are never
replaced, reruns are no-ops, and links to deleted skills are pruned. `./install.sh
--uninstall` removes only this repo's links.

Drafts are written to the WebStorm scratches folder; temporary patches go under
`~/.local/state/agentfiles-jake/patches/`.
