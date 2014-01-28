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

<p>
Lets consider the following code:
</p>

</p>

```coffeescript
class RateCalculator
  calculate: (ratePerHour) ->
    timeEntries = new TimeEntries()
    timeEntries.fetch()
    _.reduce(timeEntries.models, (acc, timeEntry)-> acc * parseInt(timeEntry.hrs, 10), 20)
```
<p class="content">
This method calculates the total rate based on how many hours the hourly rate. The hours is fetched via
an XHR request. Testing this can be a little challenging, but not impossible. We can use sinon to stub
the collection's `fetch` function:
</p>

```coffeescript
describe 'Rate Calculator', ->
  it 'calcluates the hourly rate', ->
    calculator = new RateCalculator()
    timeEntriesStub = sinon.stub(TimeEntries::, 'fetch').returns(new TimeEntries([{hrs: 2}, {hrs: 3}]))
    expect( calculator.calculate(20) ).to.be 100
    timeEntriesStub.restore()
```

<p class="content">
While this will work, there are a couple things that should bother us. First, the RateCalculator
is tightly coupled to TimeEntries collection; but most importantly, the RateCalculator is doing too much.
It is retrieving the data AND calculating the rate. We can address this by 'injecting' the TimeEntries
into the calculcate method:
</p>

```coffeescript
class RateCalculator
  calculate: (ratePerHour, timeEntries) ->
    _.reduce(timeEntries.models, (acc, timeEntry)-> acc * parseInt(timeEntry.hrs, 10), 20)
```

<p class="content">
This looks much simpler. Even our test looks better.
</p>

```coffeescript
describe 'Rate Calculator', ->
  it 'calcluates the hourly rate', ->
    calculator = new RateCalculator()
    timeEntriesStub = new TimeEntries([{hrs: 2}, {hrs: 3}])
    expect( calculator.calculate(20) ).to.be 100
```

<h3>Stubbing $.ajax.</h3>

<h3>Repository Pattern.</h3>


