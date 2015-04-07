debug = require('debug') 'XenAPI:VDI'
Promise = require 'bluebird'

class VDI
  session = undefined
  xenAPI = undefined

  ###*
  * Construct VDI.
  * @class
  * @param      {Object}   session - An instance of Session
  * @param      {Object}   vdi - A JSON object representing this VDI
  * @param      {String}   opaqueRef - The OpaqueRef handle to this VDI
  * @param      {Object}   xenAPI - An instance of XenAPI.
  ###
  constructor: (_session, _vdi, _opaqueRef, _xenAPI) ->
    debug "constructor()"
    debug _vdi, _opaqueRef

    unless _session
      throw Error "Must provide `session`"
    unless _vdi
      throw Error "Must provide `vdi`"
    unless _opaqueRef
      throw Error "Must provide `opaqueRef`"

    #These can safely go into class scope because there is only one instance of each.
    session = _session
    xenAPI = _xenAPI

    @opaqueRef = _opaqueRef
    @uuid = _vdi.uuid
    @name = _vdi.name_label
    @description = _vdi.name_description
    @allowed_operations = _vdi.allowed_operations
    @SR = _vdi.SR

module.exports = VDI
