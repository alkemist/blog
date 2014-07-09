---
title: "Stumbling on Ratpack - Templates"
author:
  name: "Roberto Guerra"
---

Rendering html templates in __Ratpack__ is very straightforward. We'll use the built-in templating features of Ratpack's Groovy module to render 
very simple templates, to complex templates with sub-templates; and templates with dynamic data.

###Rendering A Simple Template
As mentioned in our previous post, __Ratpack__ applications have a base dir that contains all the files accessible at runtime.
When using the Gradle plugin, this is the __src/ratpack__ directory during development. 
The default location for template files is the __templates__ directory inside the base directory.
If we place our html templates under the __templates__ folder, then we can easily render them.
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
      render groovyTemplate("hello.html", name: "Jon")
    }
  }
}
```

We are using [Groovy's named parameter syntax](http://mrhaki.blogspot.com.au/2009/09/groovy-goodness-named-parameters-are.html) here.

Template files are just text files with embedded Groovy expressions.

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

The content of the file is effectively evaluated as one big [Groovy GString](http://mrhaki.blogspot.com.au/2009/08/groovy-goodness-string-strings-strings.html).
Code can be evaluated via the standard `$«variable»` or `${«code»}` GString constructs.

The API available for a template file is the [TemplateScript](http://www.ratpack.io/manual/current/api/ratpack/groovy/templating/TemplateScript.html) type.
Note how it provides a `getModel()` method that provides the map of data that we passed to the `groovyTemplate()` method.
It also provides the `html()` method that can be used for escaping HTML meta characters.
A better way to write our template would be:

```html
<html>
  <head>
    <title>Hello From Ratpack</title>
  </head>
  <body>
    <h1>Hello ${html model.name}, meet the amazing Ratpack!</h1>
  </body>
</html>
```

This way, if someone is unfortunate enough to contain `<strong>` in their name we will correctly encode this as `&lt;strong&gt;` in the output HTML.
  
In addition to the `$«variable»` and `${«code»}` constructs, `<% «code» %>` and `<%= «code %>` can also be used for larger (i.e. multiline) blocks of code.
The difference is that the latter outputs the string value of the last expression while the former does not.

If you need to output a literal `$` character, you can simply escape it with `\$`.

```html
<p>\$20</p>
```

###Composing Templates
Templates can also be composed. This allows us to reuse templates in a very elegant & convenient manner. A common use case is if we want all our
pages to have the same header and footer. 
The [`render()` method of `TemplateScript`](http://www.ratpack.io/manual/current/api/ratpack/groovy/templating/TemplateScript.html#render\(java.lang.String\)) 
can be used to render nested templates.

```html
<% render '_templateName.html' %>
```

There is nothing special about these templates. They reside under the __templates__ directory and they don't really need the underscore in front
of their name, but it is the recommended convention to use. Here is a simple example where we have our header and footer in their own template:

```
'_header.html'
-------------
<html>
  <head>
    <title>Hello From Ratpack</title>
  </head>
  <body>
```

```
'_footer.html'
------------
</body>
</html>
```

```
'hello.html'
-----------
<% render "_header.html" %>
<h1>Hello ${html model.name}, meet the amazing Ratpack!</h1>
<% render "_footer.html" %>
```

The sub-templates will also have access to the same `model` as the `main` template. So we can access the same data if we need to.

###Summary
Rendering templates with __Ratpack__ is not complicated. We can render simple templates, and templates with dynamic data that is
set by the handlers. We can also reuse our templates and compose them.

