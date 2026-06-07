FROM nginx:stable-alpine

LABEL maintainer="Marco Bergonzi"

# Custom nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Static site
COPY html/ /usr/share/nginx/html/

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
