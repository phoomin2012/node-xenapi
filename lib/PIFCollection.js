// Generated by CoffeeScript 1.10.0
(function() {
  var PIFCollection, Promise, _, debug, minimatch,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  debug = require('debug')('XenAPI:PIFCollection');

  Promise = require('bluebird');

  minimatch = require('minimatch');

  _ = require('lodash');

  PIFCollection = (function() {
    var PIF, createPIFInstance, session, xenAPI;

    PIF = void 0;

    session = void 0;

    xenAPI = void 0;

    createPIFInstance = function(PIF, opaqueRef) {
      if (!(PIF.other_config && (PIF.other_config.is_guest_installer_network || PIF.other_config.is_host_internal_management_network))) {
        return new PIF(session, PIF, opaqueRef, xenAPI);
      }
    };


    /**
    * Construct PIFCollection
    * @class
    * @param      {Object}   session - An instance of Session
    * @param      {Object}   PIF - Dependency injection of the PIF class.
    * @param      {Object}   xenAPI - An instance of XenAPI
     */

    function PIFCollection(_session, _PIF, _xenAPI) {
      this.findUUID = bind(this.findUUID, this);
      this.findNamed = bind(this.findNamed, this);
      this.list = bind(this.list, this);
      debug("constructor()");
      if (!_session) {
        throw Error("Must provide session");
      }
      if (!_PIF) {
        throw Error("Must provide PIF");
      }
      if (!_xenAPI) {
        throw Error("Must provide xenAPI");
      }
      session = _session;
      xenAPI = _xenAPI;
      PIF = _PIF;
    }


    /**
     * List all PIFs
     * @return     {Promise}
     */

    PIFCollection.prototype.list = function() {
      debug("list()");
      return new Promise((function(_this) {
        return function(resolve, reject) {
          return session.request("PIF.get_all_records").then(function(value) {
            var PIFs;
            if (!value) {
              reject();
            }
            debug("Received " + (Object.keys(value).length) + " records");
            PIFs = _.map(value, createPIFInstance);
            return resolve(_.filter(PIFs, function(PIF) {
              return PIF;
            }));
          })["catch"](function(e) {
            debug(e);
            return reject(e);
          });
        };
      })(this));
    };

    PIFCollection.prototype.findNamed = function(name) {
      debug("findNamed(" + name + ")");
      return new Promise((function(_this) {
        return function(resolve, reject) {
          return _this.list().then(function(PIFs) {
            var matchPIFName, matches;
            matchPIFName = function(PIF) {
              if (minimatch(PIF.name, name, {
                nocase: true
              })) {
                return PIF;
              }
            };
            matches = _.map(PIFs, matchPIFName);
            return resolve(_.filter(matches, function(PIF) {
              return PIF;
            }));
          })["catch"](function(e) {
            debug(e);
            return reject(e);
          });
        };
      })(this));
    };

    PIFCollection.prototype.findUUID = function(uuid) {
      debug("findUUID(" + uuid);
      return new Promise((function(_this) {
        return function(resolve, reject) {
          return _this.list().then(function(PIFs) {
            var filtered, matchPIFUuid, matches;
            matchPIFUuid = function(PIF) {
              if (PIF.uuid === uuid) {
                return PIF;
              }
            };
            matches = _.map(PIFs, matchPIFUuid);
            filtered = _.filter(matches, function(PIF) {
              return PIF;
            });
            if (filtered.length > 1) {
              return reject("Multiple PIFs for UUID " + uuid);
            } else {
              return resolve(filtered[0]);
            }
          })["catch"](function(e) {
            debug(e);
            return reject(e);
          });
        };
      })(this));
    };

    return PIFCollection;

  })();

  module.exports = PIFCollection;

}).call(this);
