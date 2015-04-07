debug = require('debug') 'XenAPI:VDICollection'
Promise = require 'bluebird'
minimatch = require 'minimatch'
_ = require 'lodash'

class VDICollection
  VDI = undefined
  session = undefined
  xenAPI = undefined

  createVDIInstance = (vdi, opaqueRef) =>
    return new VDI session, vdi, opaqueRef, xenAPI

  ###*
  * Construct VDICollection
  * @class
  * @param      {Object}   session - An instance of Session
  * @param      {Object}   VDI - Dependency injection of the VBD class.
  * @param      {Object}   xenAPI - An instance of XenAPI
  ###
  constructor: (_session, _VDI, _xenAPI) ->
    debug "constructor()"
    unless _session
      throw Error "Must provide session"
    unless _VDI
      throw Error "Must provide VDI"
    unless _xenAPI
      throw Error "Must provide xenAPI"

    #These can safely go into shared class scope because this constructor is only called once.
    session = _session
    xenAPI = _xenAPI
    VDI = _VDI

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
