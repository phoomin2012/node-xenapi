(function () {
    var Promise, Snapshot, _, debug,
        bind = function (fn, me) { return function () { return fn.apply(me, arguments); }; };

    debug = require('debug')('XenAPI:Snapshot');

    Promise = require('bluebird');

    _ = require('lodash');

    Snapshot = (function () {
        var session, xenAPI;

        session = void 0;

        xenAPI = void 0;


        /**
        * Construct Snapshot. Very similar to a VM, but not yet set up.
        * @class
        * @param      {Object}   session - An instance of Session
        * @param      {Object}   snapshot - A JSON object representing this Snapshot
        * @param      {String}   opaqueRef - The OpaqueRef handle to this snapshot
        * @param      {Object}   xenAPI - An instance of XenAPI.
         */

        function Snapshot(_session, _snapshot, _opaqueRef, _xenAPI) {
            this.getVBDs = bind(this.getVBDs, this);
            this.provision = bind(this.provision, this);
            this.pushOtherConfig = bind(this.pushOtherConfig, this);
            this.clone = bind(this.clone, this);
            this.rename = bind(this.rename, this);
            this.destroy = bind(this.destroy, this);
            this.toJSON = bind(this.toJSON, this);
            debug("constructor()");
            debug(_snapshot, _opaqueRef);
            if (!_session) {
                throw Error("Must provide `session`");
            }
            if (!_snapshot) {
                throw Error("Must provide `snapshot`");
            }
            if (!_opaqueRef) {
                throw Error("Must provide `opaqueRef`");
            }
            if (!_xenAPI) {
                throw Error("Must provide `xenAPI`");
            }
            if (!(_snapshot.is_a_snapshot && !_snapshot.is_control_domain && _snapshot.uuid)) {
                throw Error("`snapshot` does not describe a valid Snapshot");
            }
            session = _session;
            xenAPI = _xenAPI;
            this.opaqueRef = String(_opaqueRef);
            this.uuid = String(_snapshot.uuid);
            this.name = _snapshot.name_label;
            this.description = _snapshot.name_description;
            this.VIFs = _snapshot.VIFs || [];
            this.VBDs = _snapshot.VBDs || [];
            this.other_config = _snapshot.other_config;
            this.ram_minimum = _snapshot.memory_static_max;
            this.vcpu_minimum = _snapshot.VCPUs_max;
            this.is_snapshot = _snapshot.is_a_snapshot;
            this.is_template = _snapshot.is_template;
        }

        Snapshot.prototype.toJSON = function () {
            return {
                opaqueRef: this.opaqueRef,
                uuid: this.uuid,
                name: this.name,
                description: this.description,
                VIFs: this.VIFs,
                VBDs: this.VBDs,
                other_config: this.other_config,
                ram_minimum: this.ram_minimum,
                vcpu_minimum: this.vcpu_minimum,
                is_snapshot: this.is_snapshot,
                is_template: this.is_template,
            };
        };

        Snapshot.prototype.destroy = function () {
            debug("destroy()");
            return new Promise((function (_this) {
                return function (resolve, reject) {
                    return session.request("VM.destroy", [_this.opaqueRef]).then(function (value) {
                        return resolve();
                    })["catch"](function (e) {
                        debug(e);
                        return reject(e);
                    });
                };
            })(this));
        };

        Snapshot.prototype.rename = function (name) {
            debug("rename(" + name + ")");
            return new Promise((function (_this) {
                return function (resolve, reject) {
                    return session.request("VM.set_name_label", [_this.opaqueRef, name]).then(function (value) {
                        return resolve();
                    })["catch"](function (e) {
                        debug(e);
                        return reject(e);
                    });
                };
            })(this));
        };


        /**
         * Clone this Snapshot, creates a new Snapshot
         * @param     {String}  name - A name for the new clone
         * @return    {Promise}
         */

        Snapshot.prototype.clone = function (name) {
            debug("clone()");
            return new Promise((function (_this) {
                return function (resolve, reject) {
                    if (!name) {
                        return reject("Must provide a name for the clone");
                    } else {
                        return session.request("VM.clone", [_this.opaqueRef, name]).then(function (value) {
                            debug(value);
                            return xenAPI.snapshotCollection.findOpaqueRef(value).then(function (clonedSnapshot) {
                                return resolve(clonedSnapshot);
                            });
                        })["catch"](function (e) {
                            debug(e);
                            return reject(e);
                        });
                    }
                };
            })(this));
        };

        Snapshot.prototype.pushOtherConfig = function () {
            debug("pushOtherConfig()");
            return new Promise((function (_this) {
                return function (resolve, reject) {
                    return session.request("VM.set_other_config", [_this.opaqueRef, _this.other_config]).then(function (value) {
                        debug(value);
                        return resolve();
                    })["catch"](function (e) {
                        debug(e);
                        return reject(e);
                    });
                };
            })(this));
        };

        Snapshot.prototype.provision = function () {
            debug("provision()");
            return new Promise((function (_this) {
                return function (resolve, reject) {
                    return session.request("VM.provision", [_this.opaqueRef]).then(function (value) {
                        debug(value);
                        return xenAPI.vmCollection.findOpaqueRef(_this.opaqueRef).then(function (vm) {
                            return resolve(vm);
                        });
                    })["catch"](function (e) {
                        debug(e);
                        return reject(e);
                    });
                };
            })(this));
        };

        Snapshot.prototype.getVBDs = function () {
            debug("getVBDs()");
            return new Promise((function (_this) {
                return function (resolve, reject) {
                    var vbdSearchPromises;
                    vbdSearchPromises = [];
                    _.each(_this.VBDs, function (vbd) {
                        var vbdSearchPromise;
                        vbdSearchPromise = xenAPI.vbdCollection.findOpaqueRef(vbd);
                        return vbdSearchPromises.push(vbdSearchPromise);
                    });
                    return Promise.all(vbdSearchPromises).then(function (vbdObjects) {
                        debug(vbdObjects);
                        return resolve(vbdObjects);
                    })["catch"](function (e) {
                        debug(e);
                        return reject(e);
                    });
                };
            })(this));
        };

        return Snapshot;

    })();

    module.exports = Snapshot;

}).call(this);
