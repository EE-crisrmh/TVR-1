# contributing to tvr-1

## workflow

1. Get the latest code: `git checkout main && git pull`.
2. Make a branch named for your area and the task, for example `software/state-machine` or `hardware/power-schematic`.
3. Commit small, clear changes. Say what changed and why.
4. Push your branch and open a pull request into `main`.
5. A lead for your area reviews it. Checks must pass before merging.

If you do not have write access, fork the repo, work on a branch in your fork, and open a pull request from there. Keep your fork current with the main repo (github's "sync fork" button, or `git fetch upstream`).

## rules of thumb

- Keep each folder's files to its own area (hardware, mechanical, simulation, software, docs).
- Use lowercase file names with underscores or dashes.
- Do not commit editor autosaves or build output (see `.gitignore`).
- Give files real names. Avoid names like `final2` or `new`.
- Put a short note in the folder's readme when you add something others need to know how to use.
- Do not commit passwords, tokens or personal data.

Not sure who owns something? See [ownership.md](ownership.md).
