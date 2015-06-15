debug = require('debug') 'XenAPI:GuestMetricsCollection'
Promise = require 'bluebird'
minimatch = require 'minimatch'
_ = require 'lodash'

class GuestMetricsCollection
  GuestMetrics = undefined
  session = undefined
  xenAPI = undefined

  createGuestMetricsInstance = (guestmetrics, opaqueRef) =>
    return new GuestMetrics session, guestmetrics, opaqueRef, xenAPI

  ###*
  * Construct GuestMetricsCollection
  * @class
  * @param      {Object}   session - An instance of Session
  * @param      {Object}   GuestMetrics - Dependency injection of the GuestMetrics class.
  * @param      {Object}   xenAPI - An instance of XenAPI
  ###
  constructor: (_session, _guestMetrics, _xenAPI) ->
    debug "constructor()"
    unless _session
      throw Error "Must provide session"
    unless _guestMetrics
      throw Error "Must provide GuestMetrics"
    unless _xenAPI
      throw Error "Must provide xenAPI"

    #These can safely go into shared class scope because this constructor is only called once.
    session = _session
    xenAPI = _xenAPI
    GuestMetrics = _guestMetrics

  ###*
  * List all GuestMetrics
  * @return     {Promise}
  ###
  list: =>
    debug "list()"
    new Promise (resolve, reject) =>
      session.request("VM_guest_metrics.get_all_records").then (value) =>
        unless value
          reject()

        debug "Received #{Object.keys(value).length} records"

        GuestMetrics = _.map value, createGuestMetricsInstance
        resolve _.filter GuestMetrics, (guestmetrics) -> guestmetrics
      .catch (e) ->
        debug e
        reject e

  findUUID: (uuid) =>
    debug "findUUID(#{uuid}"
    new Promise (resolve, reject) =>
      @list().then (GuestMetrics) =>
        matchGuestMetricsuuid = (guestmetrics) ->
          if guestmetrics.uuid == uuid
            return guestmetrics

        matches = _.map GuestMetrics, matchGuestMetricsuuid
        resolve _.filter matches, (guestmetrics) -> guestmetrics
      .catch (e) ->
        debug e
        reject e

  findOpaqueRef: (opaqueRef) =>
    debug "findOpaqueRef(#{opaqueRef})"
    new Promise (resolve, reject) =>
      session.request("VM_guest_metrics.get_record", [opaqueRef]).then (value) =>
        unless value
          reject()

        template = createGuestMetricsInstance value, opaqueRef
        resolve template
      .catch (e) ->
        debug e
        reject e

module.exports = GuestMetricsCollection
