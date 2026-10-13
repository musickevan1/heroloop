# Dev loop glossary

How a code change goes from an idea to merged pull requests, with the agent doing the implementation between two human decisions.

**Dev loop**: the process from grilling an idea to merging its pull requests: `/dev-loop`, then `/land-prs`.

**Spec**: the accepted description of what to build, published by `/to-spec` to the repo's tracker.

**Ticket**: one independently implementable slice of a spec, with the tickets that block it. One ticket, one branch, one pull request.

**Pass**: one run of the ticket loop over a spec's ready tickets.

**Ticket brief**: the table of a spec's tickets, their blockers, base branches and status, plus the gate command, shown for sign-off before any implementation.

**Sign-off**: the user's decision at a checkpoint: on a ticket brief, or on a merge plan. Each sign-off allows exactly what its checkpoint lists.

**Gate**: what a change must pass: the repo's test command locally, CI on the pull request.

**Stack**: a chain of pull requests, each based on the branch of the one below it, so a ticket can start before its blocker merges.

**Parked ticket**: a ticket whose gate stayed red after one fix attempt. Its work is pushed as a draft PR and the ticket is labelled for a human.

**Merge plan**: one repo's ordered list of pull requests proposed for merging together.
