debug = require('debug') 'XenAPI:Metrics'
Promise = require 'bluebird'

class Metrics
  session = undefined
  xenAPI = undefined

  ###*
  * Construct Metrics
  * @class
  * @param      {Object}   session - An instance of Session
  * @param      {Object}   metrics - A JSON object representing this Metrics
  * @param      {String}   opaqueRef - The OpaqueRef handle to this Metrics
  * @param      {Object}   xenAPI - An instance of XenAPI
  ###
  constructor: (_session, _metrics, _opaqueRef, _xenAPI) ->
    debug "constructor()"
    debug _metrics, _opaqueRef

    unless _session
      throw Error "Must provide `session`"
    unless _metrics
      throw Error "Must provide `metrics`"
    unless _opaqueRef
      throw Error "Must provide `opaqueRef`"

    #These can safely go into class scope because there is only one instance of each.
    session = _session
    xenAPI = _xenAPI

    @opaqueRef = _opaqueRef
    @uuid = _metrics.uuid
    @memory_actual = _metrics.memory_actual
    @start_time = _metrics.start_time
    @VCPUs_number = _metrics.VCPUs_number


module.exports = Metrics
