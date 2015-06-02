debug = require('debug') 'XenAPI:SR'
Promise = require 'bluebird'

class SR
  session = undefined
  xenAPI = undefined

  ###*
  * Construct SR
  * @class
  * @param      {Object}   session - An instance of Session
  * @param      {Object}   sr - A JSON object representing this SR
  * @param      {String}   opaqueRef - The OpaqueRef handle to this SR
  * @param      {Object}   xenAPI - An instance of XenAPI
  ###
  constructor: (_session, _sr, _opaqueRef, _xenAPI) ->
    debug "constructor()"
    debug _sr, _opaqueRef

    unless _session
      throw Error "Must provide `session`"
    unless _sr
      throw Error "Must provide `sr`"
    unless _opaqueRef
      throw Error "Must provide `opaqueRef`"

    #These can safely go into class scope because there is only one instance of each.
    session = _session
    xenAPI = _xenAPI

    @opaqueRef = _opaqueRef
    @uuid = _sr.uuid
    @name = _sr.name_label
    @description = _sr.name_description
    @allowed_operations = _sr.allowed_operations
    @current_operations = _sr.current_operations
    @VDIs = _sr.VDIs
    @PBDs = _sr.PBDs
    @physical_utilisation = _sr.physical_utilisation
    @physical_size = _sr.physical_size
    @unused_space = _sr.physical_size - _sr.physical_utilisation

  scan: =>
    debug "scan()"
    new Promise (resolve, reject) =>
      session.request("SR.scan", [@opaqueRef]).then (value) =>
        resolve()
      .catch (e) ->
        debug e
        reject e

module.exports = SR
