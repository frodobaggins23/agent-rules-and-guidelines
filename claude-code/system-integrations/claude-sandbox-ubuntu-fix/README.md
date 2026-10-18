# claude-sandbox-ubuntu-fix

Makes Claude Code's Bash sandbox work on Ubuntu, where the default AppArmor policy for `bwrap`
breaks it. Without this fix every sandboxed Bash command fails, so the sandbox either blocks all
work or gets bypassed.

**Intended for and tested on Ubuntu 26.04 LTS** (26.04.1, kernel 7.0.0, `apparmor`
5.0.2-0ubuntu1~26.04.1, `bubblewrap` 0.11.1, Claude Code 2.1.302). Other releases ship different
AppArmor profiles; do not apply it there without comparing the files first (see
[Maintenance](#maintenance)).

## Symptom

Every Bash command in Claude Code (CLI and VS Code extension) fails with:

```
apply-seccomp: write /proc/self/setgroups (nested userns is capability-restricted; caller must provide CAP_SYS_ADMIN): Permission denied
```

The kernel log shows:

```
apparmor="DENIED" operation="capable" class="cap" profile="unpriv_bwrap" comm="bwrap" capability=21 capname="sys_admin"
```

Upstream report: [anthropics/claude-code#87680](https://github.com/anthropics/claude-code/issues/87680)
(closed by the stale bot, no official fix).

## Cause

- Ubuntu restricts unprivileged user namespaces (`kernel.apparmor_restrict_unprivileged_userns = 1`).
- The shipped profile `/etc/apparmor.d/bwrap-userns-restrict` lets `bwrap` create namespaces,
  but runs everything `bwrap` starts under the `unpriv_bwrap` profile with
  `audit deny capability,`, i.e. no capabilities at all.
- Claude Code's sandbox runs `bwrap` and then, inside it, a helper that creates a nested user
  namespace to install a seccomp filter (it blocks Unix sockets). That step needs `CAP_SYS_ADMIN`
  and is denied.

## The fix

[`profile-files/bwrap-sandbox`](profile-files/bwrap-sandbox) replaces Ubuntu's profile. It is
identical to the original ([`profile-files/bwrap-userns-restrict`](profile-files/bwrap-userns-restrict),
a reference copy) except:

- `unpriv_bwrap` explicitly allows `capability sys_admin,` and denies every other capability by
  name instead of `audit deny capability,`.
- The `include if exists <local/...>` lines point to new names, so stale local overrides of the
  original are not picked up.

The profile names `bwrap` and `unpriv_bwrap` are kept on purpose: the `papers` and `glycin`
profiles reference them.

Review the difference before installing:

```sh
diff profile-files/bwrap-userns-restrict profile-files/bwrap-sandbox
```

## Apply on a fresh machine

Run from this directory, as a user with `sudo`.

1. Check the system profile still matches the reference copy. If this prints anything, stop and
   update `bwrap-sandbox` first (see [Maintenance](#maintenance)):

   ```sh
   diff profile-files/bwrap-userns-restrict /etc/apparmor.d/bwrap-userns-restrict
   ```

2. Install the replacement profile, owned by root so an unprivileged user cannot weaken it:

   ```sh
   sudo install -m 644 -o root -g root profile-files/bwrap-sandbox /etc/apparmor.d/bwrap-sandbox
   ```

3. Disable the original so it is not loaded at boot. Both files define the same profile names;
   without this the original wins after a reboot. The `disable/` directory may not exist on a
   fresh install; `apparmor_parser` skips every profile linked from it.

   ```sh
   sudo mkdir -p /etc/apparmor.d/disable
   sudo ln -s /etc/apparmor.d/bwrap-userns-restrict /etc/apparmor.d/disable/
   ```

4. Load the new profile. `-r` replaces the loaded profiles with the same names, no reboot needed:

   ```sh
   sudo apparmor_parser -r /etc/apparmor.d/bwrap-sandbox
   ```

5. Verify as your normal user. This runs a sandbox inside a sandbox, like Claude Code does:

   ```sh
   bwrap --ro-bind / / --unshare-user --proc /proc --dev /dev \
     bwrap --ro-bind / / --unshare-user --dev /dev true && echo "nested userns OK"
   ```

   Note: `aa-status` only lists profile names, so it looks the same before and after the change.
   Use the test above instead.

6. Restart all Claude Code sessions (CLI and VS Code). In a new session, a sandboxed Bash command
   should run and `cat /proc/self/attr/current` should print `bwrap//&unpriv_bwrap (enforce)`.

If step 5 fails, look for denials and move only the named capability from the deny list to the
allow line:

```sh
sudo journalctl -k --since "10 min ago" | grep 'apparmor="DENIED"'
```

## Rollback

```sh
sudo rm /etc/apparmor.d/disable/bwrap-userns-restrict /etc/apparmor.d/bwrap-sandbox
sudo apparmor_parser -r /etc/apparmor.d/bwrap-userns-restrict
```

The first path is a symlink, so `rm` removes only the link; the original profile stays intact.
Reloading it restores Ubuntu's behavior immediately.

## Security trade-offs

**What Ubuntu's restriction protects against.** A user namespace gives an unprivileged process
"root" inside the namespace, which exposes kernel code normally reachable only by root (mounts,
nftables, ...). Bugs in that code have repeatedly allowed local privilege escalation to real root
(e.g. CVE-2022-0185, CVE-2024-1086). Ubuntu blocks this for unprivileged users and, via
`unpriv_bwrap`, for anything started through `bwrap`.

**What this fix gives up.** Any process running as any local user can now use `bwrap` to get
`CAP_SYS_ADMIN` inside a nested user namespace. Combined with an unpatched kernel bug in code
reachable with that capability, malicious code already running on the machine could become root.
This affects every `bwrap` user on the machine (Flatpak, GNOME image loaders), not only Claude
Code.

**What it keeps.** All other capabilities stay denied inside `bwrap`, including `CAP_NET_ADMIN`,
which the well-known nf_tables escalation exploits need. User namespaces outside `bwrap` stay
restricted. This is narrower than the `flags=(unconfined)` profile in Claude Code's docs.

**Why it is worth it.** Without a working sandbox, every command an agent runs has full access to
your user's files: SSH keys, credentials, browser data, all projects. That risk is everyday and
needs no kernel bug. The fix trades it for a rare one that needs both malicious code on the machine
and an unpatched kernel bug.

**It matters more for accounts without `sudo`.** A `sudo` user's account is already a thin wall to
root (e.g. a fake `sudo` in `~/.bashrc` captures the password), so this fix costs little there. For
an account without `sudo`, the restriction is one of the things keeping root out of reach.

**Reduce the remaining risk:**

- Keep the kernel patched (`unattended-upgrades`, reboot after kernel updates, or
  `sudo pro enable livepatch`).
- Use a separate admin account; develop as a user without `sudo`.
- Do not add the development user to the `docker` group. It is root-equivalent without any kernel
  bug and makes this whole analysis moot. Use rootless Podman instead.

## What did not work

- **`priority=1 capability sys_admin,` in `/etc/apparmor.d/local/unpriv_bwrap`** (the workaround
  from the upstream issue). AppArmor 5.0.2 ignores `priority` on capability rules: the compiled
  policy is byte-identical with and without it, and the deny still wins.
- **`kernel.apparmor_restrict_unprivileged_userns = 0`.** Disables the restriction for all
  programs, and does not help anyway: the `unpriv_bwrap` deny is part of the loaded profile,
  independent of the sysctl.
- **`sandbox.enableWeakerNestedSandbox: true`** in Claude Code settings. Only changes the error to
  `unshare(CLONE_NEWUSER): Invalid argument`.

## Maintenance

While the original is disabled, Ubuntu's updates to it no longer take effect. After `apparmor`
package upgrades, check whether it changed:

```sh
diff profile-files/bwrap-userns-restrict /etc/apparmor.d/bwrap-userns-restrict
```

If it did, apply the same change to `profile-files/bwrap-sandbox`, copy the new original over
`profile-files/bwrap-userns-restrict`, and repeat steps 2 and 4.
