debug = require('debug') 'XenAPI:SRCollection'
Promise = require 'bluebird'
minimatch = require 'minimatch'
_ = require 'lodash'

class SRCollection
  SR = undefined
  session = undefined
  xenAPI = undefined

  createSRInstance = (sr, opaqueRef) =>
    return new SR session, sr, opaqueRef, xenAPI

  ###*
  * Construct SRCollection
  * @class
  * @param      {Object}   session - An instance of Session
  * @param      {Object}   SR - Dependency injection of the SR class.
  * @param      {Object}   xenAPI - An instance of XenAPI
  ###
  constructor: (_session, _SR, _xenAPI) ->
    debug "constructor()"
    unless _session
      throw Error "Must provide session"
    unless _SR
      throw Error "Must provide SR"
    unless _xenAPI
      throw Error "Must provide xenAPI"

    #These can safely go into shared class scope because this constructor is only called once.
    session = _session
    xenAPI = _xenAPI
    SR = _SR

  ###*
  * List all SRs
  * @return     {Promise}
  ###
  list: =>
    debug "list()"
    new Promise (resolve, reject) =>
      session.request("SR.get_all_records").then (value) =>
        unless value
          reject()

        debug "Received #{Object.keys(value).length} records"

        SRs = _.map value, createSRInstance
        resolve _.filter SRs, (sr) -> sr
      .catch (e) ->
        debug e
        reject e

  findNamed: (name) =>
    debug "findNamed(#{name})"
    new Promise (resolve, reject) =>
      @list().then (SRs) =>
        matchSRName = (sr) ->
          if minimatch(sr.name, name, {nocase: true})
            return sr

        matches = _.map SRs, matchSRName
        resolve _.filter matches, (sr) -> sr
      .catch (e) ->
        debug e
        reject e

  findUUID: (uuid) =>
    debug "findUUID(#{uuid}"
    new Promise (resolve, reject) =>
      @list().then (SRs) =>
        matchSRuuid = (sr) ->
          if sr.uuid == uuid
            return sr

        matches = _.map SRs, matchSRuuid
        resolve _.filter matches, (sr) -> sr
      .catch (e) ->
        debug e
        reject e

  findOpaqueRef: (opaqueRef) =>
    debug "findOpaqueRef(#{opaqueRef})"
    new Promise (resolve, reject) =>
      session.request("SR.get_record", [opaqueRef]).then (value) =>
        unless value
          reject()

        template = createSRInstance value, opaqueRef
        resolve template
      .catch (e) ->
        debug e
        reject e

module.exports = SRCollection
