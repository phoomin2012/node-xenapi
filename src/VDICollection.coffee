debug = require('debug') 'XenAPI:VDICollection'
Promise = require 'bluebird'
_ = require 'lodash'

class VDICollection
  session = undefined
  VDI = undefined
  xenAPI = undefined

  ###*
  * Construct VDICollection
  * @class
  * @param      {Object}   session - An instance of Session
  * @param      {Object}   VDI - Dependency injection of the VBD class.
  ###
  constructor: (_session, _VDI, _xenAPI) ->
    debug "constructor()"
    unless _session
      throw Error "Must provide session"
    unless _VDI
      throw Error "Must provide VDI"
    unless _xenAPI
      throw Error "Must provide xenAPI"

    session = _session
    VDI = _VDI
    xenAPI = _xenAPI

  ###*
  * List all VDIs
  * @return     {Promise}
  ###
  list: =>
    debug "list()"
    new Promise (resolve, reject) =>
      session.request("VDI.get_all_records").then (value) =>
        unless value
          reject()

        debug "Received #{Object.keys(value).length} records"
        createVDIInstance = (vdi, key) =>
          return new VDI session, vdi, key, xenAPI

        VDIs = _.map value, createVDIInstance
        resolve _.filter VDIs, (vdi) -> vdi
      .catch (e) ->
        debug e
        reject e

  findSR: (SR) =>
    debug "findSR(#{SR})"
    new Promise (resolve, reject) =>
      @list().then (VDIs) =>
        vdiOnSR = (vdi) ->
          if vdi.SR == SR
            return vdi

        matches = _.map VDIs, vdiOnSR
        resolve _.filter matches, (vdi) -> vdi
      .catch (e) ->
        debug e
        reject e
    .catch (e) ->
      debug e
      reject e

module.exports = VDICollection
