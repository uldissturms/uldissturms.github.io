---
layout: post
title: property based testing in javascript - diamond kata
date: 2018-07-01 12:00:00 +000
tags: javascript property-testing katas
---

## credits

This is pretty much a re-implementation of kata done by [Mark Seeman in FSharp](http://blog.ploeh.dk/2015/01/10/diamond-kata-with-fscheck/).
 so all credits go to him. The goal is to learn property based testing from something that had already been implement in functional programming language and transfer that knowledge to javascript. So here we go.

## kata

Kata was first described by [Seb Rose in Recycling tests in TDD](http://claysnow.co.uk/recycling-tests-in-tdd/).

> Given a letter, print a diamond starting with 'A' with the supplied letter at the widest point. For example: print-diamond 'C' prints

{% highlight text %}
  A
 B B
C   C
 B B
  A
{% endhighlight %}

## code

Non empty diamond

{% highlight javascript %}
test('diamond is non-empty', t => {
  t.true(isNotEmpty(diamond(letter)))
})

const not = fn => (...val) => !fn(...val)
const isEmpty = obj => obj === ''
const isNotEmpty = not(isEmpty)

const diamond = _ => '_'
{% endhighlight %}

First and last row contains A

{% highlight javascript %}
test('first row contains A', t => {
  const d = diamond(letter)
  t.is(compose(trim, head, splitLF)(d), 'A')
})

test('last row contains A', t => {
  const d = diamond(letter)
  t.is(compose(trim, last, splitLF)(d), 'A')
})

const trim = s => s.trim()
const split = c => s => s.split(c)
const splitLF = split('\n')

const diamond = _ => 'A'
{% endhighlight %}

All rows have symmetric contour

{% highlight javascript %}
test('all rows have symmetric contour', t => {
  const d = diamond(letter)
  t.true(
    compose(
      all(x => leadingSpaces(x) === trailingSpaces(x)),
      map(withoutLF),
      splitLF
    )(d)
  )
})

const isLetter = c => /[A-Z]/.test(c)
const leadingSpaces = s => s.substring(0, firstIndex(isLetter)(s))
const trailingSpaces = s => s.substring(lastIndex(isLetter)(s) + 1)
const replace = (x, y) => s => s.replace(new RegExp(x, 'g'), y)
const withoutLF = replace('\\n', '')

const diamond = _ => '  A  '
{% endhighlight %}

All rows containt the correct letter in the correct order

{% highlight javascript %}
test('rows contain the correct letter in the correct order', t => {
  const d = diamond(letter)
  const l = letters('A', letter)
  t.deepEqual(
    compose(map(head), map(trim), splitLF)(d),
    [...l, ...compose(tail, reverse)(l)]
  )
})

const diamond = l => {
  const s = 'A'
  const d = distance(s, l)
  return compose(
    join('\n'),
    xs => [...xs, ...compose(tail, reverse)(xs)],
    map(makeLine(d))
  )(letters(s, l))
}

const toCharCode = c => c.charCodeAt(0)
const fromCharCode = c => String.fromCharCode(c)
const letters = (s, e, l = []) =>
  toCharCode(s) > toCharCode(e)
    ? l
    : letters(fromCharCode(toCharCode(s) + 1), e, [...l, s])
const distance = (s, e) => toCharCode(e) - toCharCode(s)
const join = c => xs => xs.join(c)
const spaces = t => new Array(t).fill(' ').join('')

const makeLine = d => s => spaces(3) + s + spaces(3)
{% endhighlight %}

As wide as high

{% highlight javascript %}
test('as wide as high', t => {
  const d = diamond(letter)
  const height = splitLF(d).length
  t.true(
    compose(
      all(x => x.length === height),
      map(withoutLF),
      splitLF
    )(d)
  )
})
{% endhighlight %}

All lines except top and bottom have two identical letters

{% highlight javascript %}
test('all lines except top and bottom have two identical letters', t => {
  const d = diamond(letter)
  t.true(
    compose(
      all(isTwoIdenticalLetters),
      filter(not(includes('A'))),
      map(withoutSpaces),
      splitLF
    )(d)
  )
})

const withoutSpaces = replace(' ', '')
const isTwoIdenticalLetters = s =>
  s.length === 2 && s[0] === s[1]
{% endhighlight %}

Lower left space is a triangle

{% highlight javascript %}
test('lower left space is a triangle', t => {
  const d = diamond(letter)
  const dist = distance('A', letter)
  t.deepEqual(
    compose(
      map(x => x.length),
      map(leadingSpaces),
      skipWhile(([x]) => isNotLetter(x)),
      splitLF
    )(d),
    ints(0, dist)
  )
})

const ints = (s, e, l = []) =>
  s > e
    ? l
    : ints(s + 1, e, [...l, s])

const skipWhile = fn =>
  compose(
    snd,
    xs => xs.reduce(
      ([s, l], c) => s && fn(c)
        ? [true, []]
        : [false, [...l, c]],
      [true, []]
    )
  )
{% endhighlight %}

Figure is symmetric around horizontal axis

{% highlight javascript %}
test('figure is symmetric around horizontal axis', t => {
  const d = diamond(letter)
  t.deepEqual(
    compose(
      map(withoutLF),
      splitLF
    )(d),
    compose(
      reverse,
      map(withoutLF),
      splitLF
    )(d)
  )
})

const makeLine = d => (s, i) => {
  const padding = spaces(d - i)
  return s === 'A'
    ? padding + s + padding
    : padding + s + spaces(i * 2 - 1) + s + padding
{% endhighlight %}

The full source code can be found [here](https://github.com/uldissturms/exercises/blob/master/katas/property-testing.test.js).
