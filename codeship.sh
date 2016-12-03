#!/bin/bash

git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.2.0
echo '. $HOME/.asdf/asdf.sh' >> ~/.bashrc
echo '. $HOME/.asdf/completions/asdf.bash' >> ~/.bashrc
source ~/.bashrc

asdf plugin-add erlang https://github.com/HashNuke/asdf-erlang.git
asdf plugin-add elixir https://github.com/HashNuke/asdf-elixir.git

asdf install erlang 19.0
asdf install elixir 1.3.4

asdf global elrang 19.0
asdf global elixir 1.3.4

cd ~/clone

export MIX_ENV=test

mix local.hex --force
mix local.rebar
mix hex.info
mix deps.get
