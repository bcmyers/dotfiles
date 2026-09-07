"""Checks for signed-index parsing and keeping the app after build failure."""

import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

sys.dont_write_bytecode = True
spec = importlib.util.spec_from_file_location(
    "updater", Path(__file__).resolve().parents[1] / "scripts/update-chatgpt.py"
)
updater = importlib.util.module_from_spec(spec)
spec.loader.exec_module(updater)


class UpdateTests(unittest.TestCase):
    index = (
        "Package: chatgpt\nArchitecture: amd64\nVersion: 26.901.51231\n"
        "Filename: pool/main/c/chatgpt/chatgpt_26.901.51231_amd64.deb\n"
        + "SHA256: " + "a" * 64 + "\n"
    ).encode()

    def release(self):
        return (
            "Suite: stable\nCodename: stable\nSHA256:\n "
            + hashlib.sha256(self.index).hexdigest()
            + f" {len(self.index)} {updater.INDEX}\n"
        )

    def test_valid_index(self):
        updater.verify_index(self.release(), self.index)
        self.assertEqual(updater.package(self.index)["version"], "26.901.51231")

    def test_modified_index_is_rejected(self):
        with self.assertRaises(ValueError):
            updater.verify_index(self.release(), self.index + b"\n")

    def test_unexpected_download_path_is_rejected(self):
        index = self.index.replace(b"pool/main/c/chatgpt/", b"../other/")
        with self.assertRaises(ValueError):
            updater.package(index)

    def test_duplicate_digest_is_rejected(self):
        with self.assertRaises(ValueError):
            updater.package(self.index + b"SHA256: " + b"b" * 64 + b"\n")

    def test_build_failure_keeps_current_profile(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            installed = root / "installed"
            (installed / "nix-support").mkdir(parents=True)
            current = {"version": "26.900.1", "sha256": "b" * 64}
            (installed / "nix-support/upstream.json").write_text(json.dumps(current))
            state = root / "state"
            state.mkdir()
            (state / "profile").symlink_to(installed)
            args = argparse.Namespace(state_directory=state, keyring=root / "keyring",
                                      fallback=installed, expression=root / "package.nix", check=False)
            with patch.object(updater, "latest_release", return_value=updater.package(self.index)), \
                 patch.object(updater.subprocess, "run", side_effect=[
                     subprocess.CompletedProcess([], 1),  # latest is not older
                     subprocess.CalledProcessError(1, ["nix", "build"]),
                 ]):
                with self.assertRaises(subprocess.CalledProcessError):
                    updater.update(args)
            self.assertEqual((state / "profile").resolve(), installed.resolve())
            self.assertEqual(json.loads((installed / "nix-support/upstream.json").read_text()), current)


if __name__ == "__main__":
    unittest.main()
