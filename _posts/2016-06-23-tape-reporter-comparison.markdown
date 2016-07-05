---
layout: post
title: tape reporter comparison
date: 2016-06-23 21:00:00 +000
tags: testing tape reporters
---

at the time of writing I prefer tap-min

- summary for passed tests
- detailed failed test assertions
- console log statements still make it to the output to help identify the issue

lets take a look at possible alternatives and a quick comparison

test code
---------

{% highlight js %}
const test = require('tape')

test('is okay', t => {
  t.plan(1)
  console.log('log: this test will be okay')
  t.ok('is okay')
})

test('is okay', t => {
  t.plan(1)
  console.log('log: this test will fail')
  t.notOk('is not okay')
})
{% endhighlight %}

tape reporter
-------------

{% highlight bash %}
TAP version 13
# is okay
log: this test will be okay
ok 1 should be truthy
# is okay
log: this test will fail
not ok 2 should be falsy
  ---
    operator: notOk
    expected: false
    actual:   'is not okay'
    at: Test.t (/Users/uldis/git/playgrounds/tape-reporters/test.js:12:5)
  ...

1..2
# tests 2
# pass  1
# fail  1
{% endhighlight %}

faucet reporter
---------------

- compacts successful scenarious and comes with colors
- hides console log statements

{% highlight bash %}
✓ is okay
⨯ is okay
  not ok 2 should be falsy
    ---
      operator: notOk
      expected: false
      actual:   'is not okay'
      at: Test.t (/Users/uldis/git/playgrounds/tape-reporters/test.js:12:5)
    ...

# tests 2
# pass  1
⨯ fail  1
{% endhighlight %}

tap-spec reporter
----------------

- mocha like output
- summary contains failed tests

{% highlight bash %}
  is okay

    log: this test will be okay
    ✔ should be truthy

  is okay

    log: this test will fail

    ✖ should be falsy
    ------------------
      operator: notOk
      expected: false
      actual:   'is not okay'
      at: Test.t (/Users/uldis/git/playgrounds/tape-reporters/test.js:12:5)




  Failed Tests: There was 1 failure

    is okay

      ✖ should be falsy


  total:     2
  passing:   1
  failing:   1
  duration:  22ms
{% endhighlight %}

tap-dot reporter
---------------

- very compact
- hides console log statements

{% highlight bash %}
  .x


  ---
    operator: notOk
    expected: false
    actual:   'is not okay'
    at: Test.t (/Users/uldis/git/playgrounds/tape-reporters/test.js:12:5)
  ...



  2 tests
  1 passed
  1 failed

  Failed Tests:   There was 1 failure

    x should be falsy
{% endhighlight %}

tap-min reporter
-----------------

- minimalistic output
- returns full details for failed tests

{% highlight bash %}
TAP version 13
# is okay
log: this test will be okay
ok 1 should be truthy
# is okay
log: this test will fail
not ok 2 should be falsy
  ---
    operator: notOk
    expected: false
    actual:   'is not okay'
    at: Test.t (/Users/uldis/git/playgrounds/tape-reporters/test.js:12:5)
  ...
{% endhighlight %}

tap-bail reporter
-----------------

- stops after first failed test

{% highlight bash %}
TAP version 13
# is okay
log: this test will be okay
ok 1 should be truthy
# is okay
log: this test will fail
not ok 2 should be falsy
{% endhighlight %}

tap-pessimist reporter
----------------------

- super minimalist output of just the failed test names

{% highlight bash %}
2 - should be falsy
{% endhighlight %}
