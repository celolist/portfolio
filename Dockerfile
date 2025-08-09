FROM node:20 AS base

# Rust install
RUN apt-get update && apt-get install -y curl build-essential \
    && curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# cargo-edit install
RUN cargo install cargo-edit

WORKDIR /app

# Node.js packages install
RUN npm install express @remix-run/express http-proxy-middleware

# init scripts
COPY init.sh /init.sh
RUN chmod +x /init.sh

EXPOSE 8080
CMD ["/init.sh"]