---
title: "Testing XHR in Backbone using a Repository and Promises"
author:
  name: "Roberto Guerra"
---

<p class="content">
<h3>Stubbing Backbone's fetch().</h3>
When we need to test a part of our application that fetches data
from a server, we will want to avoid making that request so as 
not to slow down our tests; and because that endpoint might not
be implemented yet. Besides, we are focusing on unit tests, and they
should only test individual indpendent units. If our test makes an external
request, then it stops being a unit test and starts to venture into
the realm of integration or functional tests.
</p>

Let's consider the following code:

```coffeescript
class RateCalculator
  calculate: (ratePerHour) ->
    timeEntries = new TimeEntries()
    timeEntries.fetch()
    _.reduce(timeEntries.models, (acc, timeEntry)-> acc * parseInt(timeEntry.hrs, 10), 20)
```

This method calculates the total rate based on how many hours worked and the hourly rate. The hours is fetched via
an XHR request. Testing this can be a little challenging, but not impossible. We can use sinon to stub
the collection's `fetch` function:

```coffeescript
describe 'Rate Calculator', ->
  it 'calculates the hourly rate', ->
    calculator = new RateCalculator()
    timeEntriesStub = sinon.stub(TimeEntries::, 'fetch').returns(new TimeEntries([{hrs: 2}, {hrs: 3}]))
    expect( calculator.calculate(20) ).to.be 100
    timeEntriesStub.restore()
```

While this will work, there are a couple things that should bother us. First, the RateCalculator
is tightly coupled to TimeEntries collection; but most importantly, the RateCalculator is doing too much.
It is retrieving the data AND calculating the rate. We can address this by 'injecting' the TimeEntries
into the calculate method:

```coffeescript
class RateCalculator
  calculate: (ratePerHour, timeEntries) ->
    _.reduce(timeEntries.models, (acc, timeEntry)-> acc * parseInt(timeEntry.hrs, 10), 20)
```

This looks much simpler. Even our test looks better.

```coffeescript
describe 'Rate Calculator', ->
  it 'calculates the hourly rate', ->
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
  it 'calculates the hourly rate', ->
    rateController = new RateController()
    timeEntriesStub = sinon.stub(TimeEntries::, 'fetch').returns(new TimeEntries([{hrs: 2}, {hrs: 3}]))
    expect( rateCalculator.onSubmitButton() ).to.be 100
    timeEntriesStub.restore()
```

If we need to use RateCalculator in other parts of our application, we will duplicate this in many places
and lose track of it. Why is this bad again? Because it couples our application to Backbone and creates
some unmaintainable code. It will be difficult to change this if we ever decide that maybe Backbone is not
the right choice, or if our TimeEntries is a more complex collection

We can solve this by injecting the collection, like we did in the first scenario, and it is the route
I would take; but we will reach a point where passing the collection like a hot potato will not save us,
and we will have to deal with this situation head on.

And what about situations where we would want to trigger an action when a new set of collections is fetched?
Or maybe we have a real-time dashboard that needs to get updated on near real time everytime some event
happens somewhere else (even on a remote computer or server)? How we handle error messages for all xhr requests?

What about scenarios where the xhr response does not fit nicely with our collections and entities? For example, 
suppose we need to request data about 'things to do' and the structure of that data returned is something like:

```json
{
venues: [{name: 'Venue A', qty: 10},
        {name: 'Venue B', qty: 65},
        {name: 'Venue C', qty: 31}
        ],
dates: [{when: 'Today', qty: 7},
        {when: 'Tomorrow', qty: 13},
        {when: 'Friday', qty: 41}
      ]
thingsToDo: [{name: 'Concert A', date: '2014-01-31 20:00'},
            {name: 'Comedy Club', date: '2014-01-31 19:00'}
            ......
            ]
rel:[{currentPage: 'http://some.domain/2/20'},
      {nextPage: 'http://some.domain/3/20'},
      {previousPage: 'http://some.domain/1/20'}
  ]
```

