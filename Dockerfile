# Node Alpine container image
FROM alpine:3.6

RUN apk update && apk add --no-cache nmap && \
    echo @edge http://nl.alpinelinux.org/alpine/edge/community >> /etc/apk/repositories && \
    echo @edge http://nl.alpinelinux.org/alpine/edge/main >> /etc/apk/repositories && \
    apk update && \
    apk add --no-cache \
      chromium \
      harfbuzz \
      "freetype>2.8" \
      ttf-freefont \
      nss

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

# Install artillery globally
RUN npm i -g artillery --allow-root --unsafe-perm=true
RUN npm i puppeteer

# Copy bash script to root of container image
COPY entrypoint.sh /entrypoint.sh
COPY generate-pdf.js /generate-pdf.js

RUN chmod +x /entrypoint.sh

# Execute Bash script on container start up
ENTRYPOINT ["/entrypoint.sh"]