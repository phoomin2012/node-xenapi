debug = require('debug') 'XenAPI:PoolCollection'
Promise = require 'bluebird'
_ = require 'lodash'

class PoolCollection
  session = undefined
  Pool = undefined

  ###*
  * Construct PoolCollection
  * @class
  * @param      {Object}   session - An instance of Session
  * @param      {Object}   Pool - Dependency injection of the Pool class.
  ###
  constructor: (_session, _Pool) ->
    debug "constructor()"
    unless _session
      throw Error "Must provide session"
    else
      session = _session

    unless _Pool
      throw Error "Must provide Pool"
    else
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
        createPoolInstance = (pool, key) =>
          return new Pool session, pool, key

        Pools = _.map value, createPoolInstance
        resolve _.filter Pools, (pool) -> pool
      .catch (e) ->
        debug e
        reject e

module.exports = PoolCollection
