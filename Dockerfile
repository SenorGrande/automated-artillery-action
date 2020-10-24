# Node Alpine container image
FROM python:3.8

# Install python & pip
# RUN apt update -y && apt upgrade -y && apt install python python3-pip -y

RUN apt-get install git-core curl build-essential openssl libssl-dev \
  && git clone https://github.com/nodejs/node.git \
  && cd node \
  && ./configure \
  && make \
  && sudo make install

# Install python package
RUN pip3 install weasyprint

# Install artillery globally
RUN npm i -g artillery --allow-root --unsafe-perm=true

# Copy bash script to root of container image
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

# Execute Bash script on container start up
ENTRYPOINT ["/entrypoint.sh"]