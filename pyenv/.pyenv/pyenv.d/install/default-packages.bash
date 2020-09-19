#!/usr/bin/env bash

source ${PYENV_ROOT}/libexec/install_packages.bash

if declare -Ff after_install >/dev/null; then
    after_install 'install_packages $VERSION_NAME'
else
    echo "pyenv: pyenv-default-packages plugin requires pyenv v0.1.0 or later" >&2
fi
