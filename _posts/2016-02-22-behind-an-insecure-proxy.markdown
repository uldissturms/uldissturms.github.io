---
layout: post
title: behind an insecure proxy
date: 2016-02-22 12:56:00 +000
tags: proxy
---

Its quite often a necessity to proxy all outgoing requests when working for a corporation. Some of the organisations require to proxy https traffic as well as http. In this setup the company ends up as a [man-in-the-middle](https://en.wikipedia.org/wiki/Man-in-the-middle_attack) generating certificates on the fly. In this blog post I've gathered most configurations and tweaks I've applied when working behind and untrusted proxy.

.gemrc
------

{% highlight config %}
http_proxy: http://proxy:port
:ssl_verify_mode: 0
{% endhighlight %}

.npmrc
------

{% highlight config %}
registry=http://registry.npmjs.org/
proxy=http://proxy:port/
https-proxy=http://proxy:port/
strict-ssl=false
{% endhighlight %}

.bowerrc
--------
{% highlight json %}
{
    "proxy": "http://proxy:port",
    "https-proxy": "http://proxy:port",
    "strict-ssl": false
}
{% endhighlight %}

.gitconfig
----------

{% highlight ini %}
[http]
    proxy = http://proxy:port
[https]
    proxy = http://proxy:port
{% endhighlight %}

Gemfile
-------

{% highlight config %}
source "http://rubygems.org"
{% endhighlight %}

env system variables (windows)
-------
{% highlight shell %}
setx /s HTTP_PROXY http://proxy:port/ /m
setx /s HTTPS_PROXY http://proxy:port/ /m
setx /s NO_PROXY .localhost,.domain.local /m
{% endhighlight %}

settings.json (visual studio code)
----------------------------------
{% highlight json %}
{
  "http.proxy": "http://proxy:port/",
  "http.proxyStrictSSL": false
}
{% endhighlight %}

add certificate to keychain (java)
----
{% highlight shell %}
keytool -importcert -file <cert file> -keystore <path to JRE installation>/lib/security/cacerts
{% endhighlight %}
