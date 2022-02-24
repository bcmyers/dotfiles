#!/usr/bin/env python3

from pathlib import Path
import shlex
import subprocess
import sys
from typing import Optional


def blue(s: str) -> str:
    return "\033[94m" + s + "\033[0m"


def red(s: str) -> str:
    return "\033[91m" + s + "\033[0m"


def bash(
    command: str, *, allow_fail: bool = False, cwd: Optional[Path] = None
):
    print(blue(command))
    commands = shlex.split(command)
    completed = subprocess.run(commands, cwd=cwd)
    if (not allow_fail) and completed.returncode != 0:
        print(red(f'"{command}" FAILED'))
        sys.exit(1)


def main():
    bash("yay -Syyuu")
    bash("yay -Yc")
    bash("yay -Sc")
    bash("pip2 install --upgrade -r /home/bcmyers/.pyenv/requirements.txt")
    bash("pip3 install --upgrade -r /home/bcmyers/.pyenv/requirements.txt")
    bash("yarn global upgrade")
    bash("rustup self update")
    bash("rustup update")
    bash("cargo install-update --all")
    bash("cargo cache --autoclean")
    bash(
        "git checkout master",
        cwd="/home/bcmyers/opt/rust-analyzer",
    )
    bash(
        "git pull",
        cwd="/home/bcmyers/opt/rust-analyzer",
    )
    bash(
        "cargo +nightly xtask install",
        cwd="/home/bcmyers/opt/rust-analyzer",
    )
    bash("sudo journalctl --vacuum-size=1G")
    bash("sudo updatedb")


if __name__ == "__main__":
    main()
