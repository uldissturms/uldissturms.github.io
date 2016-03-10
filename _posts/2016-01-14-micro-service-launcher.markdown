---
layout: post
title: micro service launcher
date:   2016-01-14 17:10:36 +0000
tags: microservices development
---

Most of the time we use microservices to deliver software. Part of the reason we do so is to decouple dependencies between logical services and benefit from having different release cycles. Given service A consumes service B and service B consumes service C, functionality can only be finished when it's been implemented across all services (C, B and A). We prefer to test at different levels and be able to run functional tests for service A without spinning up instances of B and C (read more on testing at different levels [here](http://martinfowler.com/articles/microservice-testing/ "microservices testing")). In this scenario A is being tested against a stub implementation of B and verified that it interacts correctly with the interface provided by B. This gives us enough confidence and enables us to move quick. We can start work on service A implementation before service B is done, given we've agreed on contract between them. That enables us to split service ownership across team and parallelise work.

![](/images/micro-launcher/services-with-stub.svg "services using stub")

![](/images/micro-launcher/services.svg "services fully integrated")

To have confidence that all components work together as expected we have end-to-end integration tests written in Selenium. These tests are slow - take around 5 min to complete and have relatively high chance of failure in CI compared to other types of tests (functional, unit) and it might not be obvious what caused them to fail. At the moment we are mostly .NET Windows shop with few Go services running on Windows with WYSE terminals as dev machines, which brings its opportunities (hence no docker yet). To address these challenges we have introduced [micro-launcher](https://github.com/uldissturms/micro-launcher "micro-launcher") - a microservices launcher application that restores and runs microservices from package repository (TeamCity nuget in our case).

Micro-launcher has enabled us to improve and simplify our deployment pipline, making sure only a good commit results in published artefact and brought CI closer to developers - something we call NoCI. With one command ```./run.sh``` we can spin up all related microservices to run automated end-to-end tests against them. (Take a look at github repository for all the available command line parameters.) This is how our local and build agent setup looks like:

![](/images/micro-launcher/micro-launcher-setup.svg "micro-launcher setup")

We have got rid of CI environment as such - thanks to micro-launcher we can spin up all services on any build-agent which makes scaling much easier - we just need to scale build agents as needed. Or instances of builds - when most of our services can run in a container. Bad commits are no longer blocking our delivery pipeline. We can still release other services while others are broker if we need to. Neat flexibility to have. 

It also bridges the gap between business and development - ability for SME (subject matter expert) to build insurance products locally using latest versions of services with ease. (In our team we use git as a collaboration tool for insurance product definitions.) Micro-launcher abstracts away how artefact is created and eliminates the need of creating one, saving time and knowledge necessary to run services locally. Please take a look at micro-launcher on [github](https://github.com/uldissturms/micro-launcher "micro-launcher") and tell us what you think.
