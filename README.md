# Pflaenzli Frontend

This is the frontend for the plant watering project. It displays a chart of the moisture and pump data and allows to send
actions and configuration changes to the backend and Arduino.

## Customize configuration

See [Vite Configuration Reference](https://vitejs.dev/config/).

## Project Setup

```sh
npm install
```

### Compile and Hot-Reload for Development

```sh
npm run dev
```

## Deployment

- Pull the `pflaenzli_frontend` code from github to the server
- Install nodejs and npm: `sudo apt install nodejs npm -y`
- Install dependencies: `npm install`
- Build files to serve: `npm run build`
- Install nginx: `sudo apt install nginx`
- Copy site configuration, enter your server IP: `sudo cp pflaenzli_frontend.nginx /etc/nginx/sites-available/pflaenzli_frontend`
- Enable site by linking configuration: `sudo ln -s /etc/nginx/sites-available/pflaenzli_frontend /etc/nginx/sites-enabled/`
- Nginx uses `www-data` user, which can't access the `pi` users folders
- Create a copy of the dist folder: `sudo mkdir /var/www/pflaenzli_frontend`
- Copy the data: `sudo cp -r dist/* /var/www/pflaenzli_frontend`
- Change the access: `sudo chown -R www-data:www-data /var/www/pflaenzli_frontend/`
- Restart nginx: `sudo systemctl reload nginx.service`
