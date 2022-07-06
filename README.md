This site or product includes IP2Location LITE data available from <a href="https://lite.ip2location.com">https://lite.ip2location.com</a>.

# EXAMPLE environment for express.js
[![Build Status](https://app.travis-ci.com/mbaglieri/low-code-engine.svg?branch=master)](https://app.travis-ci.com/mbaglieri/low-code-engine)

This project was created for have a init project with all the configuration for ...
using [Node.js](https://nodejs.org/en/) and [Express](https://expressjs.com/pt-br/).

Tools Used:
* [NodeJs](https://nodejs.org/en/)
* [Express](https://expressjs.com/pt-br/)
* [knex](http://knexjs.org/)
* [mysql2](https://www.npmjs.com/package/mysql2)
* [dotenv](https://www.npmjs.com/package/dotenv)
* [cors](https://www.npmjs.com/package/cors)
* [joi](https://www.npmjs.com/package/@hapi/joi)
* [date-fns](https://www.npmjs.com/package/date-fns)
* [date-fns-tz](https://www.npmjs.com/package/date-fns-tz)
* [helmet](https://www.npmjs.com/package/helmet)
* [hide-powered-by](https://www.npmjs.com/package/hide-powered-by)
* [http-status-codes](https://www.npmjs.com/package/http-status-codes)
* [morgan](https://www.npmjs.com/package/morgan)
* [swagger-jsdoc](https://www.npmjs.com/package/swagger-jsdoc)
* [swagger-ui-express](https://www.npmjs.com/package/swagger-ui-express)
* [uuid](https://www.npmjs.com/package/uuid)
* [winston](https://www.npmjs.com/package/winston)
* [winston-daily-rotate-file](https://www.npmjs.com/package/winston-daily-rotate-file)
* [x-xss-protection](https://www.npmjs.com/package/x-xss-protection)
* [yamljs](https://www.npmjs.com/package/yamljs)
* [ioredis](https://www.npmjs.com/package/ioredis)
* [ramda](https://www.npmjs.com/package/ramda)
* [i18n](https://www.npmjs.com/package/i18n)
* [socket.io](https://socket.io/)
* [nodemon](https://nodemon.io/)
* [prom-client](https://www.npmjs.com/package/prom-client)

<!-- ## Screenshots
App view:
![App UI](/app.png) -->

## Development

### Setup

#### 1) Installation of dependencies
``` sh
npm i
```
Note: It is necessary that [NodeJs](https://nodejs.org/en/) is already installed on your machine

#### 2) Base date
``` sh
docker-compose up -d
```
Note: I left a file of [DockerCompose](https://docs.docker.com/compose/) so that the use of this
design is simpler
brew cask install docker

sudo curl -L "https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose


#### 3) Setup Data base and Initial Data
``` sh
npm run setup:up
```

#### 4) Start Project
``` sh
npm run dev

# check the url http://localhost:3000 or http://localhost:${customPort}
```

#### 5) Usage
Make 2 requests on the route http://localhost:3000 or http://localhost:${customPort} and check your
execution console

## EXTRA
#### 1) Database
Before starting which environment it is `LOCAL | DOCKERIZADO` must be created a database in [mysql](https://www.mysql.com/) one for the
DEV environment. For more information check `./src/env.js` for environment variables check `.env.example`

Database Name | User Database | Password Database
--------------|---------------|------------------
finance | `root` | admin

#### 2) Documentation
The project has a documentation of API routes, just navigate to `http://localhost:3000/api-doc`, I also left a localized file
`./docker-compose.prod.yml` to make testing project easier.

#### 3) Create new migrate
run the command
```sh
set NAME=test && npm run migrate:create
```

#### 4) Email Config
I'll be leaving the link to [appMenosSeguro](https://myaccount.google.com/u/2/lesssecureapps) that needs to be
enabled to use the standard email sending service. To use email services with OAuth2 follow
the next steps  check the pdf in doc to follow the steps.
https://console.cloud.google.com/home/dashboard?project=
https://developers.google.com/oauthplayground/

#### 5) Postman Collection
I will be leaving a collection of the tool [Postman](https://www.postman.com/) to facilitate manual testing. 😁😁😁

## Contact
Developed by: [Matias Baglieri](https://github.com/mbaglieri) 🤓🤓🤓

* Email: [matiasbaglieri@gmail.com](mailto:matiasbaglieri@gmail.com)
* Github: [github.com/mbaglieri](https://github.com/mbaglieri)
* Linkedin: [linkedin.com/in/matiasbaglieri/](https://www.linkedin.com/in/matiasbaglieri/)

### Project Settings Customization
Check [Settings and References](https://expressjs.com/).

---

## License
>You can check out the full license [here](https://github.com/mbaglieri/david_bknd/blob/master/LICENCE.md)

This project is licensed under the terms of the **PRIVATE** license.