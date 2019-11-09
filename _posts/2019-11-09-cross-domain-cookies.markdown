---
layout: post
title: cross domain cookies
date: 2019-11-09 12:00:00 +000
tags: cookies
---

There might be times when state needs to be passed between sub and root domain or sibling domains such as:
* a.domain.local -> b.domain.local (siblings)
* b.domain.local -> a.domain.local (siblings)
* a.domain.local -> domain.local (sub -> root)
* domain.local -> a.domain.local (root -> sub)

All this is possible if:
* cookies are set with explicit domain
* cookie domain is part of all interested parties (.domain.local in this particular case)

Further read on cookies and security policies: https://blog.webf.zone/ultimate-guide-to-http-cookies-2aa3e083dbae

### setup

#### /etc/hosts file

```
127.0.0.1 domain.local
127.0.0.1 a.domain.local
127.0.0.1 b.domain.local
```

#### express node app

```javascript
const cookieParser = require('cookie-parser')
const express = require('express')

const port = 80
const domain = '.domain.local'

const app = express()
app.use(cookieParser())

app.get('/', (req, res) => {
  const { hostname, cookies } = req
  const { cookieName = 'n', cookieValue = 'v' } = req.query
  const opts = {
    domain
  }
  res.cookie(cookieName, cookieValue, opts).send(
    `[${hostname}] cookies: ${JSON.stringify(cookies)}`
  )
})

app.listen(port,
  () => console.log(`Cookie app listening on port ${port}!`)
)
```

### test

#### curl

```
curl -v http://a.domain.local?cookieName=a&cookieValue=a # < Set-Cookie: a=a; Domain=.domain.local; Path=/
curl -v http://b.domain.local?cookieName=b&cookieValue=b # < Set-Cookie: b=b; Domain=.domain.local; Path=/
curl -v http://domain.local?cookieName=t&cookieValue=t # < Set-Cookie: t=t; Domain=.domain.local; Path=/
```

#### browser

```
open http://a.domain.local/?cookieName=a&cookieValue=a
open http://b.domain.local/?cookieName=b&cookieValue=b
open http://t.domain.local/?cookieName=t&cookieValue=t
```

After all paths have been visited we will see that rendered browser output is:

* http://a.domain.local - `[a.domain.local] cookies: {"b":"b","t":"t","a":"a"}`
* http://b.domain.local - `[b.domain.local] cookies: {"b":"b","t":"t","a":"a"}`
* http://domain.local - `[domain.local] cookies: {"b":"b","t":"t","a":"a"}`

We have successfuly achieved cookie sharing between sub and root and sibling domains.
