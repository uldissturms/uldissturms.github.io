---
layout: post
title: vim cheat sheet
date: 2016-08-07 14:00:00 +000
tags: vim cheat sheet
---

> this is not an exhaustive list and most probalby will be extended in the future

paste
-----
- ```"+p``` - paste from global buffer (clipboard)

editing (insert mode)
---------------------
- ```ctrl+n``` - auto-completion next
- ```ctrl+p``` - auto-completion previous
- ```ctrl+t``` - indent line
- ```ctrl+d``` - outdent line

editing (normal mode)
---------------------
- ```.``` - repeat last command (insert is treated as a single command)
- ```R``` - type over text

navigate
---------
- ```''``` - back to previous position
- ```'.``` - back to previous edit
- ```{``` - back one paragraph
- ```}``` - forward by one paragraph
- ```*``` - next occurance of word under cursor
- ```%``` - bounce between brackets, beginning and end of a single method
- ```o``` - bounce between beginning and end of a visual block

panes
-----
- ```ctrl+wv``` - split vertically
- ```ctrl+ws``` - split horizontally
- ```ctrl+wq``` - close
- ```ctrl+wo``` - close all but current


vit (visual inside tag)
---
- v - operator, i - extent, t - object
- operator is one of:
  - change
  - delete
  - yank
  - visual
- extent is one of:
  - around (a)
  - inside (i)
- object is one of:
  - word (w)
  - Word (W)
  - sentence (s)
  - pagragraph (p)
  - tag (t)
  - " ' [ { (

favourite plugins
-----------------
- syntastic
- ctrlp.vim
- vim-colors-solarized
- vim-json

custom key mappings
-------------------
{% highlight bash %}
nnoremap <TAB> <C-w>w
nnoremap <S-TAB> <C-w>W
inoremap jj <ESC>
let mapleader=","
{% endhighlight %}
