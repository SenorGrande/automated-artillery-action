# Node Alpine container image
FROM node:14.14.0

# Install python & pip
RUN apt update -y && apt upgrade -y && apt install python3.8 python3-pip -y

# Install python package
RUN pip3 install weasyprint

# Install artillery globally
RUN npm i -g artillery --allow-root --unsafe-perm=true

# Copy bash script to root of container image
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

# Execute Bash script on container start up
ENTRYPOINT ["/entrypoint.sh"]