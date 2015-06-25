debug = require('debug') 'XenAPI:PoolCollection'
Promise = require 'bluebird'
minimatch = require 'minimatch'
_ = require 'lodash'

class PoolCollection
  Pool = undefined
  session = undefined
  xenAPI = undefined

  createPoolInstance = (pool, opaqueRef) =>
    return new Pool session, pool, opaqueRef, xenAPI

  ###*
  * Construct PoolCollection
  * @class
  * @param      {Object}   session - An instance of Session
  * @param      {Object}   Pool - Dependency injection of the Pool class.
  * @param      {Object}   xenAPI - An instance of XenAPI
  ###
  constructor: (_session, _Pool, _xenAPI) ->
    debug "constructor()"
    unless _session
      throw Error "Must provide session"
    unless _Pool
      throw Error "Must provide Pool"
    unless _xenAPI
      throw Error "Must provide xenAPI"

    #These can safely go into shared class scope because this constructor is only called once.
    session = _session
    xenAPI = _xenAPI
    Pool = _Pool

  ###*
  * List all Pools
  * @return     {Promise}
  ###
  list: =>
    debug "list()"
    new Promise (resolve, reject) =>
      session.request("pool.get_all_records").then (value) =>
        unless value
          reject()

        debug "Received #{Object.keys(value).length} records"

        Pools = _.map value, createPoolInstance
        resolve _.filter Pools, (pool) -> pool
      .catch (e) ->
        debug e
        reject e

  findUUID: (uuid) =>
    debug "findUUID(#{uuid}"
    new Promise (resolve, reject) =>
      @list().then (Pools) =>
        matchPooluuid = (pool) ->
          if pool.uuid == uuid
            return pool

        matches = _.map Pools, matchPooluuid
        filtered = _.filter matches, (pool) -> pool
        if filtered.length > 1
          reject("Multiple Pools for UUID #{uuid}")
        else
          resolve filtered[0]
      .catch (e) ->
        debug e
        reject e

module.exports = PoolCollection
