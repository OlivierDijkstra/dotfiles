# restic-oliarch

Daily restic backup of oliarch to `/mnt/nasigoreng/backups/restic` (CIFS share on nasigoreng), with a weekly prune and integrity check, failure notifications and a status file for the dynamic island.

These files are sources only. `scripts/install-restic-backup` installs them as root-owned copies, because units symlinked into `/home` dangle when systemd loads units at early boot (`@home` mounts later), which silently dropped the old `restic-backup.timer` from February 2026 onward.

## Install or update

```sh
sudo /home/oli/dotfiles/scripts/install-restic-backup
```

The installer is idempotent. It:

- removes the old `restic-backup.{service,timer}` links if they point into `/home`;
- copies the units to `/etc/systemd/system` and `oliarch-backup` to `/usr/local/sbin`;
- writes `/etc/restic-oliarch/{env,excludes}` from this directory (re-run it after editing them);
- keeps a working `/etc/restic-oliarch/password`, or copies the first of `/root/.config/restic/password` and `~oli/.config/restic/password` that opens the repo;
- seeds `status.json` from the latest snapshot, then enables both timers.

## Layout

| Source | Installed as | Purpose |
| --- | --- | --- |
| `oliarch-backup` | `/usr/local/sbin/oliarch-backup` | `backup [--dry-run]`, `check`, `status`, `notify UNIT` |
| `restic-oliarch-backup.{service,timer}` | `/etc/systemd/system/` | daily at 12:30 (+≤10 min), `Persistent=true` |
| `restic-oliarch-check.{service,timer}` | `/etc/systemd/system/` | Sundays 14:00: `prune`, then `check --read-data-subset=5%` |
| `restic-oliarch-notify@.service` | `/etc/systemd/system/` | `OnFailure=` desktop notification to oli |
| `env.example` | `/etc/restic-oliarch/env` (0600) | repository, password file, cache dir |
| `excludes` | `/etc/restic-oliarch/excludes` (0600) | exclude patterns |

## What is backed up

`/etc`, `/home/oli`, `/srv` and `/var/backups/oliarch`, the last holding package lists (`pacman -Qqe`, `-Qqm`) and enabled system and user units, refreshed before each run. Runs use `--one-file-system`, `--exclude-caches`, and skip directories containing `CMakeCache.txt` or a `.nobackup` file.

Excluded: caches, toolchains and package stores (`.bun`, `.npm`, `.cargo`, `.rustup`, `go/pkg`, pnpm, uv, nvm versions), Steam and `~/Games`, podman storage, Trash, AppImages, model weights (`*.gguf`, `*.safetensors`, ComfyUI and chats-2 model dirs, Ollama models), disk and VM images, Electron and Chromium caches under `~/.config`, Codex and Claude caches, and build output (`node_modules`, `.next`, `.turbo`, `.venv`, `target`, `dist`, ...). Kept: all code sources and git history, Documents, Pictures, editor and agent settings, Codex and Claude sessions, and the T3 Code database.

As of 2026-10-30, a dry run processes about 60 GiB in 416k files.

Retention: `forget --host oliarch --keep-daily 7 --keep-weekly 4 --keep-monthly 6` after every backup. Pruning runs weekly with the check. Older snapshots with different paths (`/`, December 2025 to February 2026) form their own groups and are kept.

## Status file

`/var/lib/restic-oliarch/status.json` (0644) is replaced atomically at the start and end of each run, including failures (EXIT trap):

```json
{
  "host": "oliarch",
  "state": "ok",
  "last_start": "2026-10-30T12:31:02+01:00",
  "last_end": "2026-10-30T12:44:10+01:00",
  "last_success": "2026-10-30T12:43:58+01:00",
  "snapshot_id": "…",
  "files_new": 812,
  "files_changed": 1904,
  "data_added": 1234567890,
  "total_bytes": 64150000000,
  "duration": 788,
  "error": null,
  "last_check": "2026-10-25T14:05:00+01:00",
  "last_check_result": "ok",
  "check_error": null
}
```

`state` is `running`, `ok` or `failed`. `error` is a short reason (the failing step and restic's last error line), or a warning when restic exits 3 because some files were unreadable. The dynamic island reads this file; see its README.

## Operating

```sh
sudo systemctl start restic-oliarch-backup.service   # run now
journalctl -fu restic-oliarch-backup.service          # follow progress (one line per minute)
oliarch-backup status                                 # status.json and timers
sudo oliarch-backup backup --dry-run                  # what would be added
sudo sh -c 'set -a; . /etc/restic-oliarch/env; restic snapshots --host oliarch'
```

Stale locks from crashed runs are cleared with `restic unlock`, which only removes locks whose process is gone. Backup and check runs are serialised with `flock`.

Without root, a dry run needs the repository environment and the repo's exclude file:

```sh
RESTIC_REPOSITORY=/mnt/nasigoreng/backups/restic RESTIC_PASSWORD_FILE=~/.config/restic/password \
OLIARCH_BACKUP_EXCLUDES=~/dotfiles/system/restic-oliarch/excludes \
  ~/dotfiles/system/restic-oliarch/oliarch-backup backup --dry-run
```

If the NAS mount fails, systemd doesn't start the service (`RequiresMountsFor=`), so neither the status file nor the notification fires. The island's "overdue" alert after two days covers that case.
