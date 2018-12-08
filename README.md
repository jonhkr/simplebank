# SimpleBank

A simple bank API written in Elixir.

## Features

Users can register by providing their name, username, password and email.

Upon registration a `BRL` account is created and an initial deposit of R$ 1.000,00 will be loaded to the account.

Transfers between accounts can be made by providing the `IBAN` of the destination account and the amount to be transfered.

Withdrawals can be requested by entering the amount to be withdrawn.

Users can generate a report of their transactions filtering by period.

## Running

Follow the kubernetes deployment guide [here](kubernetes/README.md).

## Monitoring

## API Specification

[Here](docs/api-spec.md)