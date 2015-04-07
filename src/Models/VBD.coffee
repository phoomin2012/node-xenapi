debug = require('debug') 'XenAPI:VBD'
Promise = require 'bluebird'

class VBD
  session = undefined
  xenAPI = undefined

  ###*
  * Construct VBD.
  * @class
  * @param      {Object}   session - An instance of Session
  * @param      {Object}   vbd - A JSON object representing this VBD
  * @param      {String}   opaqueRef - The OpaqueRef handle to this vbd
  * @param      {Object}   xenAPI - An instance of XenAPI.
  ###
  constructor: (_session, _vbd, _opaqueRef, _xenAPI) ->
    debug "constructor()"
    debug _vbd, _opaqueRef

    unless _session
      throw Error "Must provide `session`"
    unless _vbd
      throw Error "Must provide `vbd`"
    unless _opaqueRef
      throw Error "Must provide `opaqueRef`"
    unless _xenAPI
      throw Error "Must provide `xenAPI`"

    #These can safely go into class scope because there is only one instance of each.
    session = _session
    xenAPI = _xenAPI

    @opaqueRef = _opaqueRef
    @uuid = _vbd.uuid
    @VM = _vbd.VM
    @VDI = _vbd.VDI
    @userdevice = _vbd.userdevice
    @mode = _vbd.mode
    @type = _vbd.type
    @empty = _vbd.empty

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
      session.request("VBD.insert", [@opaqueRef, vdi]).then (value) =>
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

  VBD.MODES =
    RO: "RO",
    RW: "RW"

  VBD.TYPES =
    CD: "CD",
    DISK: "Disk"

module.exports = VBD
