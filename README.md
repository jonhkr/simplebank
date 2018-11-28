# SimpleBank

A simple bank API written in Elixir.

## Features

Users can register by providing their name, username, password and email.

Upon registration a `BRL` account is created and an initial deposit of R$ 1.000,00 will be loaded to the account.

Transfers between accounts can be made by providing the `IBAN` of the destination account and the amount to be transfered.

Withdrawals can be requested by entering the amount to be withdrawn.

Users can generate a report of their transactions filtering by period.

## API Specification

### User registration

Request:
```
POST /v1/users
Content-Type: application/json


{
	"name": "Your Name",
	"username": "your-username",
	"raw_password": "yourpassword",
	"email": "Your email"
}
```

Response:
```
< HTTP/1.1 200 OK
< cache-control: max-age=0, private, must-revalidate
< content-length: 92
< date: Wed, 28 Nov 2018 20:54:52 GMT
< server: Cowboy
< x-request-id: 2llma8eep65ua5o1to0000o1

{
	"id": 121,
	"name": "Your Name",
	"username": "your-username",
	"inserted_at": "2018-11-28T20:54:53"
}
```

Curl request:
```
curl -X POST http://localhost:3000/v1/users -H "content-type:application/json" -d '{
    "name": "Your name",
    "username": "Your username",
    "raw_password": "Your password",
    "email": "Your email"
}'
```


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `simplebank` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:simplebank, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/simplebank](https://hexdocs.pm/simplebank).

