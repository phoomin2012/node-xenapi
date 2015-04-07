debug = require('debug') 'XenAPI:VIF'
Promise = require 'bluebird'

class VIF
  session = undefined
  xenAPI = undefined

  ###*
  * Construct VIF
  * @class
  * @param      {Object}   session - An instance of Session
  * @param      {Object}   vif - A JSON object representing this VIF
  * @param      {String}   opaqueRef - The OpaqueRef handle to this VIF
  * @param      {Object}   xenAPI - An instance of XenAPI.
  ###
  constructor: (_session, _vif, _opaqueRef, _xenAPI) ->
    debug "constructor()"
    debug _vif, _opaqueRef

    unless _session
      throw Error "Must provide `session`"
    unless _vif
      throw Error "Must provide `vif`"
    unless _opaqueRef
      throw Error "Must provide `opaqueRef`"
    unless _xenAPI
      throw Error "Must provide `xenAPI`"

    #These can safely go into class scope because there is only one instance of each.
    session = _session
    xenAPI = _xenAPI

    @opaqueRef = _opaqueRef
    @uuid = _vif.uuid
    @MAC = _vif.MAC
    @MTU = _vif.MTU
    @device = _vif.device
    @network = _vif.network
    @vm = _vif.VM
    @attached = _vif.currently_attached

  toJSON: =>
    {
      MAC: @MAC,
      MTU: @MTU,
      device: @device,
      VM: @vm,
      network: @network,
      other_config: {},
      qos_algorithm_type: "",
      qos_algorithm_params: {}
    }

  push: =>
    new Promise (resolve, reject) =>
      session.request("VIF.create", [@.toJSON()]).then (value) =>
        debug value
        resolve()
      .catch (e) ->
        debug e
        reject e

  VIF.ALLOWED_OPERATIONS =
    ATTACH: "attach",
    UNPLUG: "unplug"

module.exports = VIF
