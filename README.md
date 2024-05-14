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

## First Deployment

- Pull the `pflaenzli_frontend` code from github to the server
- Install nodejs and npm: `sudo apt install nodejs npm -y`
- Install dependencies: `npm install`
- Install nginx: `sudo apt install nginx`
- Install password utility: `sudo apt install apache2-utils`
- Create a password for basic authentication: `sudo htpasswd -c /etc/nginx/.htpasswd username`
- Copy site configuration, enter your server IP or url: `sudo cp pflaenzli.nginx /etc/nginx/sites-available/pflaenzli`
- Enable site by linking configuration: `sudo ln -s /etc/nginx/sites-available/pflaenzli /etc/nginx/sites-enabled/`
- To create website deployment folder `/var/www/pflaenzli_frontend` and copy the files with the right permission run `./deploy.sh`

## Update deployment

- Pull the new code with git
- Run `./deploy.sh`