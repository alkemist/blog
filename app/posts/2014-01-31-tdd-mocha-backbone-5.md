---
title: "Episode IV: TDD with Backbonejs and Mocha - Testing XHR"
author:
  name: "Roberto Guerra"
---

<p class="content">
<h3>Stubbing Backbone's fetch().</h3>
When we need to test a part of our application the fetches data
from a server, we will want to avoid making that request so as 
not to slow down our tests; and because that endpoint might not
be implemented yet. Besides, we are focusing on unit tests, and they
should only test individual indpendent units. If our test makes an external
request, then it stops being a unit test and starts to venture into
the realm of integration or functional tests.
</p>

Lets consider the following code:

```coffeescript
class RateCalculator
  calculate: (ratePerHour) ->
    timeEntries = new TimeEntries()
    timeEntries.fetch()
    _.reduce(timeEntries.models, (acc, timeEntry)-> acc * parseInt(timeEntry.hrs, 10), 20)
```

This method calculates the total rate based on how many hours the hourly rate. The hours is fetched via
an XHR request. Testing this can be a little challenging, but not impossible. We can use sinon to stub
the collection's `fetch` function:

```coffeescript
describe 'Rate Calculator', ->
  it 'calcluates the hourly rate', ->
    calculator = new RateCalculator()
    timeEntriesStub = sinon.stub(TimeEntries::, 'fetch').returns(new TimeEntries([{hrs: 2}, {hrs: 3}]))
    expect( calculator.calculate(20) ).to.be 100
    timeEntriesStub.restore()
```

While this will work, there are a couple things that should bother us. First, the RateCalculator
is tightly coupled to TimeEntries collection; but most importantly, the RateCalculator is doing too much.
It is retrieving the data AND calculating the rate. We can address this by 'injecting' the TimeEntries
into the calculcate method:

```coffeescript
class RateCalculator
  calculate: (ratePerHour, timeEntries) ->
    _.reduce(timeEntries.models, (acc, timeEntry)-> acc * parseInt(timeEntry.hrs, 10), 20)
```

This looks much simpler. Even our test looks better.

```coffeescript
describe 'Rate Calculator', ->
  it 'calcluates the hourly rate', ->
    calculator = new RateCalculator()
    timeEntriesStub = new TimeEntries([{hrs: 2}, {hrs: 3}])
    expect( calculator.calculate(20) ).to.be 100
```

If we step back for a moment, we can see that we might stumble on the same problem again. Consider
a testing some part of our application that uses RateCalculator. We might have some code similar to this:

```coffeescript
class RateController
  onSubmittButton: ->
    timeEntries = new TimeEntries().fetch()
    rateCalculator = new RateCalculator()
    rateCalculator.calculate(20, timeEntries)
```

When we try to test this we might have a situation similar to our first test:

```coffeescript
describe 'Rate Controller', ->
  it 'calcluates the hourly rate', ->
    rateController = new RateController()
    timeEntriesStub = sinon.stub(TimeEntries::, 'fetch').returns(new TimeEntries([{hrs: 2}, {hrs: 3}]))
    expect( rateCalculator.onSubmitButton() ).to.be 100
    timeEntriesStub.restore()
```

If we need to use RateCalculator in other parts of our application, we will duplicate this in many places
and lose track of it. Why is this bad again? Because it couples our application to Backbone and creates
some unmaintanable code. It will be difficult to change this if we ever decide that maybe Backbone is not
the right choice, or if our TimeEntries is a more complex collection

We can solve this by injecting the collection, like we did in the first scenario, and it is the route
I would take; but we will reach a point where passing the collection like a hot potato will not save us,
and we will have to deal with this situation head on.

And what about situations where we would want to trigger an action when a new set of collections is fetched?
Or maybe we have a real-time dashboard that needs to get updated on near real time everytime some event
happens somewhere else (even on a remote computer or server)?

We can still solve this by using Backbone Collections and listening to the events triggered. And we might even
add our own custom events. But the fact remains that we are still tightly coupled to Backbone.

###Repository Pattern.
If we step back for a bit, and imagine our application as a vulnerable kernel that needs to be shielded from any
outside infection, then we can see how allowing direct calls to Backbone.Collection#fetch() deep in our application
exposes it to external factors. Changes to the Backbone API can require massive changes deep in our application's
kernel.

We can take some inspiration from the ['Hexagonal Architecture'](http://alistair.cockburn.us/Hexagonal+architecture) to help us come up with a 'cleaner' solution.
In order to access any external system (like xhr requests), we need to add an interface for it.


