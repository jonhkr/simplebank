# SimpleBank

[![Build Status](https://travis-ci.org/jonhkr/simplebank.svg?branch=master)](https://travis-ci.org/jonhkr/simplebank)

A simple bank API written in Elixir.

## Features

Users can register by providing their name, username, password and email.

Upon registration a `BRL` account is created and an initial deposit of R$ 1.000,00 will be loaded to the account.

Transfers between accounts can be made by providing the `IBAN` of the destination account and the amount to be transfered.

Withdrawals can be requested by entering the amount to be withdrawn.

Users can generate a report of their transactions filtering by period.

## Running

### Development environment

You will need a mysql server running either in your machine or in a docker container.

Copy the `config/dev.exs.sample` config file to `config/dev.exs` and adjust it to your environment:

```sh
cp config/dev.exs.sample config/dev.exs

# export EDITOR=/usr/bin/vim
$EDITOR config/dev.exs
```

After you've configured your environment, use the following commands to start the application:

```sh
# Make sure the MIX_ENV is set to dev
export MIX_ENV=dev

# Install the dependencies
mix deps.get

# Create the database
mix ecto.create

# Apply the migrations
mix ecto.migrate

# Run the application and access the console
iex -S mix
```

### Testing

Testing the application is similar to running it in development mode.
You will need a mysql server running either in your machine or in a docker container.

Copy the `config/test.exs.sample` config file to `config/test.exs` and adjust it to your environment:

```sh
cp config/test.exs.sample config/test.exs

# export EDITOR=/usr/bin/vim
$EDITOR config/test.exs
```

After you've configured your environment, use the following commands to test the application:

```sh
# Set the env to test. Optionally, add MIX_ENV=test before every mix command you execute (e.g. MIX_ENV=test mix deps.get).
export MIX_ENV=test

# Install the dependencies
mix deps.get

# Create the database
mix ecto.create

# Apply the migrations
mix ecto.migrate

# Run the tests
mix test
```

### Docker

A docker image is generated everytime a commit is pushed to the `master` branch.

This image is used do deploy the application in a Kubernetes cluster, but it can also be run outside kubernetes.

The image is located [here](https://hub.docker.com/r/jonhkr/simplebank/).

You will need a mysql instance for the application and it needs to be running in the same network the application is running, to achive that you can use these commands:

```sh
docker network create simplebank
docker run -d \
    --net simplebank \
    --name mysql \
    -e MYSQL_ROOT_PASSWORD=foo \
    mysql:5.6
```

The above commands are going to create a network called `simplebank` and start a container named `mysql` running the mysql server with password set to `foo`. As we created a network for our application, we can access the mysql servicer using the hostname `mysql.simplebank` and the default mysql port `3306`

We need to create a database to be used by the application, to do that run the following command:

```sh
docker run -it \
    --net simplebank \
    --name mysql-client \
    --rm \
    mysql:5.6 \
    mysql -h mysql.simplebank -P3306 -uroot -pfoo -e "create database simplebank;"
```

Now, copy the `kubernetes/config.toml.sample` to `config.toml` and edit it to your needs.

```sh
cp kubernetes/config.toml.sample config.toml

# export EDITOR=/usr/bin/vim
$EDITOR config.toml
```

After that, lets apply the migrations by running the following command:

```sh
docker run -it \
    --net simplebank \
    --name simplebank-migrations \
    --mount type=bind,source="$(pwd)"/config.toml,target=/app/config/config.toml \
    --rm \
    jonhkr/simplebank \
    /app/bin/simplebank migrate
```

Finally, run the application with this command:

```sh
docker run -d -it \
    --net simplebank \
    --name simplebank \
    --mount type=bind,source="$(pwd)"/config.toml,target=/app/config/config.toml \
    jonhkr/simplebank
```

The container will run in the background, to see the logs use:

```sh
docker logs -f simplebank
```

To access the service api use:

```sh
docker run --rm \
    --net simplebank \
    appropriate/curl -X POST http://simplebank.simplebank:3000 YOUR CURL COMMAND
```

### Kubernetes

Follow the kubernetes deployment guide [here](kubernetes/README.md).

## Monitoring

The application comes with a built in logstash backend. To use it configure the `logstash` backend:

```elixir
config :logger, :logstash,
  host: "logstash-host",
  port: 10001,
  type: "app"
```

When running on docker the configuration must be set in the `config.toml` file, for example:

```toml
[logger.logstash]
host = "simplebank-logstash"
port = 10001
type = "app"
```

To setup Kibana + Elasticsearch + Logstash on Minikube, run:

```sh
kubectl apply -f kubernetes/kibana-deployment.yaml
```

The logstash service will be mapped to `simplebank-logstash` hostname and port `10001`.

## API Specification

[Here](docs/api-spec.md)