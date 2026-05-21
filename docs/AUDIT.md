#### General

##### Before we start, let's check that we have the necessary tools to perform the tests. You should make sure that VirtualBox (or equivalent software), Vagrant, and Postman are installed. If they are not, please install them.

#### Documentation

##### Take a look at the `README.md` file provided by the learner.

###### Does the file include enough context and details to understand and run the project?

###### Does the OpenAPI documentation accurately reflect the implemented behavior of the API Gateway?

#### Virtual Machines

##### In the directory of the project run `vagrant up` and then run `vagrant status`.

###### Can you confirm that the three VMs (`gateway-vm`, `inventory-vm` and `billing-vm`) are up and running?

##### Locate the `.env` file in the root of the project, run `cat .env`:

###### Does the output contain all the necessary credentials required for the microservices to run properly?

###### Is the source code free from any credential that could have been added to the `.env` file?

###### Are environment variables correctly injected into the VMs and used by the services?

###### Is the learner able to explain the commands included in the `/scripts` directory and why they are used?

#### The API Gateway

##### The API Gateway is responsible for routing requests to the appropriate service using the correct protocol.

###### Does the API Gateway correctly route requests to the Inventory API using HTTP?

###### Does the API Gateway correctly route requests to the Billing API using RabbitMQ?

###### Does the API Gateway return the exact response received from the Inventory API without modification?

###### Is the Billing endpoint able to enqueue messages even when the Billing API is not running?

#### Inventory API

##### Open Postman and make a `POST` request to `http://[GATEWAY_IP]:[GATEWAY_PORT]/api/movies/` address with the following body as `Content-Type: application/json`:

```json
{
  "title": "A new movie",
  "description": "Very short description"
}
```

###### Can you confirm the response was the success code `201`?

###### Is the created movie persisted in the PostgreSQL database?

##### In Postman make a `GET` request to `http://[GATEWAY_IP]:[GATEWAY_PORT]/api/movies/` address.

###### Can you confirm the response was success code `200` and the body of the response is in `json` with the information of the last added movie?

###### Does the API support filtering movies by title using query parameters?

##### Ask to locate the Postman configuration file in the files committed by the learner and import this file in Postman.

###### Can you confirm that the imported endpoints include all methods supported by both APIs and that all of those methods are returning the expected response? (use the subject as a reference)

#### PostgreSQL database for Inventory

##### Run `vagrant ssh inventory-vm` to enter into the VM, then run `sudo -i -u postgres`, then `psql` and once in the database enter `\l`.

###### Can you confirm the `movies` database is listed?

##### Still in `psql` run `\c movies_db` and then `TABLE movies;`.

###### Can you confirm that the entries are present and reflect the calls you made when checking the endpoints for this API?

#### Billing API

##### Open Postman and make a `POST` request to `http://[GATEWAY_IP]:[GATEWAY_PORT]/api/billing/` address with the following body as `Content-Type: application/json`:

```json
{
  "user_id": "20",
  "number_of_items": "99",
  "total_amount": "250"
}
```

###### Can you confirm the response was success code `200`?

##### Run `vagrant ssh billing-vm` to interact with the proper VM. Run `sudo pm2 stop billing_app` and then `sudo pm2 list`.

###### Can you confirm the `billing_app` API was correctly stopped?

##### Open Postman and make a `POST` request to `http://[GATEWAY_IP]:[GATEWAY_PORT]/api/billing/` address with the following body as `Content-Type: application/json`:

```json
{
  "user_id": "22",
  "number_of_items": "10",
  "total_amount": "50"
}
```

###### Can you confirm the response was success code `200` even if the `billing_app` is not running?

###### Does the API Gateway enqueue the billing message instead of directly writing to the database?

#### PostgreSQL database for Billing

##### Run `vagrant ssh billing-vm` to enter into the VM, then run `sudo -i -u postgres`, then `psql` and once in the database enter `\l`.

###### Can you confirm the `orders` database is listed?

##### Still in `psql` run `\c orders_db` and then `TABLE orders;`.

###### Can you confirm the order with `user_id = 20` is listed properly?

###### Can you confirm the order with `user_id = 22` is NOT listed?

###### Does the database schema match the specification described in the README?

#### Check the resilience of messaging queue

###### Is RabbitMQ installed and running on the billing-vm, with the billing_queue properly created and the Billing API correctly subscribed to it?

###### Are messages persisted in RabbitMQ when the Billing API is unavailable?

##### Run `sudo pm2 start billing_app` to start again the Billing API. At this point enter again in the database following the same instructions as in the previous section.

###### Can you confirm the order with `user_id = 22` is now listed properly?

###### Does the Billing API acknowledge messages after successful processing?

#### Bonus

###### + Did the learner implement additional validation or error handling?

###### + Did the learner add monitoring, logging, or security improvements?

###### + Did the learner clearly justify architectural and design choices during the audit?