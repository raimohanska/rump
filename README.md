Rump
====

Rump is a rendez-vous server for mobile clients, inspired by Bump. Rump matches meeting
request by grouping incoming requests within 3 seconds. 

Location and URL based grouping is on the way...

Installation
============

Install Haskell Platform

- OSX: brew install haskell-platform

Clone, build, install:

~~~ .bash
git clone git@github.com:raimohanska/rump.git
cd rump
cabal install
~~~

Run:

~~~ .bash
rump --port 9876
~~~

Test:

~~~ .bash
$ curl -d '{ "userId" : "john", "displayName" : "John Kennedy", "location": { "latitude": 51.0, "longitude": -0.1}}' localhost:9876/lol

[{"userId":"john","displayName":"John Kennedy","location":{"latitude":51,"longitude":-0.1}}]
~~~

Protocol
========

POST /yourservicenamehere

Request payload:

~~~ .json
 : { 
  "userId" : "jack", 
  "displayName" : "Jack Bauer", 
  "location": {
    "latitude": 51.0,
    "longitude": -0.1
  }
}
~~~

Response (if no match) :

~~~ .json
 []
~~~

Response (with matches):

~~~ .json
[
  { "userId" : "john", "displayName" : "John Kennedy", ... }
  { "userId" : "jack", "displayName" : "Jack Bauer", ... }
]
~~~
