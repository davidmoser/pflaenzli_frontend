#!/bin/bash
set -e
# Build requires Node >=20.19/22.12 (Vite 8). nvm isn't sourced in a non-interactive
# ssh shell, so load it here and select Node 22.
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
nvm use 22 >/dev/null
npm run build
sudo rm -rf /var/www/pflaenzli_frontend
sudo mkdir /var/www/pflaenzli_frontend
sudo cp -r dist/* /var/www/pflaenzli_frontend
sudo chown -R www-data:www-data /var/www/pflaenzli_frontend/
sudo systemctl reload nginx.service