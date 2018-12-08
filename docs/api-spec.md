# SimpleBank

A simple bank API written in Elixir.

## API Specification

### User registration

Request:
```
POST /v1/users
Content-Type: application/json

{
	"name": "Your Name",
	"username": "username",
	"raw_password": "password",
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
	"username": "username",
	"inserted_at": "2018-11-28T20:54:53"
}
```

Curl request:
```
curl -X POST http://localhost:3000/v1/users -H "content-type:application/json" -d '{
    "name": "Your name",
    "username": "username",
    "raw_password": "password",
    "email": "Your email"
}'
```

### Creating an authentication token

Request:
```
POST /v1/sessions
Content-Type: application/json

{
	"username": "username",
	"raw_password": "password"
}
```

Response:
```
< HTTP/1.1 200 OK
< cache-control: max-age=0, private, must-revalidate
< content-length: 92
< date: Wed, 28 Nov 2018 20:54:52 GMT
< server: Cowboy
< x-request-id: 2llma8eep65ua5o1to0000o2

{
	"session_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjE1OSwidXNlcl9pZCI6MjgwLCJleHAiOjE1NDM0NTk4ODcsImlhdCI6MTU0MzQ1MjY4NywianRpIjoiMmxsbjQya2kwcnNwOHB2b3FjMDAwMDEyIiwibmJmIjoxNTQzNDUyNjg3fQ.HxdfL0ez9tEK9UXPWaAG598BBW5d7MfPdb4wok5qtG0"
}
```

Curl request:
```
curl -X POST http://localhost:3000/v1/sessions -H "content-type:application/json" -d '{
    "username": "username",
    "raw_password": "password"
}'
```


### List accounts

Request:
```
GET /v1/accounts
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjE1OSwidXNlcl9pZCI6MjgwLCJleHAiOjE1NDM0NTk4ODcsImlhdCI6MTU0MzQ1MjY4NywianRpIjoiMmxsbjQya2kwcnNwOHB2b3FjMDAwMDEyIiwibmJmIjoxNTQzNDUyNjg3fQ.HxdfL0ez9tEK9UXPWaAG598BBW5d7MfPdb4wok5qtG0
```

Response:
```
< HTTP/1.1 200 OK
< cache-control: max-age=0, private, must-revalidate
< content-length: 147
< date: Sat, 01 Dec 2018 16:05:17 GMT
< server: Cowboy
< x-request-id: 2lm424ff08ia7896l80000r1

[
	{
		"id": 290,
		"user_id": 353,
		"iban": "8e571614-fe31-4466-930f-4b8f7e5272a1",
		"balance": "1000.0000",
		"currency": "BRL",
		"inserted_at": "2018-12-01T16:04:19"
	}
]
```

Curl request:
```
curl -X GET http://localhost:3000/v1/accounts -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjE1OSwidXNlcl9pZCI6MjgwLCJleHAiOjE1NDM0NTk4ODcsImlhdCI6MTU0MzQ1MjY4NywianRpIjoiMmxsbjQya2kwcnNwOHB2b3FjMDAwMDEyIiwibmJmIjoxNTQzNDUyNjg3fQ.HxdfL0ez9tEK9UXPWaAG598BBW5d7MfPdb4wok5qtG0" -v
```

### Request withdrawal

Request:
```
POST /v1/withdrawals
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjM0NiwidXNlcl9pZCI6MzUzLCJleHAiOjE1NDM3MDA3MjcsImlhdCI6MTU0MzY5MzUyNywianRpIjoiMmxtNHE1ZGMwbnJxMHB2b3FjMDAwMDcyIiwibmJmIjoxNTQzNjkzNTI3fQ.-mGOu8c6lKShnbfLtp2oFGQwhQhcBVs6nr70a8Fks9E
Content-type: application/json

{
	"amount": 100
}
```

Response:
```
< HTTP/1.1 200 OK
< cache-control: max-age=0, private, must-revalidate
< content-length: 98
< date: Sat, 01 Dec 2018 19:47:00 GMT
< server: Cowboy
< x-request-id: 2lm4qarla36psodf8o000023

{
	"id": 29,
	"account_id": 290,
	"transaction_id": 509,
	"amount": "100",
	"inserted_at": "2018-12-01T19:47:01"
}
```