###Repository Pattern.
If we step back for a bit, and imagine our application as a vulnerable kernel that needs to be shielded from any
outside infection, then we can see how allowing direct calls to Backbone.Collection#fetch() deep in our application
exposes it to external factors. Changes to the Backbone API can require massive changes deep in our application's
kernel.

We can take some inspiration from the ['Hexagonal Architecture'](http://alistair.cockburn.us/Hexagonal+architecture) to help us come up with a 'cleaner' solution.
In order to access any external system (like xhr requests), we need to add an interface for it.

We might want to start by defining the interface:

```coffeescript
describe 'Time Entry Repository', ->
  describe 'Configure the end points'
    it 'When end points are not uniform', ->
      repository = new TimeEntryRepository
        get:  '...'
        post: '...'
        put:  '...'
        list: '...'
      expect( repository.getURL() ).to.be '...'
      expect( repository.postURL() ).to.be '...'
      expect( repository.putURL() ).to.be '...'
      expect( repository.listURL() ).to.be '...'
    it 'When end points are uniform', ->
      repository = new TimeEntryRepository
        all:  '...'
      expect( repository.getURL() ).to.be '...'
      expect( repository.postURL() ).to.be '...'
      expect( repository.putURL() ).to.be '...'
      expect( repository.listURL() ).to.be '...'
```

Our repository makes provisions for cases where the url does not fit nicely with Backbone's
expectations. Backbone expects all urls to be the same and the only thing that changes
is the http verb. There might be cases where that is not possible.


####Fetch API
Now we can specify how we will fetch data from the server:

```coffeescript
describe 'Time Entry Repository', ->
  describe 'Fetch API', ->
    describe 'When it fetches data from remote server', ->
      it 'then makes an xhr request', ->
        xhrMock = sinon.mock($, 'ajax').returns({})
        repository = new TimeEntryRepository()
        repository.all('http://a.url/timeEntries')
        expect(xhr.calledOnce).to.be true
        xhrMock.restore()
```

This test only needs to ensure that an xhr request is made with jquery. It is testing the 
repository's internal implementation, which consequently makes it very fragile. However, an object like
this lives in the periphery of an application and for them these kinds of tests are common. We will later
see how it makes our domain logic much cleaner. In the meantime, we can make this test pass:

```coffeescript
class TimeRepository
  all: (url) ->
    @_listUrl = url
    @_getUrl = url
    ...

  listUrl: ->
    @_listUrl

  fetch: ->
    $.ajax(url: @listUrl())
```

Our fetch function could have also used a backbone collection. The clients using the repository won't know
nor need to know how it is implemented. But this still looks a little wonky. We haven't gotten anything benefits
from it... yet. 

Now lets consider a scenario where we'd like to `promisify` our interface:

```coffeescript
describe 'When it fetches data from remote server', ->
  it 'then it returns a promise', (done)->
    xhrMock = sinon.stub($, 'ajax').returns([1,2,3,4,5])
    repository = new TimeEntryRepository()
    repository
      .all('http://a.url/timeEntries')
      then(timeEntries) ->
        expect(timeEntries.length).to.be 5
        done()
    xhrMock.restore()
```

This is a contrived example, but bear with me for a while. We return an array of 5 items and we need to tell
mocha that this is an async test. We do this by passing `done` as an argument to the test and then invoking
`done()` to notify mocha that the async test has finished. We can then make assertions on the value of the
promise. Our specs now start to look more like production code. The only inconvenience at the moment is
creating some fake data. But we can live with that. Much better than coupling all our tests (and production
code to jquery). And we don't need to change anything in our code to make this pass because $.ajax() returns
a promise.

This is okay for very simple cases, but what if we need to return something with behavior (an instance of an object):

```coffeescript
describe 'When it fetches data from remote server', ->
  it 'then it returns a promise', (done)->
    xhrMock = sinon.stub($, 'ajax').returns([1,2,3,4,5])
    repository = new TimeEntryRepository()
    repository
      .all('http://a.url/timeEntries')
      then(timeEntries) ->
        expect(timeEntries instanceof TimeEntries).to.be true
        done()
    xhrMock.restore()
```

Implementing this wouldn't be so difficult:

```coffeescript
fetch: ->
  promise = Q.when($.ajax(url: @listUrl()))
  promise.then (response) =>
    new TimeEntries(response)
```

We introduced the Q library for dealing with promises (a matter of personal preference). Our clients don't need
to know what library is being used, they just need to know its a Promises/A+ compatiable library. So we should be
able to substitute the Q library for Bluebird if we need to and any client of this class won't need to change.


####Notifications
We can now even start introducing custom events that our application can listen to. An event for fetching data, or
for creating a new entity, deleting one or updating one; can be triggered for any part of our application to
listen to:

```coffeescript
describe 'Time Entry Repository', ->
  beforeEach ->
    @caughtEvent = false
    @aRemoteObject =
      listen: (repository) =>
        repository.onFetch =>
          @caughtEvent = true
          
  it 'Trigger an event when entries are fetched', (done)->
    repository = new TimeEntryRepository()
    repository.all('http://a.url/timeEntries')
    xhrStub = sinon.stub($, 'ajax').returns([1,2,3,4,5])
    @aRemoteObject.listen(repository)
    repository.fetch()
    expect( @caughtEvent ).to.be true
    xhrStub.restore()

```

```coffeescript
class TimeEntryRepository
  constructor: ->
    @vent = _.extend {}, Backbone.Events

  onFetch: (callback) ->
    @vent.on 'fetched', callback

  fetch: ->
    promise = Q.when($.ajax(url: @listUrl()))
    promise.then (response) =>
      timeEntries = new TimeEntries(response)
      @vent.trigger 'fetched', timeEntries

```

Now any part of our application can listen directly for any events triggered by the repository and execute
a function accordingly. This enables us to update different parts of our UI independent of each other. We can
also test those parts our application pretty easily by just triggering the event without needing to wire up
the entire repository:

```coffeescript
repository.vent.trigger 'fetched'
```

In some cases, we might only need to create some fake time entries, but that is to be expected.

####Handling Network Failures
This strategy can also enable us to handle network errors in a generic manner. If our app is a single
page app that is expected to be kept running on the browser for long periods of time (even days or weeks),
whenever the network is down or an xhr request failed for some other reason, we should be able to notify the user.
Although we can do this with Backbone by overriding _sync_, it feels like a hack and I am always wary of 
overriding third party libraries.

To handle network failures for all xhr requests we would either need to implement that code in every repository,
or use inheritance (or mixins also). We'll use inheritance in this case since it is something only 
repositories will need to do:

```coffeescript
describe 'Time Entry Repository', ->
  beforeEach ->
    @handledError = false
    @errorHandlingFn = -> @handledError = true
          
  it 'Handles XHR errors', (done)->
    repository = new TimeEntryRepository()
    repository.all('http://a.url/timeEntries')
    deferred = Q.defer()
    xhrStub = sinon.stub($, 'ajax').returns(deferred)
    repository
      .fetch()
      .then( -> console.log 'Success'
      , @handleError)
    deferred.reject()
    expect( @handledError ).to.be true
    xhrStub.restore()

```

We can handle errors with promises by passing in a function as an error handler to the _then()_ method.
We could also have an application event bus which we can notify of any errors from within this error handler:

```coffeescript
repository
  .fetch()
  .then(null, (error)-> app.eventBus.trigger 'network:error')

...
app.eventBus.on  'network:error', showErrorMessage
```

###Conclusion
We can use the Repository Pattern to decouple our application from any framework specific code that can
make our application hard to test. As a secondary benefit, our objects become more focused by having only
one primary reason to change if all they do is just concern themselves with fetching and sending data.
Promises can also be used to make our code more readable when dealing with async operations. They also help
us deal with error handling in an elegant manner. Finally, the use of a messaging pattern and an event bus
helps us keep the components of our application decoupled by enabling us to send messages to remote objects
without having to hold a direct reference to them. We can then test these objects in isolation without
having to wire up a large object graph.

