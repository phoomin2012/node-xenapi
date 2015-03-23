// Generated by CoffeeScript 1.8.0
(function() {
  var Promise, VM, debug,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  debug = require('debug')('XenAPI:VM');

  Promise = require('bluebird');

  VM = (function() {
    var key, session, vm;

    key = void 0;

    session = void 0;

    vm = void 0;


    /**
    	* Construct VM
    	* @class
    	* @param      {Object}   session - An instance of Session
    	* @param      {Object}   vm - A JSON object representing this VM
    	* @param      {String}   key - The OpaqueRef handle to this VM
     */

    function VM(_session, _vm, _key) {
      this.resume = __bind(this.resume, this);
      this.suspend = __bind(this.suspend, this);
      this.unpause = __bind(this.unpause, this);
      this.pause = __bind(this.pause, this);
      this.refreshPowerState = __bind(this.refreshPowerState, this);
      debug("constructor()");
      if (!_session) {
        throw Error("Must provide `session`");
      } else {
        session = _session;
      }
      if (!_vm) {
        throw Error("Must provide `vm`");
      }
      if (!(!_vm.is_a_template && !_vm.is_control_domain && _vm.uuid)) {
        throw Error("`vm` does not describe a valid VM");
      } else {
        vm = _vm;
      }
      if (!_key) {
        throw Error("Must provide `key`");
      } else {
        key = _key;
      }
      this.uuid = vm.uuid;
      this.name = vm.name_label;
      this.description = vm.name_description;
      this.xenToolsInstalled = !(vm.guest_metrics === 'OpaqueRef:NULL');
      this.powerState = vm.power_state;
      this.POWER_STATES = {
        HALTED: 'Halted',
        PAUSED: 'Paused',
        RUNNING: 'Running',
        SUSPENDED: 'Suspended'
      };
    }


    /**
    	 * Refresh the power state of this VM
    	 * @return     {Promise}
     */

    VM.prototype.refreshPowerState = function() {
      debug("refreshPowerState()");
      return new Promise((function(_this) {
        return function(resolve, reject) {
          return session.request("VM.get_power_state", [key]).then(function(value) {
            debug(value);
            _this.powerState = value;
            return resolve(value);
          })["catch"](function(e) {
            debug(e);
            return reject(e);
          });
        };
      })(this));
    };


    /**
    	 * Pause this VM. Can only be applied to VMs in the Running state.
    	 * @return     {Promise}
     */

    VM.prototype.pause = function() {
      debug("pause()");
      return new Promise((function(_this) {
        return function(resolve, reject) {
          return _this.refreshPowerState().then(function(currentPowerState) {
            if (currentPowerState !== _this.POWER_STATES.RUNNING) {
              return reject("VM not in " + _this.POWER_STATES.RUNNING + " power state.");
            } else {
              return session.request("VM.pause", [key]).then(function(value) {
                return resolve();
              })["catch"](function(e) {
                debug(e);
                return reject(e);
              });
            }
          })["catch"](function(e) {
            debug(e);
            return reject(e);
          });
        };
      })(this));
    };


    /**
    	 * Unpause this VM. Can only be applied to VMs in the Paused state.
    	 * @return     {Promise}
     */

    VM.prototype.unpause = function() {
      debug("unpause()");
      return new Promise((function(_this) {
        return function(resolve, reject) {
          return _this.refreshPowerState().then(function(currentPowerState) {
            if (currentPowerState !== _this.POWER_STATES.PAUSED) {
              return reject("VM not in " + _this.POWER_STATES.PAUSED + " power state.");
            } else {
              return session.request("VM.unpause", [key]).then(function(value) {
                return resolve();
              })["catch"](function(e) {
                debug(e);
                return reject(e);
              });
            }
          })["catch"](function(e) {
            debug(e);
            return reject(e);
          });
        };
      })(this));
    };


    /**
    	 * Suspend this VM. Can only be applied to VMs in the Running state.
    	 * @return     {Promise}
     */

    VM.prototype.suspend = function() {
      debug("suspend()");
      return new Promise((function(_this) {
        return function(resolve, reject) {
          return _this.refreshPowerState().then(function(currentPowerState) {
            if (currentPowerState !== _this.POWER_STATES.RUNNING) {
              return reject("VM not in " + _this.POWER_STATES.RUNNING + " power state.");
            } else {
              return session.request("VM.suspend", [key]).then(function(value) {
                return resolve();
              })["catch"](function(e) {
                debug(e);
                return reject(e);
              });
            }
          })["catch"](function(e) {
            debug(e);
            return reject(e);
          });
        };
      })(this));
    };


    /**
    	 * Resume this VM. Can only be applied to VMs in the Suspended state.
    	 * @return     {Promise}
     */

    VM.prototype.resume = function() {
      debug("resume()");
      return new Promise((function(_this) {
        return function(resolve, reject) {
          return _this.refreshPowerState().then(function(currentPowerState) {
            var force, startPaused;
            if (currentPowerState !== _this.POWER_STATES.SUSPENDED) {
              return reject("VM not in " + _this.POWER_STATES.SUSPENDED + " power state.");
            } else {
              startPaused = false;
              force = false;
              return session.request("VM.resume", [key, startPaused, force]).then(function(value) {
                return resolve();
              })["catch"](function(e) {
                debug(e);
                return reject(e);
              });
            }
          })["catch"](function(e) {
            debug(e);
            return reject(e);
          });
        };
      })(this));
    };

    return VM;

  })();

  module.exports = VM;

}).call(this);