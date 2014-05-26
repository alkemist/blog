---
title: "Event Tracking with Google Analytics & Java"
author:
  name: "Roberto Guerra"
---

Google provides a javascript library (analytics.js) that can be used to track events and do page tracking in our web aplications.
This is convenient for most use cases, but it wasn't serving one of our use cases. We wanted to track a couple of events:

1. Login
2. Logout
3. Registration

This is pretty straightforward with anaylics.js, but we had an additional requirement. We wanted to track this events across a
'federated' group of sites. Users for these applications authenticate through a single _CAS_ server. We could have embedded
some javascript in all the sites, but it wasn't practical. There are literally dozens of sites that authenticate via the same
_CAS_ server.

So we started looking at doing this on the _CAS_ server itself, but we quickly discovered that Google does not provide a Java API
for event tracking. We discovered a library that wrapped the XHR calls in a JAVA API [https://github.com/brsanthu/google-analytics-java](https://github.com/brsanthu/google-analytics-java).
Using the API is very intuitive:

```Groovy
GoogleAnalytics ga = new GoogleAnalytics("UA-XXXXX")
ga.eventLabel("SOME LABEL")
ga.postAsync()
```

The above snippet looks fine and it won't throw an error. It would seem as if it is working fine. But after checking the Analytics dashboard, we don't see any event
being tracked. After some hours of pulling hair, we discover that Google won't process an event if it does not have a 'valid' user agent.
_Analytics.js_ will send the user agent for us, so we normally do not have to configure that. The other caveat is that Google 'automatically validates' the User Agent, which
means we can not just make up a fake user agent. But we can easily provide a valid User Agent from one of our browsers:

```Groovy
def USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.9; rv:28.0) Gecko/20100101 Firefox/28.0"
GoogleAnalytics ga = new GoogleAnalytics("UA-XXXXX")
ga.eventLabel("SOME LABEL")
ga.userAgent(USER_AGENT)
ga.postAsync()
```

And now when we check the Analytics Dashboard, we can finally see some events being tracked.



