[ -r ~/.bashrc ] && source ~/.bashrc

# gpg
is_in_path gpgconf
if [[ "$?" -eq 0 ]]; then
  gpgconf --kill gpg-agent
  gpgconf --launch gpg-agent
  export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
  GPG_TTY=$(tty)
  export GPG_TTY
fi
