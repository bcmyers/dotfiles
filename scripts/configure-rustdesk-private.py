"""Merge the personal RustDesk networking policy while preserving credentials."""

import os
from pathlib import Path
import sys
import tempfile
import tomllib

import tomli_w


def configure(directory: Path, role: str) -> None:
    if role not in {"controller", "host"}:
        raise ValueError("role must be controller or host")
    path = directory / "RustDesk2.toml"
    existing = path.read_bytes() if path.exists() else b""
    data = tomllib.loads(existing.decode())
    options = data.setdefault("options", {})
    options.update(
        {
            # Unused loopback endpoints prevent public ID/relay registration.
            "custom-rendezvous-server": "127.0.0.1:21116",
            "relay-server": "127.0.0.1:21117",
            "api-server": "http://127.0.0.1:21114",
            "enable-lan-discovery": "N",
            "enable-tunnel": "N",
            "enable-file-transfer": "N",
            "enable-audio": "N",
            "enable-clipboard": "N",
            "allow-remote-config-modification": "N",
            "approve-mode": "click",
            "direct-server": "N" if role == "controller" else "Y",
            "stop-service": "Y" if role == "controller" else "N",
        }
    )
    data["rendezvous_server"] = "127.0.0.1:21116"
    if role == "host":
        options.update(
            {"direct-access-port": "21118", "whitelist": "127.0.0.1,::1"}
        )
    updated = tomli_w.dumps(data).encode()
    if updated == existing:
        return
    directory.mkdir(parents=True, exist_ok=True, mode=0o700)
    descriptor, temporary = tempfile.mkstemp(prefix=".private-networking-", dir=directory)
    try:
        with os.fdopen(descriptor, "wb") as output:
            output.write(updated)
        os.replace(temporary, path)
    finally:
        Path(temporary).unlink(missing_ok=True)


if __name__ == "__main__":
    configure(Path(sys.argv[1]), sys.argv[2])
