## Team sync rules (Matt + Pete)

We both push directly to main. Every push to main deploys live on Netlify.

Before making any changes:
1. Run `git fetch` and `git status`.
2. If the branch is behind origin, show me what changed
   (`git log HEAD..@{u} --oneline`) and who pushed it, then `git pull`
   before doing anything else.
3. If there are uncommitted local changes AND new commits on GitHub,
   stop and ask me.

Before pushing:
1. Run `git fetch` again.
2. If someone pushed while I was working, pull first, check that the
   app still runs, then push.
3. If the pull causes a merge conflict, stop and explain it in plain
   English before resolving anything.
4. Run the app locally and confirm it works before pushing to main.

After pushing:
- Confirm the push succeeded. No summary needed unless I ask.
