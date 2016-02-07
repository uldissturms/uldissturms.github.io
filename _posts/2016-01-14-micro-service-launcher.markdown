---
layout: post
title: micro service launcher
date:   2016-01-14 17:10:36 +0000
tags: microservices development
---

Most of the time at Markel Digital we use microservices to deliver software. Part of the reason we do so is to decouple dependencies between logical services and benefit from having different release cycles. Given service A consumes service B and service B consumes service C, functionality can only be finished when it's been implemented across all services (C, B and A). We prefer to test at different levels and be able to run functional tests for service A without spinning up instances of B and C (read more on testing at different levels [here](http://martinfowler.com/articles/microservice-testing/ "microservices testing")). In this scenario A is being tested against a stub implementation of B and verified that it interacts correctly with the interface provided by B. This gives us enough confidence and enables us to move quick. We can start work on service A implementation before service B is done, given we've agreed on contract between them. That enables us to split service ownership across team and parallelise work.

![](/images/micro-launcher/services-with-stub.svg "services using stub")

![](/images/micro-launcher/services.svg "services fully integrated")

Read more on our markel digital blog [http://www.markeldigital.io/2016/01/14/micro-service-launcher](http://www.markeldigital.io/2016/01/14/micro-service-launcher).
