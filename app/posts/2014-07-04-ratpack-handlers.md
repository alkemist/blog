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
__Handlers__ are responsible for _handling_ response and request objects. They are stateless & asynchronous by default, although
we can block explicitly (to be covered in a later blog post). A simple example looks like this:

```java

ratpack {

  handlers {
    get("hello") {
      render "Hello!"
    }
  }
}
```

This will render "Hello!" when we visit __http://localhost:5050/hello__.

The handler exposes methods whose names match the HTTP verbs - __get__, __post__, __delete__, __put__ - and each
method takes a string as a parameter that defines the unique path. For example, get("books") allows us to do a GET at "/books".
And __post("books")__ allows us to do a DELETE on "/books".

#### Order Matters
The order of the handlers also matter. Those declared at the top are evaluated first. E.g.:

```java
ratpack {
  handlers {
    get("hello") {
      render "Hello!"
    }

    get("bye") {
      render "Bye Bye!"
    }
  }
}
```

__Ratpack__ will first check if the route matches "hello", if not, it will proceed to the next handler, until it finds a matching one.


#### JSON
If we want to render json, we need to use the __JacksonModule__:

```java
import ratpack.jackson.JacksonModule
import static ratpack.jackson.Jackson.json

ratpack {
  bindings {
    new JacksonModule()
  }

  handlers {
    get("api/books") {
      def books = [
        [title: 'A Tale of Two Cities'],
        [title: 'Daughter of Smoke & Bone'],
        [title: 'Wheel of Time'],
        [title: "Spider's Bite (Elemental Assasin #1)"]
      ]
      render json(books)
    }

    get("api/authors") {
      def authors = [
        [name: 'Charles Dickens'],
        [name: 'Laini Taylor'],
        [name: 'Robert Jordan'],
        [name: 'Jennifer Estep']
      ]
      render json(authors)
    }
  }
}
```

We can also use __prefix__ if we want to group all these handlers:

```java
import ratpack.jackson.JacksonModule
import static ratpack.jackson.Jackson.json

ratpack {
  bindings {
    new JacksonModule()
  }

  handlers {
    prefix("api") {
      get("books") {
        def books = [
          [title: 'A Tale of Two Cities'],
          [title: 'Daughter of Smoke & Bone'],
          [title: 'Wheel of Time'],
          [title: "Spider's Bite (Elemental Assasin #1)"]
        ]
        render json(books)
      }

      get("authors") {
        def authors = [
          [name: 'Charles Dickens'],
          [name: 'Laini Taylor'],
          [name: 'Robert Jordan'],
          [name: 'Jennifer Estep']
        ]
        render json(authors)
      }
    }
  }
}
```

#### Dynamic Paths
We can create dynamic paths pretty easily by prepending a __:__ to the dynamic parts of the route.
Every __handler__ has a __pathTokens__ attribute that allows us to access the dynamic parts of the url through its name:

```java
import ratpack.jackson.JacksonModule
import static ratpack.jackson.Jackson.json

ratpack {
  bindings {
    new JacksonModule()
  }

  handlers {
    get("hello/:name") {
      def name = pathTokens.name
      render "Hello $name"
    }
  }
```

#### Static Assets
If we are using the lazybones template to generate a __Ratpack__ application, we can serve up static assets quite easily.
__Ratpack__ provides an __assets__ function that takes a string which represents the directory that we want to serve. This
directory has to be inside the __src/ratpack__ folder:

```java
ratpack {
  handlers {
    assets "css"
  }
}
```

The above snippet will serve everything under __src/ratpack/css__ as static assets. We can also serve more than one folder:

```java
ratpack{
  handlers{
    assets "css"
    assets "js"
  }
}
```

These are the basics of how handlers work in __Ratpack__. In the next installment we will see how we can render templates.

