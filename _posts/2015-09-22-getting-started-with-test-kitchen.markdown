---
layout: post
title: "getting started with test-kitchen"
categories: test-kitchen chef berkshelf infrastructure-code
---

<iframe src="//www.slideshare.net/slideshow/embed_code/key/yOFK2KpzSQ6nXf" width="425" height="355" frameborder="0" marginwidth="0" marginheight="0" scrolling="no" style="border:1px solid #CCC; border-width:1px; margin-bottom:5px; max-width: 100%;"> </iframe>

<iframe width="420" height="315" src="https://www.youtube.com/embed/snZeEDKo9Pc" frameborder="0"></iframe>

One of the easiest ways to get started is by using [Berkshelf](http://berkshelf.com/) but here is also where most of the problems come in - so I decided to write a blog post on it and do a presentation on my findings.

It might be easy to get berkshelf via [chef-dk](https://downloads.chef.io/chef-dk/) but that’s not much fun for few reasons: not a clear understanding how bits fit together, locked into a concrete version of berkshelf - things can start to break if updated on their own, not the latest, bleeding edge version by definition - which is not much fun.

Here it goes. To start we need latest stable ruby version (2.2.2 at the time of writing).
{% highlight bash %}
rvm install 2.2.2 # install latest stable ruby version at the time of writing
rvm use 2.2.2 # using installed ruby version
gem install berkshelf # install berkshelf
{% endhighlight %}

Now that we have berkshelf installed lets install virtualbox, vagrant and test-kitchen so that we can start writing infrastucture code.

{% highlight bash %}
apt-get install virtualbox -y # install oracle virtual box
wget [https://bit.ly/vagrant172](https://bit.ly/vagrant172)
dpkg -i vagrant172 # install vagrant for automating vboxes
gem install test-kitchen # installs test-kitchen gem so that berks puts it into Gemfile
{% endhighlight %}

Lets scaffold our cookbook called _hello-infra_

{% highlight bash %}
berks cookbook hello-infra # generate infrastructure as code layout
{% endhighlight %}

and pull in dependecies.

{% highlight bash %}
cd hello-infra
gem install bundler # install bundler gem
bundle install # install test-kitchen from Gemfile
{% endhighlight %}

Lets change defaults to use chef-zero instead of chef-solo and use debian instead of ubuntu. Vagrant will work faster with debian than ubuntu since it’s server distro and less stuff comes with it pre-installed.

{% highlight bash %}
sed -i 's/chef_solo/chef_zero/g' .kitchen.yml # use chef zero instead of solo
sed -i 's/ubuntu-12.04/debian-7.8/g' .kitchen.yml # use debian instead of ubuntu
sed -i '10d' .kitchen.yml # remove centos from platfor list to begin with
{% endhighlight %}

Test-kitchen comes with handy commands to see if we got the configuration right.

{% highlight bash %}
kitchen list # outputs list of boxes configured
kitchen diagnose # outputs the list of box properties
{% endhighlight %}

Lets create the box, converge and verify to make sure we have everything set up correctly and good to start writing infrastructure code.

{% highlight bash %}
kitchen create # creates a new virtual box > 8 min in case it has to download box from internet
kitchen converge # converges instance with recipe
kitchen verify # verify tests after box's converged, first time around will pull down and install chef
{% endhighlight %}

The initial .kitchen.yml file should look like this:

{% highlight bash %}
provisioner:
name: chef_zero
platforms:
- name: debian-7.8
suites:
name: default
run_list: [‘hello-infra’]
{% endhighlight %}

To demonstrate test-kitchen lets build a simple nodejs app powered by supervisor and reverse proxied by nginx iteratively using TDD cycle. Lets create our first failing infrastructure test.

{% highlight ruby %}
describe command('node -v') do
  its(:exit_status) { should eq 0 }
end
{% endhighlight %}

And run tests.

{% highlight bash %}
kitchen verify # should output failing test
{% endhighlight %}

To make the test pass we need to make changes to these files.

{% highlight bash %}
tail -1 metadata.rb
depends 'nodejs'

tail -1 Bershelf 
cookbook 'nodejs'

cat recipes/default.rb
include_recipe 'nodejs'
{% endhighlight %}

Now after running _kitchen converge_ the tests pass and nodejs is installed on server. We repeat these TDD steps for creating a simple hello-world nodejs app, installing nginx, and configuring supervisor service. The resulting file tree structure looks like this:

{% highlight bash %}
.
├── attributes
├── Berksfile
├── Berksfile.lock
├── CHANGELOG.md
├── chefignore
├── files
│   └── default
│       ├── default
│       └── simple.js
├── Gemfile
├── Gemfile.lock
├── libraries
├── LICENSE
├── metadata.rb
├── providers
├── README.md
├── recipes
│   └── default.rb
├── resources
├── setup.sh
├── spec
│   └── default_spec.rb
├── teardown.sh
├── templates
│   └── default
├── test
│   └── integration
│       └── default
│           ├── bats
│           │   └── autorestart.bats
│           ├── rspec
│           │   └── hello-world_spec.rb
│           └── serverspec
│               └── webserver_spec.rb
├── Thorfile
└── Vagrantfile
{% endhighlight %}

The contents of the test files are:

{% highlight ruby %}
cat test/integration/default/serverspec/webserver_spec.rb
require 'serverspec'
set :backend, :exec

describe command('node -v') do
  its(:exit_status) { should eq 0 }
end

describe port(3000) do
  it { should be_listening }
end

describe port(80) do
  it { should be_listening }
end

#cat test/integration/default/bats/autorestart.bats
#!/usr/bin/env bats

@test 'should automaticaly restart hello world app' {
  run pkill node
    sleep 5
    command curl localhost:3000
}

#cat test/integration/default/rspec/hello_world_spec.rb
require 'net/http'

describe 'website' do
  it 'should send greatings' do
    endpoint = Net::HTTP.new('localhost', 80)
    response = endpoint.get('/')
    expect(response.body).to match 'Hello World'
  end
end
{% endhighlight %}

The contents of files are:

{% highlight bash %}
cat recipe/default.rb
include_recipe 'nodejs'
include_recipe 'supervisor'

cookbook_file 'simple.js' do
  path 'srv/simple.js'
end

package 'nginx'

cookbook_file 'default' do
  path '/etc/nginx/sites-available/default'
  notifies :restart, 'service[nginx]'
end

service 'nginx' do
  action [:start]
end

supervisor_service 'hello-world' do
  command 'node /srv/simple.js'
  action :enable
  autostart true
  autorestart true
end

cat files/default/simple.js
var http = require('http');
http.createServer(function(req, res) {
    res.writeHead(200);
    res.end('Hello World');
    }).listen(3000);

cat files/default/default
server {
  location / {
    proxy_pass http://127.0.0.1:3000;
  }
}
{% endhighlight %}

To demonstrate chefspec I've also added spec/default_spec.rb for recipe.

{% highlight ruby %}
require 'chefspec'
require 'chefspec/berkshelf'

describe 'test::default' do
  let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

  before do
    stub_command("netstat -l | grep :3000").and_return(false)
  end

  it 'installs nodejs recipe' do
    expect(chef_run).to include_recipe('nodejs')
  end

  it 'installs nginx package' do
    expect(chef_run).to install_package('nginx')
  end

  it 'enables nginx' do
    expect(chef_run).to start_service('nginx')
  end
end
{% endhighlight %}

Chefspec can come in handy when testing combinations of data bags and commands running on multiple platforms, however I would only use them if something's hard or takes very long time to test using integration tests. Integration tests give the most confidence and aren't tied to implementation - verifies that implementation fulfils the contract. This makes implemtation easy to change without breaking tests.

All code commits for this example can be found on [github](https://github.com/uldissturms/test) presentation on [slidshare](http://www.slideshare.net/UldisSturms/testkitchen-keynote) and screencast on [youtube](https://www.youtube.com/watch?v=snZeEDKo9Pc).
