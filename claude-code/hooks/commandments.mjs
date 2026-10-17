#!/usr/bin/env node
// UserPromptSubmit hook: every Nth user message in a session, print the commandments.
// For UserPromptSubmit, anything written to stdout (exit code 0) is added to Claude's context.
//
// Install to: ~/.claude/hooks/commandments.mjs
// Commandments file: ~/.claude/commandments.md
// Interval: env COMMANDMENTS_EVERY (default 10)

import { mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { homedir, tmpdir } from 'node:os';
import { join } from 'node:path';

const every = Number.parseInt(process.env.COMMANDMENTS_EVERY ?? '10', 10) || 10;
const commandmentsPath = join(homedir(), '.claude', 'commandments.md');

function readStdin() {
    try {
        return readFileSync(0, 'utf8');
    } catch {
        return '';
    }
}

try {
    const input = JSON.parse(readStdin() || '{}');
    const sessionId = String(input.session_id ?? 'unknown').replace(/[^a-zA-Z0-9_-]/g, '');

    // One tiny counter file per session, kept in the OS temp dir.
    const stateDir = join(tmpdir(), 'claude-commandments');
    mkdirSync(stateDir, { recursive: true });
    const counterFile = join(stateDir, `${sessionId}.count`);

    let count = 0;
    try {
        count = Number.parseInt(readFileSync(counterFile, 'utf8'), 10) || 0;
    } catch {
        // First message of this session.
    }
    count += 1;
    writeFileSync(counterFile, String(count));

    if (count % every === 0) {
        const text = readFileSync(commandmentsPath, 'utf8');
        process.stdout.write(JSON.stringify({
            systemMessage: `Commandments reminder injected (message ${count}).`,
            hookSpecificOutput: {
                hookEventName: 'UserPromptSubmit',
                additionalContext: `Periodic reminder (message ${count}):\n\n${text}`
            }
        }));
    }
} catch (error) {
    // A reminder hook must never break the session.
    process.stderr.write(`commandments hook error: ${error}\n`);
}

process.exit(0);
