#!/usr/bin/env bash

source ${PYENV_ROOT}/libexec/install_packages.bash

if declare -Ff after_virtualenv >/dev/null; then
    after_virtualenv 'install_packages $VIRTUALENV_NAME'
else
    echo "pyenv: pyenv-default-packages plugin requires pyenv v0.1.0 or later" >&2
fi
