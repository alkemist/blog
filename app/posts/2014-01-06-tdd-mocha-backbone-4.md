---
title: "Episode IV: TDD with Backbonejs and Mocha"
author:
  name: "Roberto Guerra"
---
<p class="video">
<iframe src="//player.vimeo.com/video/83012423?title=0&amp;byline=0" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen>
</iframe>
</p>

<p class="content">
In Episode IV, the navigation bar sends messages to the center panel to display the view
corresponding to the selected navigation item. We use Marionette's EventAggregator as the 
communication mechanism between both controllers. Events/Messaging is neat way of de-coupling 
applications, but abusing it can cause problems:
<ol>
<li> You can not reason about what is handling the event, especially if we don't have a naming
standard for the events.</li>
<li>Refactoring becomes a little more difficult. If we are using and IDE like Webstorm, then we 
can't take advantage of autocomplete and its refactoring features.
</li>
</ol>
</p>

<p class="content">
Although not mentioned in the screencast, a rule of thumb I use is that events/messages are only
used when both components are 'far' from each other and don't have any sort of logical relationship
between them.
</p>

<p>
Source is available at [github](https://github.com/uris77/tdd-mocha-screencast/tree/PartIV).
</p>


