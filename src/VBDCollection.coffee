debug = require('debug') 'XenAPI:VBDCollection'
Promise = require 'bluebird'
_ = require 'lodash'

class VBDCollection
  session = undefined
  VBD = undefined
  xenAPI = undefined

  ###*
  * Construct VBDCollection
  * @class
  * @param      {Object}   session - An instance of Session
  * @param      {Object}   VBD - Dependency injection of the VBD class.
  ###
  constructor: (_session, _VBD, _xenAPI) ->
    debug "constructor()"
    unless _session
      throw Error "Must provide session"
    unless _VBD
      throw Error "Must provide VBD"
    unless _xenAPI
      throw Error "Must provide xenAPI"

    session = _session
    VBD = _VBD
    xenAPI = _xenAPI

  ###*
  * List all VBDs
  * @return     {Promise}
  ###
  list: =>
    debug "list()"
    new Promise (resolve, reject) =>
      session.request("VBD.get_all_records").then (value) =>
        unless value
          reject()

        debug "Received #{Object.keys(value).length} records"
        createVBDInstance = (vbd, key) =>
          debug vbd

        VBDs = _.map value, createVBDInstance
        resolve _.filter VBDs, (vbd) -> vbd
      .catch (e) ->
        debug e
        reject e

  create: (vm) =>
    debug "create()"

    new Promise (resolve, reject) =>
      vbd =
        VM: vm.getOpaqueRef(),
        VDI: "OpaqueRef:NULL",
        userdevice: "3",
        mode: VBD.MODES.RO,
        type: VBD.TYPES.CD,
        empty: true

      newVBD = new VBD session, vbd, "OpaqueRef:NULL"

      resolve newVBD

module.exports = VBDCollection
