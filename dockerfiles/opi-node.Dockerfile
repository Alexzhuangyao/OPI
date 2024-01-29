FROM ubuntu:22.04

# This installs all dependencies that we need.
RUN apt update -y && \
    apt install build-essential git clang curl libssl-dev llvm libudev-dev make cmake protobuf-compiler postgresql postgresql-contrib -y

# This installs Rust and updates Rust to the right version.
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > rust_install.sh && chmod u+x rust_install.sh && ./rust_install.sh -y && \
    . $HOME/.cargo/env && rustup show

ENV POSTGRES_PASSWORD=Changeme_123

RUN service postgresql start && \
    su - postgres -c "psql -c \"ALTER USER postgres WITH PASSWORD $POSTGRES_PASSWORD';\"";

# This installs all python libs that we need to run python scripts.
RUN pip install python-dotenv;pip install psycopg2-binary;pip install json5;pip install requests;pip install stdiomask;

# This builds the binary.
RUN cd ./ord;$HOME/.cargo/bin/cargo build --release;cp target/release/ord /usr/bin/

RUN cd ./modules/main_index; npm install;cd ../brc20_api; npm install;cd ../bitmap_api; npm install;cd ../sns_api; npm install;

COPY main_index.env ./modules/main_index/.env
COPY brc20_api.env ./modules/brc20_index/.env

ENTRYPOINT [""]
# CMD ["nohup /usr/bin/node ./modules/index.js >> ./modules/index.log&;"]
CMD ["/usr/bin/node ./modules/index.js;"]