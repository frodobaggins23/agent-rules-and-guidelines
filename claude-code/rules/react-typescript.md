---
paths:
  - "**/*.{ts,tsx,js,jsx}"
  - "**/package.json"
---

# React + TypeScript rules

Defaults for every React/TypeScript repo of mine. A repo-level `CLAUDE.md` may override any of it.

## Stack
- React + TypeScript, built with Vite, tested with Vitest (+ React Testing Library, jsdom).
- Package manager: **npm**. Runtime: current Node LTS, pinned in `.nvmrc` and
  `engines` in `package.json`.
- Lint/format: ESLint (flat config) + Prettier. Git hooks: Husky + lint-staged + commitlint.
- E2E (larger projects only): Playwright or Cypress. Ask me which one when E2E is first added.
- Libraries (defaults, override per repo): Tailwind CSS for styling (CSS Modules when a
  component needs bespoke CSS that utilities handle poorly), React Router for routing, Zustand
  for client state, TanStack Query for server state. Start minimal: plain React state/context
  is enough in tiny apps, so introduce a library only when the need appears (ask first).

## TypeScript
- `strict: true` and `noUncheckedIndexedAccess: true`. Also `noImplicitOverride`,
  `forceConsistentCasingInFileNames`, `isolatedModules`.
- No `any`. Use `unknown` and narrow, or write a proper type. A justified, commented
  `@ts-expect-error` is the only escape hatch (never `@ts-ignore`).
- Prefer `type` for unions and aliases, `interface` for object shapes meant to be extended.
- Explicit return types on exported functions; infer for local ones.
- Function components and hooks only. No class components.

## Naming
- Files and folders: **camelCase** (`userProfile/`, `formatDate.ts`, `useAuth.ts`).
- Exception: React component files are **PascalCase** and match the component name
  (`UserCard.tsx`, `UserCard.module.css`).
- Tests: `<fileName>.test.ts(x)`. Types/interfaces and components: PascalCase.
  Variables and functions: camelCase. Constants: camelCase, or UPPER_SNAKE_CASE for true
  module-level constants. Hooks start with `use`.
- No abbreviations that are not universal. Booleans read as questions (`isOpen`, `hasError`).

## Exports and imports
- **Named exports only.** No default exports. Exceptions only where a tool requires it
  (config files such as `vite.config.ts`, lazy-loaded routes).
- **Barrel files (`index.ts`) are off by default.** Use them only if the repo's `CLAUDE.md`
  opts in. Without barrels, import from the concrete file.
- Imports sorted alphabetically (enforced by ESLint). Use `import type` for type-only imports.
- Use a `@/` alias for `src/` if the repo defines one; otherwise relative paths.
  No deep relative chains like `../../../`.

## Folder structure (by functionality)
Small and medium repos, layers at the top of `src/`. Create folders only when needed:

```
src/
  components/    reusable UI components (shared across pages)
  pages/         route-level components, one per route
  hooks/         custom hooks
  services/      business logic and orchestration (no UI)
  apis/          HTTP clients and endpoint wrappers
  stores/        Zustand stores
  utils/         pure helper functions
  types/         shared types
  assets/        images, fonts
  styles/        global styles
```

- A component with several files gets its own folder:
  `components/userCard/UserCard.tsx`, `UserCard.module.css`, `__tests__/UserCard.test.tsx`.
- Tests live in a `__tests__/` folder inside the folder of the code they test.
- **Larger repos** switch to feature folders, keeping shared cross-feature code in the
  top-level layers:
  ```
  src/features/auth/{components,hooks,services,apis,stores,__tests__}
  src/components/   (truly shared UI)
  ```
- `services/` = logic, `apis/` = network calls. Components never call `fetch` directly.
- Only barrel (`index.ts`) a folder if the repo opted in. Keep barrels export-only.

## React guidelines
- Keep components small and focused. Extract logic into hooks, not into JSX.
- Follow the rules of hooks (enforced by ESLint). Fix `exhaustive-deps` warnings properly,
  do not silence them.
- Derive state instead of duplicating it. Do not store what can be computed.
- Use stable `key`s (never array index for dynamic lists).
- Prefer composition over prop drilling; lift state only as far as needed.
- Accessibility basics: semantic elements, labels for inputs, keyboard operable controls.
- No inline business logic in event handlers beyond trivial calls.

