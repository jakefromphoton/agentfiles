---
name: linear-ticket
description: >
  Drafting and filing a Linear ticket in Jake's Gherkin + Developer Context layout. Use
  whenever a ticket, issue, or spec is about to be written or filed, however phrased
  ("write a ticket", "log this", "track this in Linear"), including when the filing is
  delegated to a subagent. Covers the layout, scoping, Hunk review, and filing.
  Invoked with /linear-ticket.
user-invocable: true
---

# Linear tickets

## Layout

Every description has exactly two H1 sections, in this order:

````markdown
# Gherkin

```gherkin
Feature: <user-facing capability>
  Scenario: <the behaviour that delivers value>
    Given <starting context>
    When <user action or event>
    Then <observable outcome the user cares about>
```

# Developer Context

<implementation details, affected services and files, links, constraints, open questions>
````

- **Gherkin is user value only.** One Feature, one to three Scenarios, each written in
  the words of the person who benefits: a prescriber, a patient, an ops teammate, a
  calling service. Every `Then` is something that person can observe.
- **Developer Context holds everything else**: services and files, prior art, flags,
  rollout, dependencies, open questions, and any agent-oriented detail. It is the only
  home for implementation.
- **Title** is a short plain-English headline of the outcome. It goes in chat, not the
  draft file.

## Scoping

Before drafting, write the scenario in your head. If no small, honest scenario exists
(pure tech debt, too vague to name an outcome, or so big it needs four or more
scenarios), stop and ask Jake how to proceed. The answer might be a split, a sharper
goal, or skipping the ticket.

- **Outcomes, not building blocks.** Scope around something observable end to end. If
  an engineer couldn't describe how to test the scenario, the ticket is at the wrong
  level.
- **Right granularity.** Small enough to hold in your head, large enough to deliver
  something testable. Check: could someone build the wrong thing by picking this ticket
  up before a sibling?
- **Point to prior art** in Developer Context: existing code, scripts, or tickets that
  define the expected behaviour.
- **Uncertainty becomes a timeboxed investigation** listed in Developer Context.

## Review

Draft the description into a file and review it per the `draft-review` skill, slug
`linear-<kebab-title>`. Show the proposed title, team, and any labels in chat alongside
the pane.

## Filing

Only after Jake approves the draft. With the Linear MCP:

1. **Search for duplicates** with `list_issues`, completed and archived included. Report
   a likely match to Jake instead of filing.
2. **Team** is the one Jake named. If he named none, ask.
3. **Create** with `save_issue`: the approved title, and the draft file's contents
   verbatim as the description. Status and priority stay at the team's defaults unless
   Jake set them.
4. Reply with the new identifier and link, then finish the `draft-review` posting step.

A subagent asked to file gets the finished title and description, and does only the
search and create.
