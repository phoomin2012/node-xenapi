debug = require('debug') 'XenAPI:VBD'
Promise = require 'bluebird'

class VBD
  key = undefined
  session = undefined
  vbd = undefined
  xenAPI = undefined

  ###*
  * Construct VBD.
  * @class
  * @param      {Object}   session - An instance of Session
  * @param      {Object}   vbd - A JSON object representing this VBD
  * @param      {String}   key - The OpaqueRef handle to this vbd
  ###
  constructor: (_session, _vbd, _key, _xenAPI) ->
    debug "constructor()"
    debug _vbd
    unless _session
      throw Error "Must provide `session`"
    unless _vbd
      throw Error "Must provide `vbd`"
    unless _key
      throw Error "Must provide `key`"

    session = _session
    vbd = _vbd
    key = _key
    xenAPI = _xenAPI

    @uuid = vbd.uuid
    @VM = vbd.VM
    @VDI = vbd.VDI
    @userdevice = vbd.userdevice
    @mode = vbd.mode
    @type = vbd.type
    @empty = vbd.empty

  toJSON: =>
    {
      VM: @VM,
      VDI: @VDI,
      userdevice: @userdevice,
      mode: @mode,
      type: @type,
      empty: @empty,
      bootable: true,
      other_config: {},
      qos_algorithm_type: "",
      qos_algorithm_params: {}
    }

  insert: (vdi) =>
    new Promise (resolve, reject) =>
      session.request("VBD.insert", [key, vdi]).then (value) =>
        debug value
        resolve()
      .catch (e) ->
        debug e
        reject e

  push: =>
    new Promise (resolve, reject) =>
      session.request("VBD.create", [@.toJSON()]).then (value) =>
        debug value
        xenAPI.vbdCollection.findOpaqueRef(value).then (vbd) ->
          resolve vbd
      .catch (e) ->
        debug e
        reject e

  ###*
   * Return the OpaqueRef that represents this Template
   * @return     {String}
  ###
  getOpaqueRef: =>
    return key

  VBD.MODES =
    RO: "RO",
    RW: "RW"

  VBD.TYPES =
    CD: "CD",
    DISK: "Disk"

module.exports = VBD
