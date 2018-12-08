FROM elixir:1.7-slim

RUN mkdir /build mkdir /app
COPY . /build
ARG VERSION=0.1.0

RUN set -xe && buildDeps=' \
        build-essential \
        erlang-dev \
    ' \
    && apt-get update \
    && apt-get install -y --no-install-recommends $buildDeps \
    && mix local.hex --force \
    && mix local.rebar --force \
    && cd /build \
    && MIX_ENV=prod mix deps.get \
    && MIX_ENV=prod mix release \
    && cp _build/prod/rel/simplebank/releases/${VERSION}/simplebank.tar.gz /app/ \
    && cd /app \
    && tar -xzf simplebank.tar.gz \
    && rm -rf /build \
    && rm -rf ~/.hex \
    && apt-get purge -y --auto-remove $buildDeps \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

CMD ["/app/bin/simplebank", "foreground"]