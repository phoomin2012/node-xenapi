debug = require('debug') 'XenAPI:VDI'
Promise = require 'bluebird'

class VDI
  key = undefined
  session = undefined
  vdi = undefined
  xenAPI = undefined

  ###*
  * Construct VBD.
  * @class
  * @param      {Object}   session - An instance of Session
  * @param      {Object}   vdi - A JSON object representing this VDI
  * @param      {String}   key - The OpaqueRef handle to this VDI
  ###
  constructor: (_session, _vdi, _key, _xenAPI) ->
    debug "constructor()"
    debug _vdi
    unless _session
      throw Error "Must provide `session`"
    unless _vdi
      throw Error "Must provide `vdi`"
    unless _key
      throw Error "Must provide `key`"

    session = _session
    vdi = _vdi
    key = _key
    xenAPI = _xenAPI

    @uuid = vdi.uuid
    @name = vdi.name_label
    @description = vdi.name_description
    @allowed_operations = vdi.allowed_operations
    @SR = vdi.SR

  ###*
   * Return the OpaqueRef that represents this VDI
   * @return     {String}
  ###
  getOpaqueRef: =>
    return key

module.exports = VDI
