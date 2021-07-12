source ~/.profile

if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi
if which pyenv-virtualenv-init > /dev/null; then
  eval "$(pyenv virtualenv-init -)"
fi
export PYENV_VIRTUALENVWRAPPER_PREFER_PYVENV="true"
export WORKON_HOME="$HOME/.virtualenvs"
pyenv virtualenvwrapper_lazy
export CPPFLAGS=-I/usr/local/opt/openssl@1.1/include
export LDFLAGS=-L/usr/local/opt/openssl@1.1/lib

alias luamake=/Users/bcmyers/opt/lua-language-server/3rd/luamake/luamake

# Created by `pipx` on 2021-07-12 02:43:56
export PATH="$PATH:/Users/bcmyers/.local/bin"
