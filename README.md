node-xenapi
----

Usage
====

```
var xenapi = require("xenapi2")({
	host: "xen-server",
	port: "80"
});

xenapi.session.login("username", "password")
	.then(function () {
		xenapi.vmCollection.list().then(function (vms) {
			console.log(vms);
		});
	});
```
