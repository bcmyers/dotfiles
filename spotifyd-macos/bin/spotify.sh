#!/usr/bin/env bash

set -euo pipefail

spotifyd --autoplay --no-daemon --backend portaudio
