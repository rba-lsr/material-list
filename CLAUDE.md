# CLAUDE.md — RBA Material List (Cut List Pro)

iPad PWA for tech measurers: window/door material cut lists, board optimizer,
PDFs, and the Truck Report. Used daily by the field and the warehouse.

## Where things live
- The whole app is `pwa-app/index.html` (React via Babel-in-browser, one file)
  plus `pwa-app/sw.js`. The repo root holds notes only. The drag-and-drop deploy
  steps in the READMEs are historical — deploys come from GitHub now.
- **Data lives ONLY in Netlify Blobs on the `rba-material-list` site**: stores
  `jobs` (every saved and submitted job), `catalog` (Available Material),
  `offsets`. Served by `pwa-app/netlify/functions/*.mts` as `/api/jobs`,
  `/api/catalog`, `/api/offsets`; `push-to-joblist` sends the PDF + linear-feet
  data to rba-joblist; `truck-report` reads arrivals from it. Never delete a
  store or "reset" the site — there is no other copy. To inspect:
  `NETLIFY_SITE_ID=f979f1d5-307f-412d-a7ca-fd97486444dc netlify blobs:list jobs --json`.
- Netlify site `rba-material-list` → https://rbamateriallist.com, deploys every
  push to `main`. The root `netlify.toml` sets `base = "pwa-app"` so Netlify
  reads `pwa-app/netlify.toml` (publish `.`, functions). **Keep it.** On
  2026-10-28 a site reconnect dropped the base dir, the build shipped zero
  functions, `/api/jobs` 404'd, and every iPad showed only its cached jobs. The
  app now shows an orange "Server unreachable" status in that case instead of
  "Connected"; check the deploy summary for "No functions deployed" if it
  ever shows up again.
- Repo: github.com/rba-lsr/material-list.

## Run locally
`cd pwa-app && netlify dev` serves the page AND the functions (local blob
sandbox, starts empty). The static server in `.claude/launch.json` (port 3333)
serves the page only — expect the server-unreachable banner there.

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
