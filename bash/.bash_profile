source ~/.bashrc
export PATH="/Users/bcmyers/.local/share/solana/install/active_release/bin:$PATH"

export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent
