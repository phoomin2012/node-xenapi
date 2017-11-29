node-xenapi
----

Usage
====

```javascript
var xenapi = require("xenapi3")({
	host: "xen-server",
	port: "80"
});

// Example get list of VM
xenapi.session.login("username", "password")
	.then(function () {
		xenapi.vmCollection.list().then(function (vms) {
			console.log(vms);
		});
	});
```
