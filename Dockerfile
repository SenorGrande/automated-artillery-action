# Node Alpine container image
FROM node:14.14.0

# Manually install missing shared libs for Chromium.
RUN apt-get update && \
apt-get install -yq --no-install-recommends gconf-service libasound2 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 \
libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 \
libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 \
libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 \
ca-certificates fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils wget gdebi unzip

# See https://crbug.com/795759
RUN apt-get update && apt-get -yq upgrade && apt-get install \
  && apt-get autoremove && apt-get autoclean

# Install latest chrome dev package and fonts to support major charsets (Chinese, Japanese, Arabic, Hebrew, Thai and a few others)
# Note: this installs the necessary libs to make the bundled version of Chromium that Puppeteer
# installs, work.
# https://www.ubuntuupdates.org/package/google_chrome/stable/main/base/google-chrome-unstable
RUN wget -q http://dl.google.com/linux/deb/pool/main/g/google-chrome-unstable/google-chrome-unstable_86.0.4209.2-1_amd64.deb \
  && gdebi --non-interactive ./google-chrome-unstable_86.0.4209.2-1_amd64.deb \
  && rm -rf *.deb

# Install artillery globally
RUN npm i -g artillery --allow-root --unsafe-perm=true
RUN npm i puppeteer

# Copy bash script to root of container image
COPY entrypoint.sh /entrypoint.sh
COPY generate-pdf.js /generate-pdf.js

RUN chmod +x /entrypoint.sh

# Execute Bash script on container start up
ENTRYPOINT ["/entrypoint.sh"]