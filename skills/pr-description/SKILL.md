---
name: pr-description
description: >
  Drafting, posting, or updating a pull request description. Use whenever a PR body is
  about to be written, however phrased ("open a PR", "write the PR description", "update
  the description", "fill in the template"), including drafts requested in chat and when
  the posting is delegated to a subagent. Covers the template, medium selection, the
  delete pass, Hunk review alongside the diff, and posting with gh.
  Invoked with /pr-description.
user-invocable: true
---

# PR descriptions

A reviewer opens a PR knowing nothing and reads the description to decide where to look.
Its job is what the diff can't tell them: why, what shape the change has, and what to
distrust. Anything they get from Files Changed is wasted words.

## Before writing

1. **Find the base**: `gh pr view --json baseRefName -q .baseRefName` for an existing PR,
   otherwise the repo's default branch.
2. **Read the template**: `.github/pull_request_template.md` (either case) or the files
   under `.github/PULL_REQUEST_TEMPLATE/`. Keep every section it defines, in order, and
   add no top-level heading of your own; a fact that needs a heading gets an `###` inside
   the section it belongs to. A section that doesn't apply gets one line saying so. No
   template means the default below.
3. **Read the diff**: `git diff <base>...HEAD --stat`, then the substantive files.
4. **List the facts** a reviewer needs and give each one a medium from the table before
   drafting. Each fact lands in one section only.

## Default template

```markdown
## Overview

<One "This PR <does what> <rather than / because …>." sentence, then any detail and the ticket ID.>

## Change log

<Past-tense bullets grouped by what a reviewer would go check. Blocks and diagrams live here.>

## Notes

<Only for something to distrust, a scope boundary, a repro to run, or a follow-up someone must act on. Cut the heading otherwise.>
```

Overview names the change the way a reviewer would say it out loud, not by its mechanism.
The why is often the old behaviour: "rather than posting a new comment on every push".
Reference tickets by bare identifier (`ABC-123`); the repos autolink them.

Change log bullets lead with a past-tense verb and the thing changed, then the one
property a reviewer should check. Mechanics stay in the diff.

## Pick the medium

| The fact is…                                           | Medium                                       |
| ------------------------------------------------------ | -------------------------------------------- |
| a payload, response, or config shape                   | fenced `json`/`yaml`, a minimal constructed example |
| a type or class relationship                           | mermaid `classDiagram`, or three ASCII lines |
| a request across 2+ services, or ordered async steps   | mermaid `sequenceDiagram`                    |
| branching logic, a forked pipeline, a retry path       | mermaid `flowchart`                          |
| a status field and its transitions                     | mermaid `stateDiagram-v2`                    |
| table or entity relationships                          | mermaid `erDiagram`                          |
| a changed call site                                    | before/after, two short blocks               |
| verification                                           | the command and its real output              |
| a fixed value set, or behaviour per case               | markdown table                               |
| the why, a tradeoff, a scope boundary, what to distrust | prose                                       |

Only the last row is prose.

**Code blocks are constructed, not copied.** A block shows the change from outside: the
payload a client now receives, the call a caller now writes, the command and what it
printed. Ten lines at most, elided with `…`. No imports, function bodies, or test bodies;
name the test file and say what it pins.

**Mermaid stays boring**, since a syntax error renders as an error box: no styling or
`classDef`, no nested subgraphs, alphanumeric node ids with punctuation inside quoted
labels, eight nodes at most, edges labelled with the verb. Two nodes and one arrow is a
sentence instead.

## Delete pass

One pass before review, each item a cut:

- A fact in two sections: keep the better home.
- A sentence defending a decision nobody challenged. Search for *deliberately*, *worth
  noting*, *to be clear*, *it's important to*.
- Process narrative: earlier drafts, review rounds, what couldn't run locally.
- A block copied from the diff.
- Prose describing a shape: convert it to its medium.
- Any sentence that doesn't change what the reviewer does or decides.

Checkboxes stay unchecked unless Jake verified that item this session.

Budget: about 80 words of prose per section; blocks and diagrams are free. Exceed it only
for ordered migration steps, an exact repro, or a decision with real alternatives.

## Footer

The description's last line is exactly:

```markdown
🤖 LLM Generated
```

The description names no AI tool or model anywhere. The footer is in the draft Jake
reviews, so what he approves is what gets posted.

## Review

Write the body to a draft per the `draft-review` skill, slug `pr-<repo>-<branch>`, then
build a patch that puts the description above the code so Jake reviews both together:

```sh
{ (cd "$scratches" && git diff --no-index /dev/null "<slug>.md")
  git -C <repo> diff <base>...HEAD
} > "$patches/<slug>.patch"
```

Open, revise, and reload exactly as `draft-review` says, rebuilding this combined patch
each time. A note on code is addressed once the code change lands.

## Posting

Only when Jake says to post, from the repo:

- New PR: `gh pr create --base <base> --title "<title>" --body-file "$scratches/<slug>.md"`
- Existing PR: `gh pr edit --body-file "$scratches/<slug>.md"`

Then finish the `draft-review` posting step. A subagent asked to post gets the finished
file path and runs only the `gh` command.
