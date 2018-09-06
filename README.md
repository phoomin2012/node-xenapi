xenapi3
----
This module is add the missing api of xenapi2


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
