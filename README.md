Ejabberd 17.01 module to send offline user's message via POST request to target URL.
The main motivation for this module is to use it with push notifications. 
The request body is in application/x-www-form-urlencoded format. See the example below.

Forked from Nimrodda/mod_offline_http_post ejabberd 16.08

Installation
------------

1. cd /var/lib/ejabberd/.ejabberd-modules/sources/
2. git clone https://github.com/PH-F/mod_offline_http_post.git;
3. bash /var/ejabberd-17.01/bin/ejabberdctl module-install mod_offline_http_post
4. /etc/init.d/ejabberd restart;

That's it. The module is now installed.

Configuration
-------------

Add the following to ejabberd configuration under `modules:`

```
mod_offline_http_post:
    auth_token: "secret"
    post_url: "http://example.com/notify"
```

-    auth_token - user defined, hard coded token that will be sent as part of the request's body. Use this token on the target server to validate that the request arrived from a trusted source.
-    post_url - the server's endpoint url

Example of the outgoing request:
--------------------------------

```
array(5) {
  ["to"]=>
  string(11) "testuser"
  ["from"]=>
  string(7) "patrick"
  ["vhost"]=>
  string(16) "server.myserver.nl"
  ["body"]=>
  string(7) "This is a testmessage"
  ["messageId"]=>
  string(13) "purple3838f2f"
}
```

