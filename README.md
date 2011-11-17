Rump
----

Rump is a rendez-vous server inspired by Bump. Rump matches meeting
request by grouping incoming requests within 3 seconds. 

Location and URL based grouping is on the way...

Protocol
========

POST /<context>

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
