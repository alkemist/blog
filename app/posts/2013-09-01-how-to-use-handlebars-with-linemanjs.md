---
title: "How to use Handlebars with Lineman"
author:
  name: "Roberto Guerra"
---

[Lineman](https://github.com/testdouble/lineman) is a tool for creating rich front end applications. It uses __underscorejs__ templates
by default, and it comes pre-configured for __handelbars.js__. However, there is some additional work we need to do before we can use
__handlebars.js__.
Before we start we have to copy [handlebars.runtime.js](https://raw.github.com/wycats/handlebars.js/master/dist/handlebars.runtime.js) into the 
__vendor/js__ directory. Now we can start creating handlebar templates. These will go under the __app/templates__ directory. Lineman will be
looking for files with extendsions __.hb__, __.handlebar__ or __.handlebars__. And that is all we need to use __handelbars.js__.

There is one little tiny caveat that might have we scratching our head. __Linemanjs__ compiles all templates with the __JST__ namespace. So if we
are used to accessing the __handlebars.js__ templates like this __Handelbar.templates['myTemplateName']__, this won't work. You have to use the __JST__
namespace. An example of using a __handelbar.js__ template in a __Backbone__ view:

```coffeescript
class MyView extends Backbone.View
    template: JST['templates/myTemplate.hb']
    ...
```

And that is really all there is to it.
