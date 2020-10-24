# Node Alpine container image
FROM node:14.14.0

# Install python & pip
RUN apt update -y && apt upgrade -y && apt install build-essential python3-dev python3-pip python3-setuptools python3-wheel python3-cffi libcairo2 libpango-1.0-0 libpangocairo-1.0-0 libgdk-pixbuf2.0-0 libffi-dev shared-mime-info -y

# Install python package
RUN pip3 install weasyprint

# Install artillery globally
RUN npm i -g artillery --allow-root --unsafe-perm=true

# Copy bash script to root of container image
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

# Execute Bash script on container start up
ENTRYPOINT ["/entrypoint.sh"]