xenapi3
----
This module is add the missing api of xenapi2


Usage
====
```javascript
const xenapi = require("xenapi3-fix")({
	host: "xen-server",
	port: "80"
});

// Example get list of VM
xenapi.session.login("username", "password").then(function () {
	xenapi.vmCollection.list().then(function (vms) {
		console.log(vms);
	});
});
```

Document
====
```javascript
	xenAPI.host;
	xenAPI.consoleCollection;
	xenAPI.guestMetricsCollection;
	xenAPI.metricsCollection;
	xenAPI.networkCollection;
	xenAPI.poolCollection;
	xenAPI.srCollection;
	xenAPI.taskCollection;
	xenAPI.templateCollection;
	xenAPI.vbdCollection;
	xenAPI.vdiCollection;
	xenAPI.vifCollection;
	xenAPI.vlanCollection;
	xenAPI.vmCollection;

```
More comming soon...

Donate
====
https://paypal.me/PhuminShop