## Testing (Vitest)
- Config in `vite.config.ts` (or `vitest.config.ts`), environment `jsdom` for UI tests.
- Unit-test logic (utils, hooks, services, stores). Presentational components only if
  they contain real behavior. Use React Testing Library queries by role/label, not
  implementation details.
- Scripts: `test` (watch) and `test:run` (single run, used by the pre-push hook).

## package.json scripts
```
"dev": "vite",
"build": "tsc -b && vite build",
"preview": "vite preview",
"typecheck": "tsc --noEmit",
"lint": "eslint .",
"format": "prettier --write .",
"format:check": "prettier --check .",
"test": "vitest",
"test:run": "vitest run",
"prepare": "husky"
```
Adapt `typecheck` to the repo's tsconfig layout (e.g. project references).

## Prettier (`.prettierrc`)
```json
{
    "semi": true,
    "tabWidth": 4,
    "useTabs": false,
    "singleQuote": true,
    "printWidth": 100,
    "trailingComma": "all",
    "bracketSpacing": true,
    "arrowParens": "always",
    "endOfLine": "lf"
}
```
Also add a `.prettierignore` (dist, coverage, node_modules, lockfile).

## ESLint (`eslint.config.js`, flat config)
Dev deps: `eslint @eslint/js typescript-eslint eslint-plugin-react-hooks
eslint-plugin-simple-import-sort eslint-config-prettier`.

```js
import js from '@eslint/js';
import prettier from 'eslint-config-prettier';
import reactHooks from 'eslint-plugin-react-hooks';
import simpleImportSort from 'eslint-plugin-simple-import-sort';
import tseslint from 'typescript-eslint';

export default tseslint.config(
    { ignores: ['dist', 'coverage'] },
    js.configs.recommended,
    ...tseslint.configs.recommended,
    {
        plugins: {
            'react-hooks': reactHooks,
            'simple-import-sort': simpleImportSort,
        },
        rules: {
            'react-hooks/rules-of-hooks': 'error',
            'react-hooks/exhaustive-deps': 'warn',
            'simple-import-sort/imports': 'error',
            'simple-import-sort/exports': 'error',
            '@typescript-eslint/no-unused-vars': [
                'error',
                { argsIgnorePattern: '^_', varsIgnorePattern: '^_', caughtErrorsIgnorePattern: '^_' },
            ],
            '@typescript-eslint/no-explicit-any': 'error',
            '@typescript-eslint/consistent-type-imports': 'error',
            'no-restricted-exports': ['error', { restrictDefaultExports: { direct: true } }],
            'no-console': ['warn', { allow: ['warn', 'error'] }],
        },
    },
    {
        files: ['**/*.config.{js,ts}'],
        rules: { 'no-restricted-exports': 'off' },
    },
    prettier, // must be last: turns off rules that conflict with Prettier
);
```
Notes: `simple-import-sort` orders alphabetically within groups (side-effect, packages,
absolute/alias, relative). Add `eslint-plugin-react-refresh` only if the repo uses Vite
fast refresh checks. Adjust `files`/globals as the repo needs, but keep the rules above.

## Git hooks (Husky v9 + lint-staged + commitlint)
Dev deps: `husky lint-staged @commitlint/cli @commitlint/config-conventional`.
Setup: `npx husky init`, then replace the generated hook contents.

- `.husky/pre-commit`:
  ```sh
  npx lint-staged
  npm run typecheck
  ```
- `.husky/commit-msg`:
  ```sh
  npx --no -- commitlint --edit "$1"
  ```
- `.husky/pre-push`:
  ```sh
  npm run test:run
  ```
- `commitlint.config.js`:
  ```js
  export default { extends: ['@commitlint/config-conventional'] };
  ```
- lint-staged (in `package.json` or `.lintstagedrc.json`):
  ```json
  {
      "*.{ts,tsx,js,jsx}": ["eslint --fix", "prettier --write"],
      "*.{json,md,css,yml,yaml}": ["prettier --write"]
  }
  ```
Hooks must pass. Never bypass them with `--no-verify`. If a hook fails, fix the cause.

## New repo checklist
1. Scaffold with Vite (React + TS template), set `.nvmrc` and `engines`.
2. Add the tooling above (Prettier, ESLint, Vitest, Husky, lint-staged, commitlint).
3. Enable strict TS options, create the folder structure only as needed.
4. Add README, `.gitignore`, `.env.example`.
5. Verify: `npm run typecheck && npm run lint && npm run test:run && npm run build`.
