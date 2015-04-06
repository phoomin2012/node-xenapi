debug = require('debug') 'XenAPI:Pool'
Promise = require 'bluebird'

class Pool
  key = undefined
  session = undefined
  pool = undefined
  xenAPI = undefined

  ###*
  * Construct Pool
  * @class
  * @param      {Object}   session - An instance of Session
  * @param      {Object}   pool - A JSON object representing this Pool
  * @param      {String}   key - The OpaqueRef handle to this Pool
  ###
  constructor: (_session, _pool, _key, _xenAPI) ->
    debug "constructor()"
    debug _pool
    unless _session
      throw Error "Must provide `session`"
    unless _pool
      throw Error "Must provide `pool`"
    unless _key
      throw Error "Must provide `key`"
    unless _xenAPI
      throw Error "Must provide `xenAPI`"

    session = _session
    pool = _pool
    key = _key
    xenAPI = _xenAPI

    @uuid = pool.uuid
    @name = pool.name_label
    @description = pool.name_description

  getDefaultSR: =>
    debug "getDefaultSR()"
    new Promise (resolve, reject) =>
      session.request("pool.get_default_SR", [key]).then (value) =>
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
