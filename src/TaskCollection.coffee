debug = require('debug') 'XenAPI:TaskCollection'
Promise = require 'bluebird'
minimatch = require 'minimatch'
_ = require 'lodash'

class TaskCollection
  Task = undefined
  session = undefined
  xenAPI = undefined

  createTaskInstance = (task, opaqueRef) =>
    try
      return new Task session, task, opaqueRef, xenAPI
    catch
      return null

  ###*
  * Construct TaskCollection
  * @class
  * @param      {Object}   session - An instance of Session
  * @param      {Object}   Task - Dependency injection of the Task class.
  * @param      {Object}   xenAPI - An instance of XenAPI
  ###
  constructor: (_session, _Task, _xenAPI) ->
    debug "constructor()"
    unless _session
      throw Error "Must provide session"
    unless _Task
      throw Error "Must provide Task"
    unless _xenAPI
      throw Error "Must provide xenAPI"

    #These can safely go into shared class scope because this constructor is only called once.
    session = _session
    xenAPI = _xenAPI
    Task = _Task


  ###*
   * List all Tasks
   * @return     {Promise}
  ###
  list: =>
    debug "list()"
    new Promise (resolve, reject) =>
      session.request("task.get_all_records").then (value) =>
        unless value
          reject()
        debug "Received #{Object.keys(value).length} records"

        Tasks = _.map value, createTaskInstance
        resolve _.filter Tasks, (task) -> task
      .catch (e) ->
        debug e
        reject e

  ###*
   * Show Task by UUID
   * @param		{String}	uuid - The UUID of the Task to show.
   * @return		{Promise}
  ###
  show: (uuid) =>
    debug "list(#{uuid})"
    new Promise (resolve, reject) =>
      session.request("task.get_by_uuid", [uuid]).then (opaqueRef) =>
        unless opaqueRef
          reject()
        session.request("task.get_record", [opaqueRef]).then (task) =>
          unless task
            reject()
          debug task
          newTask = null
          try
            newTask = new Task session, task, opaqueRef
          finally
            resolve newTask
        .catch (e) ->
          debug e
          reject e
      .catch (e) ->
        debug e
        reject e

module.exports = TaskCollection
