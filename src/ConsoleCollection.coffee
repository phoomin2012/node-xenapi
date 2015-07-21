debug = require('debug') 'XenAPI:ConsoleCollection'
Promise = require 'bluebird'
minimatch = require 'minimatch'
_ = require 'lodash'

class ConsoleCollection
  Console = undefined
  session = undefined
  xenAPI = undefined

  createConsoleInstance = (console, opaqueRef) =>
    return new Console session, console, opaqueRef, xenAPI

  ###*
  * Construct ConsoleCollection
  * @class
  * @param      {Object}   session - An instance of Session
  * @param      {Object}   Console - Dependency injection of the Console class.
  * @param      {Object}   xenAPI - An instance of XenAPI
  ###
  constructor: (_session, _console, _xenAPI) ->
    debug "constructor()"
    unless _session
      throw Error "Must provide session"
    unless _console
      throw Error "Must provide Console"
    unless _xenAPI
      throw Error "Must provide xenAPI"

    #These can safely go into shared class scope because this constructor is only called once.
    session = _session
    xenAPI = _xenAPI
    Console = _console

  ###*
  * List all ConsoleCollection
  * @return     {Promise}
  ###
  list: =>
    debug "list()"
    new Promise (resolve, reject) =>
      session.request("console.get_all_records").then (value) =>
        unless value
          reject()

        debug "Received #{Object.keys(value).length} records"

        Consoles = _.map value, createConsoleInstance()
        resolve _.filter Consoles, (consoles) -> consoles
      .catch (e) ->
        debug e
        reject e

  findUUID: (uuid) =>
    debug "findUUID(#{uuid}"
    new Promise (resolve, reject) =>
      query = 'field "uuid"="' + uuid + '"'
      session.request("console.get_all_records_where", [query]).then (value) =>
        unless value
          reject()

        debug "Received #{Object.keys(value).length} records"

        Consoles = _.map value, createConsoleInstance
        filtered = _.filter Consoles, (consoles) -> consoles
        if filtered.length > 1
          reject("Multiple Metrics for UUID #{uuid}")
        else
          resolve filtered[0]
      .catch (e) ->
        debug e
        reject e

  findOpaqueRef: (opaqueRef) =>
    debug "findOpaqueRef(#{opaqueRef})"
    new Promise (resolve, reject) =>
      session.request("console.get_record", [opaqueRef]).then (value) =>
        unless value
          reject()

        console = createConsoleInstance value, opaqueRef
        resolve console
      .catch (e) ->
        debug e
        reject e

module.exports = ConsoleCollection
