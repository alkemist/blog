---
title: "Stumbling on Ratpack - Handlers"
author:
  name: "Roberto Guerra"
---

__Ratpack__ is a 'simple, capable, toolkit for creating high performance applications' in the jvm.
It was originally inspired by __Sinatra__ but it has taken a life of its own with very interesting concepts.
It is virtually a treasure cove of neat tricks with __Groovy__ and its __@CompileStatic__ feature. It has not
reached 1.0 yet, and it is under heavy development, with releases the 1st of every month.

__Ratpack__ has always attracted me, and I finally got some time to play with it. The documentation is a work in progress,
but the core devs are very helpful and the API seems to be stabilizing. So it seemed like the right time to
get my feet wet.

## Why I'm excited about Ratpack
I've tried __Rails__-type frameworks (Grails, Django, Rails, etc) and I seem to be very productive with them, but
as the application starts to grow, all those initial 'benefits' seem to become obstacles. They seem to encourage
tight coupling and it feels like we are building 'Rails/Grails/Django' apps instead of whatever application we are
trying to build.

__Ratpack__ tries to encourage us to build very small, lightweight applications that are not tightly coupled to 
__Ratpack__ itself. It seems to be just a thin shell that allows us to connect to external resources or expose our
system to outside world. Since it doesn't provide all these extra heavyweight 'features' like ORMs, mailers, etc;
it allows us to think about our design and not just blindly create objects for our ORM that then drive our
business logic.

Setting Up
----------
The easiest way to setup a ratpack project is with __Gradle__ and __Lazybones__. If you have __gvm__ installed you
can easily install them:

```bash
gvm install gradle
gvm install lazybones
```

And starting a ratpack project is as easy as:

```bash
lazybones create ratpack ratpack-app-name
```

This will create a folder in the current directory with the __ratpack-app-name__. For more information, you can
refer to the official [documentation](http://www.ratpack.io/manual/current/setup.html)

Handlers
--------
__Handlers__ are responsible for _handling_ response and request objects. They are asynchronous by default, although
we can block explicitly (to be covered in a later blog post). A simple example looks like this:

```java
import static ratpack.jackson.Jackson.json

ratpack {

  bindings {
    new JacksonModule()
  }

  handlers {
    get("books") {
      render json([ [title: "Book A"], [title: "Book B"] ])
    }
  }
}
```

This exposes a "/books" resource that will render a list of books as json. The __bindings__ section is where we
configure all the modules we need. In this case we need __Jackson__ to render json.

The handler exposes methods whose names match the HTTP verbs - __get__, __post__, __delete__, __put__ - and each
method takes a string as a parameter that defines the unique path. For example, get("books") allows us to do a GET at "/books".
And __post("books")__ allows us to do a DELETE on "/books".