Curl request:
```
curl -X POST http://localhost:3000/v1/withdrawals -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjE1OSwidXNlcl9pZCI6MjgwLCJleHAiOjE1NDM0NTk4ODcsImlhdCI6MTU0MzQ1MjY4NywianRpIjoiMmxsbjQya2kwcnNwOHB2b3FjMDAwMDEyIiwibmJmIjoxNTQzNDUyNjg3fQ.HxdfL0ez9tEK9UXPWaAG598BBW5d7MfPdb4wok5qtG0" -H "content-type:application/json" -d '{"amount": 100}' -v
```

### Request transfer

Request:
```
POST /v1/transfers HTTP/1.1
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjE1OSwidXNlcl9pZCI6MjgwLCJleHAiOjE1NDM0NTk4ODcsImlhdCI6MTU0MzQ1MjY4NywianRpIjoiMmxsbjQya2kwcnNwOHB2b3FjMDAwMDEyIiwibmJmIjoxNTQzNDUyNjg3fQ.HxdfL0ez9tEK9UXPWaAG598BBW5d7MfPdb4wok5qtG0
Content-type: application/json

{
	"amount": "100.0",
	"destination": "DESTINATION_IBAN"
}
```

Response:
```
< HTTP/1.1 200 OK
< cache-control: max-age=0, private, must-revalidate
< content-length: 185
< date: Mon, 03 Dec 2018 23:09:49 GMT
< server: Cowboy
< x-request-id: 2lmfapebud6ev623ak000044

{
	"id": 19,
	"account_id": 451,
	"transaction_id": 706,
	"amount": "100.5",
	"direction": "out",
	"source": null,
	"destination": "8e571614-fe31-4466-930f-4b8f7e5272a1",
	"inserted_at": "2018-12-03T23:09:49"
}
```

Curl request:
```
curl -X POST http://localhost:3000/v1/accounts -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjE1OSwidXNlcl9pZCI6MjgwLCJleHAiOjE1NDM0NTk4ODcsImlhdCI6MTU0MzQ1MjY4NywianRpIjoiMmxsbjQya2kwcnNwOHB2b3FjMDAwMDEyIiwibmJmIjoxNTQzNDUyNjg3fQ.HxdfL0ez9tEK9UXPWaAG598BBW5d7MfPdb4wok5qtG0" -H "content-type: application/json" -d '{"amount": "100.0", "destination": "DESTINATION_IBAN"}' -v
```

### Generate a report

Request:
```
GET /v1/reports?type=summary&start_date=2018-11-01&end_date=2018-12-25
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjE1OSwidXNlcl9pZCI6MjgwLCJleHAiOjE1NDM0NTk4ODcsImlhdCI6MTU0MzQ1MjY4NywianRpIjoiMmxsbjQya2kwcnNwOHB2b3FjMDAwMDEyIiwibmJmIjoxNTQzNDUyNjg3fQ.HxdfL0ez9tEK9UXPWaAG598BBW5d7MfPdb4wok5qtG0
```

Response:
```
< HTTP/1.1 200 OK
< cache-control: max-age=0, private, must-revalidate
< content-length: 185
< date: Mon, 03 Dec 2018 23:09:49 GMT
< server: Cowboy
< x-request-id: 2lmfapebud6ev623ak000044

{
	"transaction_count": 3,
	"credit_count": 1,
	"debit_count": 2
	"credit_amount": "100.5",
	"debit_amount": "200",
	"start_date": "2018-11-01",
	"end_date": "2018-12-25"
}
```

Curl Request:
```
curl -X GET "http://localhost:3000/v1/reports?type=summary&start_date=2018-12-25&end_date=2018-12-25" -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjE1OSwidXNlcl9pZCI6MjgwLCJleHAiOjE1NDM0NTk4ODcsImlhdCI6MTU0MzQ1MjY4NywianRpIjoiMmxsbjQya2kwcnNwOHB2b3FjMDAwMDEyIiwibmJmIjoxNTQzNDUyNjg3fQ.HxdfL0ez9tEK9UXPWaAG598BBW5d7MfPdb4wok5qtG0"
```