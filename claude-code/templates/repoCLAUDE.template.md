# <Project name>

<One or two sentences: what this project is and who it is for.>

Global defaults from `~/.claude/CLAUDE.md` and `~/.claude/rules/` apply. Only list what differs
or is specific to this repo below. Delete sections you do not need.

## Stack
- Type: <tiny app | larger app>
- Framework/runtime: <React + TS + Vite | Node + Express | ...>
- Package manager: npm
- E2E: <none | Playwright | Cypress>

## Commands
- Dev: `npm run dev`
- Typecheck / lint / tests: `npm run typecheck`, `npm run lint`, `npm run test:run`
- Build: `npm run build`

## Overrides of global defaults
- TDD (red/green/refactor): <on (default) | `TDD: off` for very small apps>
- Barrel exports (`index.ts`): <off | on>
- Folder structure: <layers | features/ + shared layers>
- Styling / state / routing / data: <defaults | e.g. CSS Modules only, no Zustand>
- Other: <anything that deviates from the global rules>

## Architecture notes
- <Key modules and how they relate, in a few bullets>
- <Backend/API location and contract, if any>

## Gotchas
- <Things that are easy to get wrong in this repo>
