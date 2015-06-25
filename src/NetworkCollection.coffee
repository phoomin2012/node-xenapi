debug = require('debug') 'XenAPI:NetworkCollection'
Promise = require 'bluebird'
minimatch = require 'minimatch'
_ = require 'lodash'

class NetworkCollection
  Network = undefined
  session = undefined
  xenAPI = undefined

  createNetworkInstance = (network, opaqueRef) =>
    unless network.other_config &&
      (network.other_config.is_guest_installer_network ||
        network.other_config.is_host_internal_management_network)
      return new Network session, network, opaqueRef, xenAPI

  ###*
  * Construct NetworkCollection
  * @class
  * @param      {Object}   session - An instance of Session
  * @param      {Object}   Network - Dependency injection of the Network class.
  * @param      {Object}   xenAPI - An instance of XenAPI
  ###
  constructor: (_session, _Network, _xenAPI) ->
    debug "constructor()"
    unless _session
      throw Error "Must provide session"
    unless _Network
      throw Error "Must provide Network"
    unless _xenAPI
      throw Error "Must provide xenAPI"

    #These can safely go into shared class scope because this constructor is only called once.
    session = _session
    xenAPI = _xenAPI
    Network = _Network

  ###*
   * List all Networks
   * @return     {Promise}
  ###
  list: =>
    debug "list()"
    new Promise (resolve, reject) =>
      session.request("network.get_all_records").then (value) =>
        unless value
          reject()
        debug "Received #{Object.keys(value).length} records"

        Networks = _.map value, createNetworkInstance
        resolve _.filter Networks, (network) -> network
      .catch (e) ->
        debug e
        reject e

  findNamed: (name) =>
    debug "findNamed(#{name})"
    new Promise (resolve, reject) =>
      @list().then (networks) =>
        matchNetworkName = (network) ->
          if minimatch(network.name, name, {nocase: true})
            return network

        matches = _.map networks, matchNetworkName
        resolve _.filter matches, (network) -> network
      .catch (e) ->
        debug e
        reject e

  findUUID: (uuid) =>
    debug "findUUID(#{uuid}"
    new Promise (resolve, reject) =>
      @list().then (Networks) =>
        matchNetworkUuid = (network) ->
          if network.uuid == uuid
            return network

        matches = _.map Networks, matchNetworkUuid
        filtered _.filter matches, (network) -> network
        if filtered.length > 1
          reject("Multiple Networks for UUID #{uuid}")
        else
          resolve filtered[0]
      .catch (e) ->
        debug e
        reject e

module.exports = NetworkCollection
