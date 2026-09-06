"""Install the newest signed official Linux preview in a private Nix profile."""

import argparse
import fcntl
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import tempfile

BASE = "https://persistent.oaistatic.com/codex-app-prod/linux/deb/"
INDEX = "main/binary-amd64/Packages"


def fetch(relative: str) -> bytes:
    data = subprocess.run([
        "curl", "--fail", "--location", "--silent", "--show-error",
        "--proto", "=https", "--proto-redir", "=https", "--max-time", "30",
        "--max-filesize", str(4 * 1024 * 1024), BASE + relative,
    ], stdout=subprocess.PIPE, check=True).stdout
    if len(data) > 4 * 1024 * 1024:
        raise ValueError("Update metadata exceeds the size limit")
    return data


def paragraphs(text: str) -> list[dict[str, str]]:
    result = []
    for paragraph in text.strip().split("\n\n"):
        fields = {}
        previous = None
        for line in paragraph.splitlines():
            if line.startswith((" ", "\t")) and previous:
                fields[previous] += "\n" + line.strip()
            else:
                previous, value = line.split(":", 1)
                if previous in fields:
                    raise ValueError(f"Duplicate metadata field: {previous}")
                fields[previous] = value.strip()
        result.append(fields)
    return result


def verify_index(release: str, index: bytes) -> None:
    fields, = paragraphs(release)
    if fields.get("Suite") != "stable" or fields.get("Codename") != "stable":
        raise ValueError("Unexpected OpenAI release channel")
    matches = [parts for line in fields["SHA256"].splitlines()
               if (parts := line.split()) and parts[-1] == INDEX]
    if len(matches) != 1:
        raise ValueError("Signed release does not uniquely identify the package index")
    digest, size, _ = matches[0]
    if len(index) != int(size) or hashlib.sha256(index).hexdigest() != digest:
        raise ValueError("Package index does not match the signed release")


def package(index: bytes) -> dict[str, str]:
    packages = [p for p in paragraphs(index.decode())
                if p.get("Package") == "chatgpt" and p.get("Architecture") == "amd64"]
    if not packages:
        raise ValueError("No x64 ChatGPT package in the signed index")
    latest = packages[0]
    for candidate in packages[1:]:
        if subprocess.run(["dpkg", "--compare-versions", candidate["Version"], "gt", latest["Version"]]).returncode == 0:
            latest = candidate
    version, digest = latest["Version"], latest["SHA256"]
    if not re.fullmatch(r"[0-9]+(?:\.[0-9]+)+", version):
        raise ValueError("ChatGPT changed its version format; review the Nix package")
    if not re.fullmatch(r"[0-9a-f]{64}", digest):
        raise ValueError("Invalid package SHA256")
    if latest["Filename"] != f"pool/main/c/chatgpt/chatgpt_{version}_amd64.deb":
        raise ValueError("ChatGPT changed its download path; review the Nix package")
    return {"version": version, "sha256": digest}


def latest_release(keyring: Path) -> dict[str, str]:
    with tempfile.TemporaryDirectory(prefix="chatgpt-update-") as temporary:
        directory = Path(temporary)
        signed = directory / "InRelease"
        release = directory / "Release"
        signed.write_bytes(fetch("dists/stable/InRelease"))
        # An isolated keyring accepts only the public key shipped by the module.
        subprocess.run(["gpgv", "--homedir", temporary, "--keyring", str(keyring),
                        "--output", str(release), str(signed)], check=True)
        index = fetch("dists/stable/" + INDEX)
        verify_index(release.read_text(), index)
        return package(index)


def update(args: argparse.Namespace) -> None:
    state = args.state_directory
    state.mkdir(parents=True, exist_ok=True, mode=0o700)
    with (state / "update.lock").open("w") as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            print("A ChatGPT update is already running.")
            return
        latest = latest_release(args.keyring.resolve())
        profile = state / "profile"
        current_path = profile if profile.exists() else args.fallback
        current = json.loads((current_path / "nix-support/upstream.json").read_text())
        print(f"Installed: {current['version']}; latest official Linux preview: {latest['version']}", flush=True)
        if latest == current or args.check:
            return
        if subprocess.run(["dpkg", "--compare-versions", latest["version"], "lt", current["version"]]).returncode == 0:
            print("Ignoring an older release; automatic updates never downgrade.")
            return
        result = subprocess.run([
            "nix", "--extra-experimental-features", "nix-command flakes", "build",
            "--file", str(args.expression), "--argstr", "version", latest["version"],
            "--argstr", "sha256", latest["sha256"], "--no-link", "--json",
            "--max-jobs", "1", "--cores", "2",
        ], stdout=subprocess.PIPE, text=True, check=True)
        output = Path(json.loads(result.stdout)[0]["outputs"]["out"])
        if json.loads((output / "nix-support/upstream.json").read_text()) != latest:
            raise ValueError("Built package does not match the verified release")
        if not os.access(output / "bin/chatgpt", os.X_OK):
            raise ValueError("Built ChatGPT launcher is missing")
        # Seed the fallback as generation 1 so the first update can roll back.
        if not profile.exists():
            subprocess.run(["nix-env", "--profile", str(profile), "--set", str(args.fallback)], check=True)
        subprocess.run(["nix-env", "--profile", str(profile), "--set", str(output)], check=True)
        if subprocess.run(["nix-env", "--profile", str(profile), "--delete-generations", "+3"]).returncode:
            print("The update succeeded, but old generations could not be pruned.")
        print(f"ChatGPT {latest['version']} is ready for the next launch. Previous generations are retained.")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--expression", required=True, type=Path)
    parser.add_argument("--keyring", required=True, type=Path)
    parser.add_argument("--fallback", required=True, type=Path)
    parser.add_argument("--state-directory", required=True, type=Path)
    parser.add_argument("--check", action="store_true", help="Verify update metadata without installing")
    args = parser.parse_args()
    try:
        update(args)
    except (OSError, ValueError, KeyError, subprocess.CalledProcessError) as error:
        parser.exit(1, f"ChatGPT update failed: {error}\n")


if __name__ == "__main__":
    main()
