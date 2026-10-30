"""Drive BackupState through status.json replacements, as oliarch-backup writes them."""

from datetime import datetime, timedelta
import json
import os
from pathlib import Path
import queue
import shutil
import subprocess
import tempfile
import threading
import time
import unittest


def iso(moment):
    return moment.isoformat(timespec="seconds")


class BackupEvents(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory(prefix="island-backup-test-")
        self.addCleanup(self.directory.cleanup)
        config = Path(self.directory.name)
        self.status = config / "status.json"
        self.messages = queue.Queue()
        self.logs = []
        island = Path(__file__).parent.parent
        # Quickshell requires imported components to live inside its config root.
        shutil.copytree(island / "components", config / "components")
        shutil.copytree(island / "assets", config / "assets")
        fixture = (island / "tests/fixtures/backup.qml").read_text()
        (config / "shell.qml").write_text(fixture.replace('"../../components/widgets"', '"components/widgets"'))
        environment = {**os.environ, "QT_QPA_PLATFORM": "offscreen", "ISLAND_TEST_BACKUP_STATUS": str(self.status)}
        environment.pop("WAYLAND_DISPLAY", None)
        self.shell = subprocess.Popen(
            ["quickshell", "--no-color", "-p", str(config)],
            env=environment,
            stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True,
        )
        self.reader = threading.Thread(target=self.read_status, daemon=True)
        self.reader.start()
        self.addCleanup(self.stop_shell)

    def stop_shell(self):
        if self.shell.poll() is None:
            self.shell.terminate()
        self.shell.wait(timeout=5)
        self.reader.join(timeout=2)
        self.shell.stdout.close()

    def read_status(self):
        for line in self.shell.stdout:
            self.logs.append(line)
            if "ISLAND_TEST_STATUS " in line:
                self.messages.put(json.loads(line.split("ISLAND_TEST_STATUS ", 1)[1]))

    def await_status(self, predicate, timeout=5):
        deadline = time.monotonic() + timeout
        while time.monotonic() < deadline:
            try:
                status = self.messages.get(timeout=max(0.01, deadline - time.monotonic()))
            except queue.Empty:
                break
            if predicate(status):
                return status
        self.fail("Expected backup status not received:\n" + "".join(self.logs))

    def write(self, **fields):
        temporary = self.status.with_suffix(".tmp")
        temporary.write_text(json.dumps(fields))
        os.replace(temporary, self.status)

    def test_status_lifecycle(self):
        now = datetime.now().astimezone()
        self.await_status(lambda s: s["reason"] == "No backup status" and s["indicator"])

        self.write(state="running", last_start=iso(now), last_success=iso(now - timedelta(days=30)))
        self.await_status(lambda s: s["running"] and not s["alert"] and s["indicator"])

        self.write(state="ok", last_success=iso(now - timedelta(hours=3, minutes=1)), data_added=1234567890)
        self.await_status(lambda s: not s["alert"] and not s["indicator"]
                          and s["summary"] == "Last backup 3h ago · +1.2 GB")

        self.write(state="failed", last_success=iso(now - timedelta(hours=26, minutes=1)),
                   error="NAS mount check failed: /mnt/nasigoreng is not mounted")
        self.await_status(lambda s: s["reason"] == "Backup failed" and s["indicator"]
                          and s["title"] == "Backup failed · last success 26h ago"
                          and s["detail"] == "NAS mount check failed: /mnt/nasigoreng is not mounted"
                          and s["hint"] == "journalctl -u restic-oliarch-backup")

        self.write(state="ok", last_success=iso(now - timedelta(days=3)))
        self.await_status(lambda s: s["title"] == "Backup overdue · last success 3d ago")

        self.write(state="running", last_start=iso(now - timedelta(hours=13)), last_success=iso(now - timedelta(hours=14)))
        self.await_status(lambda s: s["reason"] == "Backup interrupted" and not s["running"])

        self.write(state="ok", last_success=iso(now - timedelta(hours=1)), last_check_result="failed",
                   check_error="restic check failed: pack 1a2b3c is damaged")
        self.await_status(lambda s: s["reason"] == "Repository check failed"
                          and s["detail"] == "restic check failed: pack 1a2b3c is damaged"
                          and s["hint"].endswith("journalctl -u restic-oliarch-check"))

        self.status.unlink()
        self.await_status(lambda s: s["reason"] == "No backup status")
        # Icons resolve against the indicator's own directory, not the importing file.
        self.assertFalse([line for line in self.logs if "Cannot open" in line])


if __name__ == "__main__":
    unittest.main()
