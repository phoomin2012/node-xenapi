debug = require('debug') 'XenAPI:SR'
Promise = require 'bluebird'

class SR
  key = undefined
  session = undefined
  sr = undefined

  ###*
  * Construct SR
  * @class
  * @param      {Object}   session - An instance of Session
  * @param      {Object}   sr - A JSON object representing this SR
  * @param      {String}   key - The OpaqueRef handle to this SR
  ###
  constructor: (_session, _sr, _key) ->
    debug "constructor()"
    debug _sr
    unless _session
      throw Error "Must provide `session`"
    unless _sr
      throw Error "Must provide `sr`"
    unless _key
      throw Error "Must provide `key`"

    session = _session
    sr = _sr
    key = _key

    @uuid = sr.uuid
    @name = sr.name_label
    @description = sr.name_description
    @allowed_operations = sr.allowed_operations
    @current_operations = sr.current_operations
    @VDIs = sr.VDIs
    @PBDs = sr.PBDs
    @physical_utilisation = sr.physical_utilisation
    @physical_size = sr.physical_size
    @unused_space = sr.physical_size - sr.physical_utilisation

module.exports = SR
