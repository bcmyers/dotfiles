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
    bash("brew update")
    bash("brew upgrade")
    bash("brew upgrade --cask")
    bash("brew cleanup")
    bash("deno upgrade", allow_fail=True)
    bash("rustup update")
    bash("rustup self update")
    bash("cargo install-update --all")
    bash(
        "git pull",
        cwd="/Users/bcmyers/opt/rust-analyzer",
    )
    bash(
        "cargo xtask install",
        cwd="/Users/bcmyers/opt/rust-analyzer",
    )
    bash("nvim +'PlugInstall' +qall")
    bash("nvim +CocUpdateSync +qall")
    # bash("sudo /usr/libexec/locate.updatedb")


if __name__ == "__main__":
    main()
