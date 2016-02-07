---
layout: post
title:  "docker - from nodejs to spark using vagrant"
date:   2014-02-01 12:10:10 +0000
tags: docker nodejs spark vagrant
---

[Docker](https://www.docker.io/) is a shipping container system for code. Developer: Build Once, Run Anywhere. Operator: Configure Once, Run Anything. Integration in [Chef](http://www.opscode.com/chef), [Puppet](http://puppetlabs.com/), [Vagrant](http://www.vagrantup.com/) and [OpenStack](http://www.openstack.org/).
About [presentation](http://www.slideshare.net/dotCloud/why-docker "why docker") will get you up to speed about docker real quick.

Traditionally developers take care of code, operations take care of infrastructure. Containers are isolated but share OS and, where appropriate, bins/libraries. [Union file system](http://en.wikipedia.org/wiki/UnionFS) allows us to save the diffs between container A and A'.
Let's start by creating vagrant box to host docker (more instructions on vagrant [here](http://docs.vagrantup.com/v2)). Docker's git repository already contains everything to get you up and running in not time. Just run:

{% highlight bash %}
git clone https://github.com/dotcloud/docker.git
cd docker
vagrant up
vagrant ssh
sudo docker
{% endhighlight %}

Detailed instructions can be found [here](http://docs.docker.io/en/latest/installation/vagrant "how to install vagrant"). To get started with docker you must get guest base image, in our case ubuntu.

{% highlight bash %}
sudo docker pull ubuntu
sudo docker run -i -t ubuntu /bin/bash
{% endhighlight %}

You are in your container as root. Containers don't need to boot up or shut down the OS like VMs do. So anything to worry about is disk space really. The neat thing about docker images is the ability to make changes and commit them. Lets create image for nodeJS development. First we define Dockerfile (can be found on [github](https://github.com/uldissturms/dockerfiles/tree/master/nodejs "nodejs repository @ github")):

{% highlight bash %}
# runable base
FROM base
MAINTAINER Uldis Sturms

# REPOS
RUN apt-get -y update
RUN apt-get install -y -q software-properties-common
RUN add-apt-repository -y "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) universe"
RUN add-apt-repository -y ppa:chris-lea/node.js
RUN apt-get -y update

# EDITORS
RUN apt-get install -y -q vim nano

# TOOLS
RUN apt-get install -y -q curl

## NODE
RUN apt-get install -y -q nodejs

## APP
ADD app /root
RUN cd /root && npm install

## CONFIG
ENV RUNNABLE_USER_DIR /root

# Startup nodejs application
EXPOSE 8080
CMD ["node", "/root/server.js"]
{% endhighlight %}

Then we need to execute:

{% highlight bash %}
sudo docker build -t uldissturms/nodejs . # replace uldissturms with your username
sudo docker run -d uldissturms/nodejs # d for daemon
{% endhighlight %}

To leave nodeJS app running we must start container as daemon. To connect to container once it is running we can by grabbing the identifier of container from list of active containers and then attaching to it:

{% highlight bash %}
sudo docker ps -a # a for all
sudo docker attach 66236590f727
{% endhighlight %}
Now we can connect to the nodeJS app and see respose:

{% highlight bash %}
curl http://localhost:49161/ # will output response from nodeJS.
{% endhighlight %}

Let's assume we would like full-blown development nodeJS container. We can go and install all tools, services, etc.

{% highlight bash %}
apt-get install git
apt-get install wget
{% endhighlight %}

And then commit the changes made to the container:

{% highlight bash %}
sudo docker commit 66236590f727 uldissturms/nodejs-fullblown
{% endhighlight %}

Now we can use this newly created image as base for new containers. You can use sudo docker login command to login to online image repository and sudo docker push to upload it.

{% highlight bash %}
sudo docker push uldissturms/nodejs
{% endhighlight %}

And image is now available at [public docker image repository](https://index.docker.io/u/uldissturms/nodejs/ "my nodeJS docker image in public repository"). Hosting private repositories is also available and comes in handy in enterprise scenarios. Containers can be deleted using command:

{% highlight bash %}
docker rm
{% endhighlight %}

Let's see how docker would fit into more complicated server scenario - [Spark](http://spark.incubator.apache.org "Spark").

> Apache Spark is an open source cluster computing system that aims to make data analytics fast — both fast to run and fast to write. To run programs faster, Spark offers a general execution model that can optimize arbitrary operator graphs, and supports in-memory computing, which lets it query data faster than disk-based engines like Hadoop.

To get Spark up and running:

{% highlight bash %}
git clone https://github.com/uldissturms/dockerfiles # updated scala download path
cd dockerfiles/spark
sudo docker build -t=spark
{% endhighlight %}

I managed to get spark working by commenting out running hadoop related stuff from Dockerfile as it reported hadoop-1.1.2-bin.tar.gz not to be valid archive and since I had no intention to use HDFS I dumped it (updated version can be found on [github](https://github.com/uldissturms/dockerfiles "dockerfiles on github")):

{% highlight bash %}
#RUN tar -zxvf hadoop-1.1.2-bin.tar.gz -C /opt/
{% endhighlight %}

Things I liked about Docker:

 1.  In case of build failure it continues where it stopped – previously downloaded packages are still there.
 2.  Convenient way of setting up infrastructure – much easier and quicker for developer to get up and running than puppet, chef, cfengine.
 3.  Neat way of pulling and committing / pushing images.
 4.  No time-consuming restarts oppose to VMs.
 5.  Don't have to think about RAM when creating containers – it will use host's OS.
 6.  Potentially very easy to move between cloud provides – as soon as they support docker ([dotcloud](https://www.dotcloud.com "dotcloud")).

 Thinks that would be interesting to try:

 1.  Deploy to live cloud (AWS possibly).
 2.  Explore OpenStack and docker integration ([https://github.com/dotcloud/openstack-docker](https://github.com/dotcloud/openstack-docker "openstack and docker")).
 3.  Set up and deploy to private could (maybe [Rackspace private cloud](http://www.rackspace.com/cloud/private/script/ "rackspace private cloud") that comes with chef [cook _books_](http://www.rackspace.com/knowledge_center/article/installing-openstack-with-rackspace-private-cloud-tools "rackspace private cloud cook books").

Please note that docker is still under heavy development and should not be used in production. References:

- [https://www.docker.io](https://www.docker.io)
- [https://www.docker.io/the-whole-story](https://www.docker.io/the-whole-story)
- [https://github.com/dotcloud/docker](https://github.com/dotcloud/docker)
- [http://blog.dotcloud.com](http://blog.dotcloud.com)
- [http://docs.docker.io/en/latest/installation/vagrant](http://docs.docker.io/en/latest/installation/vagrant)
- [http://coreos.com](http://coreos.com)
- [http://coreos.com/docs/vagrant](http://coreos.com/docs/vagrant)
- [https://index.docker.io/u/fkautz/hadoop-hw](https://index.docker.io/u/fkautz/hadoop-hw)
- [http://spark.incubator.apache.org](http://spark.incubator.apache.org)
- [https://github.com/thoughtpolice/dockerfiles/tree/master/spark](https://github.com/thoughtpolice/dockerfiles/tree/master/spark)
- [http://robknight.org.uk/blog/2013/05/drupal-on-docker](http://robknight.org.uk/blog/2013/05/drupal-on-docker)
- [https://github.com/thoughtpolice/dockerfiles](https://github.com/thoughtpolice/dockerfiles)
- [https://github.com/fkautz/docker-hadoop-hw](https://github.com/fkautz/docker-hadoop-hw)
