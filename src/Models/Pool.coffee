debug = require('debug') 'XenAPI:Pool'
Promise = require 'bluebird'

class Pool
  key = undefined
  session = undefined
  pool = undefined

  ###*
  * Construct Pool
  * @class
  * @param      {Object}   session - An instance of Session
  * @param      {Object}   pool - A JSON object representing this Pool
  * @param      {String}   key - The OpaqueRef handle to this Pool
  ###
  constructor: (_session, _pool, _key) ->
    debug "constructor()"
    debug _pool
    unless _session
      throw Error "Must provide `session`"
    unless _pool
      throw Error "Must provide `pool`"
    unless _key
      throw Error "Must provide `key`"

    session = _session
    pool = _pool
    key = _key

    @uuid = pool.uuid
    @name = pool.name_label
    @description = pool.name_description
    @default_SR = pool.default_SR

module.exports = Pool
