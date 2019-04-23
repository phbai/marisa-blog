FROM nginx:latest

COPY nginx.conf /etc/nginx/nginx.conf
WORKDIR /usr/share/nginx/html
COPY ./public/ /usr/share/nginx/html
