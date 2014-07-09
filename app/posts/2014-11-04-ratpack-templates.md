---
title: "Stumbling on Ratpack - Templates"
author:
  name: "Roberto Guerra"
---

Rendering html templates in __Ratpack__ is very straightforward. We'll use the Groovy Template to render very simple templates, to complex
templates with sub-templates; and templates with dynamic data.

##Rendering A Simple Template
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


