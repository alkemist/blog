---
title: "Introduction: TDD with Backbonejs and Mocha"
author:
  name: "Roberto Guerra"
---

Welcome to the series on test driving an application with Mochajs and Backbonejs. We will build 
an application from scratch by writing tests first in an exploratory fashion. The purpose
of the series is to explore TDD. So we will make lots of mistakes along the way but hopefully
have a better understanding by the end of our journey.

We will be using Coffeescript because I prefer Coffeescript. But it should be fairly simple to
convert the code to Javascript.

We are also using [Backbonejs](http://backbonejs.org) and composite framework that sits on top of
it called [Marionettejs](http://marionettejs.com) that reduces some of the boilerplate and also
adds some nice abstractions.

Grunt is used as a build tool to run the application and the tests. Refer to the [source](https://github.com/uris77/tdd-mocha-screencast) on github on
how to use the Grunt tasks for the application.

The Application we will build is a basic web app that retrieves some time entries from [Toggl](http://www.toggl.com)
and generates an invoice based on the logged times that Toggl's api service returns.

There is a git branch corresponding to each episode to make it easier to follow the code changes.

Please bear with my accent and clumsiness, you'll see me stumbling through code as I try to figure out what
to do and murmur a lot as I get stuck.


