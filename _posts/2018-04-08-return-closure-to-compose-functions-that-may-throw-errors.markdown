---
layout: post
title: return closure to compose functions that may throw errors
date: 2018-04-08 12:00:00 +000
tags: javascript closure composition throw errors
---

## composition

{% highlight javascript %}

// simplistic implementation of compose
const compose = (...fns) => obj =>
  fns.reduceRight((acc, cur) => cur(acc), obj)

// use
const id = x => x;
const fn1 = id;
const fn2 = id;
const fn3 = id;

const data = {some: 'data'}
const res = compose(fn3, fn2, fn1)(data)

{% endhighlight %}

This approach works well in most scenarios, however, it doesn't when we anticipate a potential __failure__ in one (or more) of the earlier functions and would like to __handle__ it in one (or more) of the latter ones.

## closures to the rescue

In functional programming there is a concept of a container - function is a type of a container. We can transform functions to return functions and by doing so achieve the required functionality.

{% highlight javascript %}

// pipeline
const process = (name, fn) => compose(
  handleError(name),
  log(name),
  fn
)

// rethrow error if any hiding stack trace
const handleError = name => fn => {
  try {
    return fn()
  } catch (err) {
    return _ => { throw new Error(`${name}.GenericError`) }
  }
}

// log entry + success + error
const log = name => fn => {
  console.log(`${name}.Enter`)
  try {
    const res = fn()
    console.log(`${name}.Success`, res)
    return _ => res
  } catch (err) {
    console.log(`${name}.Error ${err.message}`)
    return _ => { throw err }
  }
}

// use
const success = x => _ => x
process('successFn', success)(data) // === data

const failure = _ => _ => undefined.a
process('failureFn', failure)(data) // throws error

// async
const successA = x => async _ => x
await process('successAFn', successA)(data) // === data

{% endhighlight %}

This is not the only way and most probably not the best either (see [Fantasy Land](https://github.com/fantasyland/fantasy-land)) - but gets the job done without external dependencies, a lot of extra code and a need to have a pre-existing FP knowledge.
