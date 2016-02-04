---
layout: post
title:  "request rate limiting with haproxy vs nginx using chef solo"
date:   2014-03-03 11:10:36 +0000
categories: request rate limiting haproxy nginx chef solo
---

When consumer base for API or web site grows, the number of potential abusers will eventually increase. Whether on purpose or not it may cause problems for legit consumers by slowing down the performance or even taking down the servers. In case of a web site it’s much easier to predict the absolute maximum requests per second/minute threshold. It wouldn’t make sense for someone to browse the page for more than 2-3 times a second including accidental refresh hits (F5). I’m speaking here about page views, not the concurrent calls to backend (css files, javascript, multiple sections loaded from different paths using jQuery).

This is much harder to do for APIs since they might be proxying the requests - in such scenario it might be worth using X-Forwarded-For header for getting client IP, white-listing legit consumers (this might be even necessary in web site scenario for companies that proxy internet traffic for their employees), delaying or restricting requests that exceed thresholds. Believe it or not all this is fairly easy to set up and comes with no-extra cost in case already using [HAProxy](http://haproxy.1wt.eu/) or [Nginx](http://wiki.nginx.org/Main).

Companies that use HAProxy can be found [here](http://haproxy.1wt.eu/they-use-it.html) and [here](http://lineofthought.com/tools/haproxy).

Companies that use Nginx can be found [here](http://wiki.nginx.org/WhyUseIt) and [here](http://nginx.com/company/), and [here](http://w3techs.com/technologies/cross/web_server/ranking) is how Nginx competes amongst other web servers.

To demonstrate the use of HAProxy I’m using:

- vagrant
- chef cookbooks for haproxy (haproxy-1.5-dev19) (original can be found [here](https://github.com/hw-cookbooks/haproxy)) and nginx

Although haproxy-1.5-dev19 is still in development it’s been used by major companies out there, some of them make their own branches so to make sure it’s inline with their upgrade policy.

The repository can be found at [https://github.com/uldissturms/request-rate-limit](https://github.com/uldissturms/request-rate-limit) where all the infrastructure setup can be seen.

{% highlight bash %}
git clone git@github.com:uldissturms/request-rate-limit.git
git submodule update --init
vagrant up
{% endhighlight %}

In case you don't have omnibus vagrant plugin installed already run command:

{% highlight bash %}
vagrant plugin install vagrant-omnibus
{% endhighlight %}

This will bring up two machines:

*   10.0.0.100 HAProxy
*   10.0.0.101 Nginx

And expose HAProxy 80 port to host port 8081 so that the web site can be accessed through http://localhost:8081/.

Lets start by testing HAProxy.

![image](https://31.media.tumblr.com/3f7ab9ff5a340d7d1d4f4afeeb82e6ff/tumblr_inline_mxr6d8YzdJ1s8znfz.png)

To test the performance of web site we will use [ApacheBench](http://en.wikipedia.org/wiki/ApacheBench).

{% highlight bash %}
sudo apt-get install apache2-utils
ab -n 500000000 -c 10 http://localhost:8081/
{% endhighlight %}

This will install the apache bench and run it against our web server making sure that we have 10 concurrent connections. Lets go ahead and try to open up 11th one.

{% highlight bash %}
telnet 127.0.0.1 8081
{% endhighlight %}

After the changes:

{% highlight bash %}
ab -n 50000000 -c 10 [http://127.0.0.1:8081/](http://127.0.0.1:8081/)
  Benchmarking 127.0.0.1 (be patient)
apr_socket_recv: Connection reset by peer (104)
  Total of 15234 requests completed
{% endhighlight %}

When running in parallel, connection is immediately dropped

{% highlight bash %}
telnet 127.0.0.1 8081
  Trying 127.0.0.1...
  Connected to 127.0.0.1.
  Escape character is '^]'.
  Connection closed by foreign host.
{% endhighlight %}

Settings that prevent from client to hold the connection open for too long can be applied

{% highlight bash %}
timeout http-request 3s # client to send the whole HTTP request
{% endhighlight %}

When 3 seconds are passed we notice:

{% highlight bash %}
telnet 127.0.0.1 8081
  Trying 127.0.0.1...
  Connected to 127.0.0.1.
  Escape character is '^]'.
  HTTP/1.0 408 Request Time-out
  Connection: close
  <html><body><h1>408 Request Time-out</h1>
  Your browser didn't send a complete request in time.
  </body></html>
  Connection closed by foreign host.
{% endhighlight %}

  Bursts can be used instead of dropping the request so that consumer experience slowdown instead of service failure. While this is a great option to consider it might also hide problems - when legit consumers aren’t familiar with busts set up then API misuse will not result in HTTP error. Monitoring and a close look should be applied.

  Burst can be set up as in this gist: [https://gist.github.com/dsuch/5872245](https://gist.github.com/dsuch/5872245)

  White-listing can be applied using /usr/local/etc/whitelist.lst file.

  Using Nginx for request rate limiting. This is achieved using [limit request module](http://wiki.nginx.org/HttpLimitReqModule).

{% highlight bash %}
  curl 10 10.0.0.101/limit -w "Time: %{time_total} "
  lt;html><head><title>Welcome to nginx!</title></head><body bgcolor="white" text="black"><center><h1>Welcome to nginx!</h1></center></body></html>Time: 0.001
  ab -n 10 10.0.0.101/limit
Percentage of the requests served within a certain time (ms)
  50%  500
  66%  501
  75%  501
  80%  501
  90%  501
  95%  501
  98%  501
  99%  501
  100% 501 (longest request)
{% endhighlight %}

  White-listing can be achieved with [geo module](http://wiki.nginx.org/HttpGeoModule). Let’s white-list localhost and execute request from Nginx server itself.

{% highlight bash %}
geo $nolimit {
    default 0;
    127.0.0.1/32 1; # my network
  }
{% endhighlight %}

{% highlight bash %}
vagrant@web:~$ ab -n 10 127.0.0.1/limit-local
Percentage of the requests served within a certain time (ms)
  50% 0
  66% 0
  75% 0
  80% 0
  90% 0
  95% 0
  98% 0
  99% 0
100% 0 (longest request)
{% endhighlight %}

  You can specify the nodelay to drop request instead of throttling.

  Things I liked about HAProxy:

- endless options to extend the rules for request limiting - even HTTP status codes returned from web server can be taken into account - lets say we want to restrict users that scrape our service by violently incrementing identifiers and fetching off content - these will probably result in loads of 404’s.
- build-in user interface for monitoring server health
- the top most element in most architectures already
- goes above HTTP, load balance any TCP
- used by stackoverflow, twitter

  Things I liked about Nginx:

- available through package manager
- easy to get started
- one of the most popular web servers
- used by netflix, github and facebook

  Thinks that would be interesting to try:

- load logs from haproxy using [logstash](http://logstash.net/) into [elasticsearch](http://www.elasticsearch.org/) and see how excessive traffic gets cut of using [kibana](http://www.elasticsearch.org/overview/kibana/)
- set up heartbeat for HAProxy server, introduce second web server, basically reduce SPoFs in all the stack
- push concurrent user count to maximum

  References:

- [http://blog.exceliance.fr/2012/02/27/use-a-load-balancer-as-a-first-row-of-defense-against-ddos/](http://blog.exceliance.fr/2012/02/27/use-a-load-balancer-as-a-first-row-of-defense-against-ddos/)
- [http://blog.serverfault.com/2010/08/26/1016491873/](http://blog.serverfault.com/2010/08/26/1016491873/)
- [http://rohitishere1.github.io/2013/06/27/rate-limit-per-ip—-nginx/](http://rohitishere1.github.io/2013/06/27/rate-limit-per-ip---nginx/)
