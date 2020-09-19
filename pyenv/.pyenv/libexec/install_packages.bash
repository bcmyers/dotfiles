#!/usr/bin/env bash

install_packages() {
    [[ "$STATUS" = "0" ]] || return 0

    local installed_version requirements_file

    installed_version=$1
    requirements_file=${PYENV_ROOT}/requirements.txt

    PYENV_VERSION="$installed_version" pyenv-exec pip install --upgrade pip || {
      echo "pyenv: error upgrading pip"
    } >&2

    PYENV_VERSION="$installed_version" pyenv-exec pip install -r "$requirements_file" || {
        echo "pyenv: error installing packages"
    } >&2
}
