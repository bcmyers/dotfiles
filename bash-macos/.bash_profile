source ~/.bashrc
export PATH="/Users/bcmyers/.local/share/solana/install/active_release/bin:$PATH"

export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent

export PATH="/usr/local/opt/php@7.4/bin:$PATH"
export PATH="/usr/local/opt/php@7.4/sbin:$PATH"

export WASMTIME_HOME="$HOME/.wasmtime"

export PATH="$WASMTIME_HOME/bin:$PATH"
# START of php@7.4 bin path -created_by_salt-
export PATH="/usr/local/opt/php@7.4/bin:$PATH"
# END of php@7.4 bin path --
