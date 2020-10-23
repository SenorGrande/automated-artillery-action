# Node Alpine container image
FROM node:14.14.0-alpine3.12

USER node

# Install artillery globally
RUN npm i -g artillery

# Copy bash script to root of container image
COPY entrypoint.sh /entrypoint.sh

# Execute Bash script on container start up
ENTRYPOINT ["/entrypoint.sh"]