debug = require('debug') 'XenAPI:Network'
Promise = require 'bluebird'

class Network
  session = undefined
  xenAPI = undefined

  ###*
  * Construct Network
  * @class
  * @param      {Object}   session - An instance of Session
  * @param      {Object}   network - A JSON object representing this Network
  * @param      {String}   opaqueRef - The OpaqueRef handle to this Network
  * @param      {Object}   xenAPI - An instance of XenAPI.
  ###
  constructor: (_session, _network, _opaqueRef, _xenAPI) ->
    debug "constructor()"
    debug _network, _opaqueRef

    unless _session
      throw Error "Must provide `session`"
    unless _network
      throw Error "Must provide `network`"
    unless _opaqueRef
      throw Error "Must provide `opaqueRef`"
    unless _xenAPI
      throw Error "Must provide `xenAPI`"

    #These can safely go into class scope because there is only one instance of each.
    session = _session
    xenAPI = _xenAPI

    @opaqueRef = _opaqueRef
    @uuid = _network.uuid
    @name = _network.name_label
    @VIFs = _network.VIFs
    @PIFs = _network.PIFs
    @MTU = _network.MTU

module.exports = Network
