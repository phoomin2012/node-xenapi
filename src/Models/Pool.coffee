debug = require('debug') 'XenAPI:Pool'
Promise = require 'bluebird'

class Pool
  session = undefined
  xenAPI = undefined

  ###*
  * Construct Pool
  * @class
  * @param      {Object}   session - An instance of Session
  * @param      {Object}   pool - A JSON object representing this Pool
  * @param      {String}   opaqueRef - The OpaqueRef handle to this Pool
  * @param      {Object}   xenAPI - An instance of XenAPI
  ###
  constructor: (_session, _pool, _opaqueRef, _xenAPI) ->
    debug "constructor()"
    debug _pool
    unless _session
      throw Error "Must provide `session`"
    unless _pool
      throw Error "Must provide `pool`"
    unless _opaqueRef
      throw Error "Must provide `opaqueRef`"
    unless _xenAPI
      throw Error "Must provide `xenAPI`"

    #These can safely go into class scope because there is only one instance of each.
    session = _session
    xenAPI = _xenAPI

    @opaqueRef = _opaqueRef
    @uuid = _pool.uuid
    @name = _pool.name_label
    @description = _pool.name_description

  getDefaultSR: =>
    debug "getDefaultSR()"
    new Promise (resolve, reject) =>
      session.request("pool.get_default_SR", [@opaqueRef]).then (value) =>
        unless value
          reject()

        xenAPI.srCollection.findOpaqueRef(value).then (sr) ->
          resolve sr
        .catch (e) ->
          debug e
          if e[0] == "HANDLE_INVALID"
            reject new Error "Xen reported default SR, but none found. Is one set as default?"
          else
            reject e
      .catch (e) ->
        debug e
        reject e

module.exports = Pool
