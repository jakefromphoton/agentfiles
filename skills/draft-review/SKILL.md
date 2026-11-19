---
name: draft-review
description: >
  Review an outbound draft line by line in a Hunk pane instead of in chat. Use whenever
  written comms are drafted for Jake's approval before posting: PR descriptions, Linear
  tickets, GitHub issues and comments, Slack posts, reply drafts. Covers the draft file,
  opening and refreshing the Hunk pane in Herdr, carrying Jake's notes across revisions,
  and posting. Invoked with /draft-review.
user-invocable: true
---

# Draft review

Jake reviews outbound drafts in Hunk, leaving notes on the lines he wants changed. The
draft file is the single source of truth: its contents are exactly what gets posted.

The installed tools carry their own agent skills. Load them for CLI detail beyond what
this skill shows: `herdr --skill` and `hunk skill show hunk-review` print them.

## The draft

One Markdown file per draft, in Jake's WebStorm scratches so it stays readable later:

```sh
scratches="$HOME/Library/Application Support/JetBrains/WebStorm2026.1/scratches"
patches="$HOME/.local/state/agentfiles-jake/patches"
```

The draft is `"$scratches/<slug>.md"`, where `<slug>` is kebab-case and names the thing:
`linear-pharmacy-hours-banner`, `pr-services-1234`, `slack-deploy-freeze`. The file holds
the post body and nothing else, footer included. A title or other field the destination
stores separately goes in chat.

## Review pane

Build the patch so the whole draft shows as added lines:

```sh
mkdir -p "$patches"
(cd "$scratches" && git diff --no-index /dev/null "<slug>.md") > "$patches/<slug>.patch"
```

`git diff --no-index` exits 1 when the files differ. That is the expected result.

Inside Herdr (`HERDR_ENV=1`), open the review in a pane to the right of the chat:

```sh
herdr pane split --current --direction right --cwd "$scratches" --no-focus
herdr pane run <new-pane-id> "hunk patch '$patches/<slug>.patch'"
```

Read `<new-pane-id>` from `.result.pane.pane_id` and keep it for closing. Tell Jake the
pane is open in one line, then wait for his notes.

Outside Herdr, give Jake the `hunk patch '<patch path>'` command to run in another
terminal, and wait for him to say it's open. The rest of this skill works the same.

## Revising

Jake's notes live in the Hunk session, not chat. Find the session by its patch path and
read every note:

```sh
id=$(hunk session list --json | jq -r --arg p "$patches/<slug>.patch" '.sessions[] | select(.sourceLabel == $p) | .sessionId')
hunk session comment list "$id" --type all --json
```

Each note carries `noteId`, `newRange`, `body`, and `author`. A question in a note gets
an answer, in chat or as a reply note (`--reply-to <noteId>`), before any edit it might
imply.

After editing the draft, reload the live session in place so the notes survive. A note
keeps its old line number through a reload, even when the text it pointed at moved, so
re-anchor every note:

1. **Snapshot first.** Before rebuilding the patch, save the note list and the text of
   each note's anchored line from the old draft.
2. **Drop addressed notes.** A note is addressed when this revision acted on it. Remove
   it with `hunk session comment rm "$id" <noteId>`. If Hunk refuses to remove a note
   Jake wrote, reply to it with `Addressed: <what changed>` instead.
3. **Rebuild and reload:** rebuild the patch as above, then
   `hunk session reload "$id" -- patch "$patches/<slug>.patch"`.
4. **Re-anchor the rest.** Find each recorded line in the new draft. If its line number
   changed, `rm` the note and re-add it at the new line with its original `--author` and
   `--summary`, then its replies with `--reply-to`. If the line is gone, re-add it on the
   nearest surviving line with the old line quoted in the summary.

Re-added notes become agent notes, which start hidden, so pass `--focus` on the first
one. When the session was closed, open a fresh pane; there are no notes to carry.

Tell Jake in one line what changed, then wait again.

## Posting

Post only when Jake says to. Post the file's contents verbatim, with no edits after his
last look; if the draft changed since then, reload the pane and wait again.

After posting, close the pane you opened with `herdr pane close <new-pane-id>` and delete
the patch. Keep the draft in scratches.
