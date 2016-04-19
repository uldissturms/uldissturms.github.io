---
layout: post
title: testing react and redux
date: 2016-04-19 20:00:00 +000
tags: testing react redux
---

For a tipical react redux application there are four levels at which it makes sense to test:

- components
- store
- reducers
- end-to-end (ui integration tests)

In this blog post I will cover __component__, __store__ and __reducer__ tests since end-to-end tests are normally written in an implementation agnostic way (e.g., selenium) and are covered well by others already.

setting up environment
-----------------------

{% highlight bash %}
npm install react react-dom redux --save
npm install mocha expect expect-jsx \
            babel-register babel-preset-2015 \
            babel-reset-react react-addons-test-utils --save-dev
echo '{ "presets": ["react", "es2015"] }' > .babelrc
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

store
-----

Store is a good place to test that dispatched actions are getting handled by the relevant reducers as expected.

### store.test.js
{% highlight js %}
import expect from 'expect';
import {store} from './store';

describe('store', () => {
  it('starts off with empty names array', () => {
    const state = store.getState();
    expect(state).toEqual({ names: []});
  });
  it('adds a name after greet action processed', () => {
    const action = { type: 'GREET', payload: { name: 'Steve' }};
    store.dispatch(action);
    const state = store.getState();
    expect(state).toEqual({ names: ['Steve']});
  });
});
{% endhighlight %}

### store.js
{% highlight js %}
import {createStore} from 'redux';
import namesReducer from './namesReducer';

export const store = createStore(namesReducer);
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

reducer
-------

In a case where reducer has many ways of processing an action a simple test that has no side effects can be written.

### namesReducer.test.js
{% highlight js %}
import expect from 'expect';
import namesReducer from './namesReducer';

const greet = name => {
  return { type: 'GREET', payload: { name: 'Stranger' }};
};

describe('names reducer', () => {
  it('no greetings to Stranger', () => {
    const state = namesReducer({ names: [] }, greet('Stranger'));
    expect(state).toEqual({ names: []});
  });
});
{% endhighlight %}
