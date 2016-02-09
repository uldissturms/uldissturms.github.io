---
layout: post
title: configure elasticsearch error watcher to send slack notifications
date: 2016-02-08 12:06:22 +000
tags: monitoring elasticsearch slack
---

It is common to use ELK stack (elasticsearch, logstash, kibana) for logging. Exposing logs to everyone on team and wider organisation increases the visibility into system running in production. One can see what code paths are actually executed in production. It also makes triaging production incidents easier. What about being more proactive... Get slack notifications on errors as they happen.

elasticsearch watchers
---------------------

One of elasticsearch plugins is [Watcher](https://www.elastic.co/guide/en/watcher/current/introduction.html). It enables alerts and notifications based on data in elasticsearch indexes.

{% highlight bash %}
bin/plugin install license
bin/plugin install watcher
{% endhighlight %}

Adding a watcher is a matter of a PUT request.

{% highlight bash %}
curl -XPUT 'http://localhost:9200/_watcher/watch/log_error_watch' -d "@watcher.json"
{% endhighlight %}

slack notification template
---------------------------

This is a slack notification template that will get you going.
{% highlight json %}
{% raw %}
{
    "trigger": {
        "schedule": {
            "interval": "10s"
        }
    },
    "input": {
        "search": {
            "request": {
                "indices": [
                    "logstash*"
                ],
                "body": {
                    "query": {
                        "filtered": {
                            "query": {
                                "match": {
                                    "level": "ERROR"
                                }
                            },
                            "filter": {
                                "range": {
                                    "@timestamp": {
                                        "from": "{{ctx.trigger.scheduled_time}}||-5m",
                                        "to": "{{ctx.trigger.triggered_time}}"
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    },
    "condition": {
        "compare": {
            "ctx.payload.hits.total": {
                "gt": 0
            }
        }
    },
    "actions": {
        "send_trigger": {
            "webhook": {
                "method": "POST",
                "scheme": "https",
                "port": 443,
                "host": "hooks.slack.com",
                "path": "/services/XXXXXX/XXXXX/XXXXXXXX",
                "body": "{ \"text\": \"encountered {{ctx.payload.hits.total}} errors in past 5 minutes \"}",
                "headers": {
                    "Content-type": "application/json"
                }
            }
        }
    }
}
{% endraw %}
{% endhighlight %}
