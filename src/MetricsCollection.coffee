debug = require('debug') 'XenAPI:MetricsCollection'
Promise = require 'bluebird'
minimatch = require 'minimatch'
_ = require 'lodash'

class MetricsCollection
  Metrics = undefined
  session = undefined
  xenAPI = undefined

  createMetricsInstance = (metrics, opaqueRef) =>
    return new Metrics session, metrics, opaqueRef, xenAPI

  ###*
  * Construct MetricsCollection
  * @class
  * @param      {Object}   session - An instance of Session
  * @param      {Object}   Metrics - Dependency injection of the Metrics class.
  * @param      {Object}   xenAPI - An instance of XenAPI
  ###
  constructor: (_session, _metrics, _xenAPI) ->
    debug "constructor()"
    unless _session
      throw Error "Must provide session"
    unless _metrics
      throw Error "Must provide Metrics"
    unless _xenAPI
      throw Error "Must provide xenAPI"

    #These can safely go into shared class scope because this constructor is only called once.
    session = _session
    xenAPI = _xenAPI
    Metrics = _metrics

  ###*
  * List all Metrics
  * @return     {Promise}
  ###
  list: =>
    debug "list()"
    new Promise (resolve, reject) =>
      session.request("VM_metrics.get_all_records").then (value) =>
        unless value
          reject()

        debug "Received #{Object.keys(value).length} records"

        Metrics = _.map value, createMetricsInstance
        resolve _.filter Metrics, (metrics) -> metrics
      .catch (e) ->
        debug e
        reject e

  findUUID: (uuid) =>
    debug "findUUID(#{uuid}"
    new Promise (resolve, reject) =>
      query = 'field "uuid"="' + uuid + '"'
      session.request("VM_metrics.get_all_records_where", [query]).then (value) =>
        unless value
          reject()

        debug "Received #{Object.keys(value).length} records"

        Metrics = _.map value, createMetricsInstance
        filtered = _.filter Metrics, (metrics) -> metrics
        if filtered.length > 1
          reject("Multiple Metrics for UUID #{uuid}")
        else
          resolve filtered[0]
      .catch (e) ->
        debug e
        reject e

  findOpaqueRef: (opaqueRef) =>
    debug "findOpaqueRef(#{opaqueRef})"
    new Promise (resolve, reject) =>
      session.request("VM_metrics.get_record", [opaqueRef]).then (value) =>
        unless value
          reject()

        metric = createMetricsInstance value, opaqueRef
        resolve metric
      .catch (e) ->
        debug e
        reject e

module.exports = MetricsCollection
