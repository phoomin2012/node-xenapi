debug = require('debug') 'XenAPI:TaskCollection'
Promise = require 'bluebird'
_ = require 'lodash'

class TaskCollection
  session = undefined
  Task = undefined

  ###*
  * Construct TaskCollection
  * @class
  * @param      {Object}   session - An instance of Session
  * @param      {Object}   Task - Dependency injection of the Task class.
  ###
  constructor: (_session, _Task) ->
    debug "constructor()"
    unless _session
      throw Error "Must provide session"
    else
      session = _session

    unless _Task
      throw Error "Must provide Task"
    else
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
        createTaskInstance = (task, key) =>
          try
            return new Task session, task, key
          catch
            return null

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
