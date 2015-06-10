debug = require('debug') 'XenAPI:VIFCollection'
Promise = require 'bluebird'
minimatch = require 'minimatch'
_ = require 'lodash'

class VIFCollection
  VIF = undefined
  session = undefined
  xenAPI = undefined

  createVIFInstance = (vif, opaqueRef) =>
    return new VIF session, vif, opaqueRef, xenAPI

  ###*
  * Construct VIFCollection
  * @class
  * @param      {Object}   session - An instance of Session
  * @param      {Object}   VIF - Dependency injection of the VIF class.
  * @param      {Object}   xenAPI - An instance of XenAPI
  ###
  constructor: (_session, _VIF, _xenAPI) ->
    debug "constructor()"
    unless _session
      throw Error "Must provide session"
    unless _VIF
      throw Error "Must provide VIF"
    unless _xenAPI
      throw Error "Must provide xenAPI"

    #These can safely go into shared class scope because this constructor is only called once.
    session = _session
    xenAPI = _xenAPI
    VIF = _VIF

  ###*
  * List all VIFs
  * @return     {Promise}
  ###
  list: =>
    debug "list()"
    new Promise (resolve, reject) =>
      session.request("VIF.get_all_records").then (value) =>
        unless value
          reject()

        debug "Received #{Object.keys(value).length} records"

        VIFs = _.map value, createVIFInstance
        resolve _.filter VIFs, (vif) -> vif
      .catch (e) ->
        debug e
        reject e

  create: (network, vm, mac) =>
    debug "create()"

    new Promise (resolve, reject) =>
      unless mac
        mac = ""
      vif =
        uuid: null,
        device: vm.VIFs.length.toString(),
        MAC: mac,
        MTU: "1500",
        currently_attached: false,
        network: network.opaqueRef,
        VM: vm.opaqueRef

      newVIF = new VIF session, vif, "OpaqueRef:NULL", xenAPI

      resolve newVIF

module.exports = VIFCollection
