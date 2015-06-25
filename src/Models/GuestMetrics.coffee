debug = require('debug') 'XenAPI:GuestMetrics'
Promise = require 'bluebird'

class GuestMetrics
  session = undefined
  xenAPI = undefined

  ###*
  * Construct GuestMetrics
  * @class
  * @param      {Object}   session - An instance of Session
  * @param      {Object}   guestmetrics - A JSON object representing this GuestMetrics
  * @param      {String}   opaqueRef - The OpaqueRef handle to this GuestMetrics
  * @param      {Object}   xenAPI - An instance of XenAPI
  ###
  constructor: (_session, _guestmetrics, _opaqueRef, _xenAPI) ->
    debug "constructor()"
    debug _guestmetrics, _opaqueRef

    unless _session
      throw Error "Must provide `session`"
    unless _guestmetrics
      throw Error "Must provide `guestmetrics`"
    unless _opaqueRef
      throw Error "Must provide `opaqueRef`"

    #These can safely go into class scope because there is only one instance of each.
    session = _session
    xenAPI = _xenAPI

    @opaqueRef = _opaqueRef
    @uuid = _guestmetrics.uuid
    @networks = _guestmetrics.networks
    @os_version = _guestmetrics.os_version
    @memory = _guestmetrics.memory
    @disks = _guestmetrics.disks
    @last_updated = _guestmetrics.last_updated

module.exports = GuestMetrics
