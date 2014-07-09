---
title: "Stumbling on Ratpack - Templates"
author:
  name: "Roberto Guerra"
---

Rendering html templates in __Ratpack__ is very straightforward. We'll use the Groovy Template to render very simple templates, to complex
templates with sub-templates; and templates with dynamic data.

###Rendering A Simple Template
As mentioned in our previous post, the root directory for a __Ratpack__ application resides under __src/main/ratpack__. This will generally have
a __public__ folder and a __templates__ folders. If we place our html templates under the __templates__ folder, then we can easily render them.
For example, if we have a template called __hello.html__, we can easily render it as follows:

```java
import static ratpack.groovy.Groovy.groovyTemplate

ratpack {

  handlers {
    get("hello") {
      render groovyTemplate("hello.html")
    }
  }
}
```

###Rendering Templates With Dynamic Data
In most cases we will want to render some data that we retrieved from a database or some other location. We won't be covering how to interact
with a database in this post, so we'll just use arbitrary data for the sake of keeping it simple. Let's say we want to print the message
"Hello Jon, meet the amazing Ratpack". __groovyTemplate__ can also take a Map and a String as parameters. It's signature looks like this:
```java
groovyTemplate(Map<String, ?>, String id)
```
This is how we would use this method to render some data in our template:

```java
import static ratpack.groovy.Groovy.groovyTemplate

ratpack {

  handlers {
    get("hello") {
      render groovyTemplate([name: "Jon"],"hello.html")
    }
  }
}
```

__Ratpack__ gives us a __model__ attribute in all our templates, which will hold any data we pass to it from our handlers. So if we want to render
the data in the example above we would just print __$model.name__ anywhere within our template where we want to display it:

```html
<html>
  <head>
    <title>Hello From Ratpack</title>
  </head>
  <body>
    <h1>Hello $model.name, meet the amazing Ratpack</h1>
  </body>
</html>
```

