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
  data to rba-joblist; `truck-report` reads arrivals from it; `packages`
  (`/api/packages?q=`) searches the installer / TechMapp packages the joblist
  has filed from email (its `package-search` function) so "Find Package" in
  the editor loads one without a manual upload. Upload File is the fallback
  (offline, or a package not filed yet). `?job=<joblist job id>` returns one
  job's package: the Truck Report's "Start from package" on a job with no
  list. Results flag jobs that already have a material list on file. Never
  delete a store or "reset" the site — there is no other copy. To inspect:
  `NETLIFY_SITE_ID=f979f1d5-307f-412d-a7ca-fd97486444dc netlify blobs:list jobs --json`.
- Combination units ("101A" + "101B") import as one opening when the layout
  is unambiguous: equal heights add widths, equal widths add heights, plus a
  mull allowance per joint: 1/2" between windows, 3/4" when any part is a door
  (doors vary up to 3/4"; Matt 2026-11-19). Custom shop-built mulls are rare
  and corrected by hand. The review screen has a checkbox to keep them
  separate. Anything else stays as separate units.
- Netlify site `rba-material-list` → https://rbamateriallist.com, deploys every
  push to `main`. The root `netlify.toml` sets `base = "pwa-app"` so Netlify
  reads `pwa-app/netlify.toml` (publish `.`, functions). **Keep it.** On
  2026-10-28 a site reconnect dropped the base dir, the build shipped zero
  functions, `/api/jobs` 404'd, and every iPad showed only its cached jobs. The
  app now shows an orange "Server unreachable" status in that case instead of
  "Connected"; check the deploy summary for "No functions deployed" if it
  ever shows up again.
- Repo: github.com/rba-lsr/material-list.

## Open reminders
- **Move package filing off Matt's Mac (asked 2026-11-19).** Packages reach
  the joblist through an Apple Mail rule on Matt's Mac, so nothing is filed
  while that Mac is asleep or Mail is closed, and Find Package can't see it.
  Goal: a server that receives anything sent from tech@northlandrba.com and
  files it instantly through the joblist's existing intake. The work is in
  rba-joblist; there is a matching idea card on the joblist in the Command
  Center. Raise this with Matt when working on imports or Find Package.
- **`/api/packages` has no login (2026-11-19).** Like the app's other
  endpoints, anyone with the address can search packages and get short-lived
  links to PDFs that hold customer addresses and phone numbers. Matt wants to
  build the lock-down on Monday 2026-11-23, when everyone is in, so he can
  tell the team the same day. Still to decide: team code or Microsoft sign-in.

## Run locally
`cd pwa-app && netlify dev` serves the page AND the functions (local blob
sandbox, starts empty). The static server in `.claude/launch.json` (port 3333)
serves the page only — expect the server-unreachable banner there.

## Team sync rules (Matt + Pete)

Automatic at session start: `.claude/hooks/session-sync.sh` checks GitHub when
a session opens here and pulls the other person's finished work when that is
safe. Its report is the first thing in the session. Tell me what it pulled
before doing anything else, and if it says STOP, stop and ask me. This replaces
step 1 and 2 of "Before making any changes" below; the rest still applies.

Where knowledge goes: facts about this app go in this file (or the notes it
points to), in the same commit as the change. Facts that apply to every app go
in `docs/canon/` or `docs/WORKING-TOGETHER.md` in rba-command-center. Nothing
that both Claudes need stays in one person's Claude memory.

We both push directly to main. Every push to main deploys live on
Netlify, and each deploy costs credits, so push when a change is
finished and tested, not after every small edit. Commit locally as
often as you like; commits are free.

Before making any changes:
1. Run `git fetch` and `git status`.
2. If behind origin, show me what changed (`git log HEAD..@{u} --oneline`)
   and who pushed it, then `git pull` before doing anything else.
3. If there are uncommitted local changes AND new commits on GitHub,
   stop and ask me.

Before pushing:
1. Run `git fetch` again. If someone pushed while I was working, pull
   first and check the app still runs.
2. If the pull causes a merge conflict, stop and explain it in plain
   English before resolving anything.
3. Run the app locally and confirm it works.
4. If the change is docs-only (README, CLAUDE.md, comments), add
   [skip netlify] to the commit message so it doesn't trigger a deploy.

After pushing:
- Confirm the push succeeded. No summary needed unless I ask.
