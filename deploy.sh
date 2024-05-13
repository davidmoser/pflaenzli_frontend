#!/bin/bash
npm run build
sudo rm -rf /var/www/pflaenzli_frontend
sudo mkdir /var/www/pflaenzli_frontend
sudo cp -r dist/* /var/www/pflaenzli_frontend
sudo chown -R www-data:www-data /var/www/pflaenzli_frontend/
sudo systemctl reload nginx.service