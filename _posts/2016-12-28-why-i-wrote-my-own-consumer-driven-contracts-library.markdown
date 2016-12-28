---
layout: post
title: why i worte my own consumer driven contracts library
date: 2016-12-28 22:50:00 +000
tags: consumer driven contracts my own
---

> [https://npmjs.com/cdc](https://npmjs.com/cdc) - give it a go and let me know what you think

## motivation
- ambition to develop over 100 new microservices during the course of next year
- confidence that microservices work when integrated with others
- testing at different levels and maintaining a resonable testing strategy ([test pyramid](http://martinfowler.com/bliki/TestPyramid.html))
- should be easy to contribute - heavy investment in JS (nodejs)
- no code generation, please
- self-documenting contracts
- functional programming
- ability to work in an environment with limited connectivity would be nice

## approach
- specify request and response objects and schemas as part of the same contract object using JS
- match on method, url, headers and body
- use [joi](https://npmjs.com/joi) validation library to assert schema compliance to:
  - generate response mocks for consumer
  - verify contract expectations against provider responses
- use contracts to generate [tape](https://npmjs.com/tape) provider tests

![](/images/cdc/consumer.png)
![](/images/cdc/provider.png)

## existing libraries*
- [consumer-contracts](https://www.npmjs.com/consumer-contracts)
  - *pros*: javascript, joi schemas - something we already use with [hapijs](https://npmjs.com/hapi), small codebase with good test coverage
  - *cons*: no mock server, no checks on method, response headers, or status code, object oriented, state manipulations
- [mockingjay-server](https://github.com/quii/mockingjay-server)
  - *pros*: admin GUI, requests endpoint to trace received requests, tiny go docker image, very fast
  - *cons*: golang, a lot of code for what was needed, not flexible enough to support advanced schema checks
- [pact](https://github.com/realestate-com-au/pact)
  - *pros*: one of the first cdc libraries, a lot of thought has gone into it and supports many scenarios, great documentation and reasoning, pact spefication available for multiple languages
  - *cons*: ruby, code generation (something simple and close to HTTP preferred)
- [pacto](https://github.com/thoughtworks/pacto)
  - no loger maintained

\* at the time of writing
