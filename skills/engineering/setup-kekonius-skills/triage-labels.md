# Triage labels

The skills speak in terms of five canonical triage roles. This file maps those roles to the label strings used in this repo.

| Role              | Label in this repo | Meaning                                  |
| ----------------- | ------------------ | ---------------------------------------- |
| `needs-triage`    | `needs-triage`     | Maintainer needs to evaluate this issue  |
| `needs-info`      | `needs-info`       | Waiting on reporter for more information |
| `ready-for-agent` | `ready-for-agent`  | Fully specified, ready for an AFK agent  |
| `ready-for-human` | `ready-for-human`  | Requires human implementation            |
| `wontfix`         | `wontfix`          | Will not be actioned                     |

When a skill mentions a role (e.g. "apply the ready-for-agent label"), use the corresponding string from the middle column.

Two category labels sit beside the roles: `bug` and `enhancement`. Every triaged issue carries exactly one category and one role.
