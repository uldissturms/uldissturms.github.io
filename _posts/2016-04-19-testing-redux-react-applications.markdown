---
layout: post
title: testing redux react applications
date: 2016-04-19 20:00:00 +000
tags: testing redux react
---

For a tipical redux react application there are three levels at which it makes sense to test:

- components
- reducers
- end-to-end (ui integration tests)

In this blog post I will cover __component__ and __reducer__ tests since end-to-end tests are normally written in an implementation agnostic way (e.g., selenium, webdriver) and are covered well by others already.

setting up environment
-----------------------

{% highlight bash %}
npm install react react-dom redux --save
npm install mocha expect expect-jsx \
            babel-register babel-preset-es2015 \
            babel-preset-react react-addons-test-utils --save-dev
echo '{ "presets": ["react", "es2015"] }' > .babelrc
{% endhighlight %}

{% highlight base %}
src
├── components
│   ├── hello.jsx
│   └── hello.test.js
└── state
    ├── namesReducer.js
    └── namesReducer.test.js
{% endhighlight %}
component
-------------------

test properties & DOM
-------------------------
React renders virtual DOM therefore its easy to assert on properties or the DOM itself. __expect-jsx__ is a handy expect extension that gives neat JSX diffs.

### hello.test.js
{% highlight js %}
import React from 'react';
import TestUtils from 'react-addons-test-utils';
import expect from 'expect';
import expectJSX from 'expect-jsx';
import Hello from './hello.jsx';

expect.extend(expectJSX);

const renderHello = name => {
  const renderer = TestUtils.createRenderer();
  renderer.render(<Hello name={name}/>);
  return renderer.getRenderOutput();
}

const getChildrenByClass = (element, name) => {
  return element.props.children.filter((value) => {
    return value.props && value.props.class === name;
  })[0];
}

describe('hello component', () => {
  it('renders name', () => {
    const output = renderHello('Steve');
    const name = getChildrenByClass(output, 'test-name');
    expect(name.props.children).toEqual('Steve');
  });
  it('renders component', () => {
    const output = renderHello('Steve');
    const expected = <div>Hello, <b class="test-name">Steve</b></div>;
    expect(output).toEqualJSX(expected);
  });
});
{% endhighlight %}

### hello.jsx
{% highlight js %}
import React from 'react';

const Hello = ({name}) => {
  return (
    <div>
      Hello, <b class='test-name'>{name}</b>
    </div>
  );
};

export default Hello;
{% endhighlight %}

reducer
-------

Since reducers are pure functions (have no side effects and only rely on parameter values) they are easy to test.

### namesReducer.test.js
{% highlight js %}
import expect from 'expect';
import namesReducer from './namesReducer';

const greet = name => {
  return { type: 'GREET', payload: { name: name }};
};

describe('names reducer', () => {
  it('greets', () => {
    const state = namesReducer({ names: [] }, greet('Steve'));
    expect(state).toEqual({ names: ['Steve']});
  });
  it('no greetings to Stranger', () => {
    const state = namesReducer({ names: [] }, greet('Stranger'));
    expect(state).toEqual({ names: []});
  });
});
{% endhighlight %}


### namesReducer.js
{% highlight js %}
const shouldGreet = name => {
  return name !== 'Stranger';
};

const namesReducer = (state = { names: [] },  action) => {
  if (action.type === 'GREET' && shouldGreet(action.payload.name)) {
    return { names: [...state.names, action.payload.name] };
  }
  return state;
};

export default namesReducer;
{% endhighlight %}

test results
------------
{% highlight js %}
 component
    ✓ renders name
    ✓ renders component

  names reducer
    ✓ greets
    ✓ no greetings to Stranger

  4 passing (39ms)
{% endhighlight %}
