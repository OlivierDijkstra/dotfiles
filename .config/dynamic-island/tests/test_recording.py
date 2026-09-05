"""Exercise real file/process watchers using a harmless stand-in recorder."""

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


class RecordingEvents(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory(prefix="island-recording-test-")
        self.addCleanup(self.directory.cleanup)
        self.pidfile = Path(self.directory.name) / "recorder.pid"
        self.pathfile = Path(self.directory.name) / "recorder.path"
        self.messages = queue.Queue()
        self.logs = []
        tests = Path(__file__).parent
        config = Path(self.directory.name)
        # Quickshell requires imported components to live inside its config root.
        shutil.copy2(tests.parent / "components/widgets/RecordingState.qml", config)
        fixture = (tests / "fixtures/recording.qml").read_text()
        (config / "shell.qml").write_text(fixture.replace('"../../components/widgets"', '"."'))
        environment = {**os.environ, "QT_QPA_PLATFORM": "offscreen",
                       "ISLAND_TEST_PIDFILE": str(self.pidfile), "ISLAND_TEST_PATHFILE": str(self.pathfile)}
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
        self.stop(self.shell)
        self.reader.join(timeout=2)
        self.shell.stdout.close()

    @staticmethod
    def stop(process):
        if process.poll() is None:
            process.terminate()
        process.wait(timeout=5)

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
        self.fail("Expected recording status not received:\n" + "".join(self.logs))

    def start_recorder(self):
        recorder = subprocess.Popen(["sleep", "30"])
        self.addCleanup(self.stop, recorder)
        self.pathfile.write_text("/tmp/example recording.mp4\n")
        self.pidfile.write_text(str(recorder.pid) + "\n")
        return recorder

    def test_start_tick_crash_and_restart(self):
        self.await_status(lambda status: not status["recording"])
        recorder = self.start_recorder()
        self.await_status(lambda status: status["recording"] and status["path"] == "/tmp/example recording.mp4")
        self.await_status(lambda status: status["recording"] and status["elapsed"] >= 1)

        # Crashing without removing either file must still hide the badge.
        self.stop(recorder)
        self.await_status(lambda status: not status["recording"])
        self.assertTrue(self.pidfile.exists())

        recorder = self.start_recorder()
        self.await_status(lambda status: status["recording"])
        replacement = self.pathfile.with_suffix(".new")
        replacement.write_text("/tmp/replaced.mp4\n")
        replacement.replace(self.pathfile)
        self.await_status(lambda status: status["path"] == "/tmp/replaced.mp4")
        self.stop(recorder)
        self.pidfile.unlink()
        self.pathfile.unlink()
        self.await_status(lambda status: not status["recording"])

        # Once idle, no recurring status subprocess or process watcher remains.
        time.sleep(1.2)
        children = Path(f"/proc/{self.shell.pid}/task/{self.shell.pid}/children").read_text().strip()
        self.assertEqual(children, "")
        self.assertFalse(any("ERROR:" in line or "WARN" in line for line in self.logs), "".join(self.logs))


if __name__ == "__main__":
    unittest.main()
