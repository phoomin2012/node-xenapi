debug = require('debug') 'XenAPI:Task'
Promise = require 'bluebird'
_ = require 'lodash'

class Task
  session = undefined
  xenAPI = undefined

  ###*
  * Construct Task
  * @class
  * @param      {Object}   session - An instance of Session
  * @param      {Object}   task - A JSON object representing this Task
  * @param      {String}   opaqueRef - The OpaqueRef handle to this Task
  * @param      {Object}   xenAPI - An instance of XenAPI
  ###
  constructor: (_session, _task, _opaqueRef, _xenAPI) ->
    debug "constructor()"
    debug _task, _opaqueRef

    unless _session
      throw Error "Must provide `session`"
    unless _task
      throw Error "Must provide `task`"
    unless _key
      throw Error "Must provide `key`"
    unless _xenAPI
      throw Error "Must provide `xenAPI`"

    unless _task.allowed_operations && _task.status
      throw Error "`task` does not describe a valid Task"

    #These can safely go into class scope because there is only one instance of each.
    session = _session
    xenAPI = _xenAPI

    @opaqueRef = _opaqueRef
    @uuid = _task.uuid
    @name = _task.name_label
    @description = _task.name_description
    @allowed_operations = _task.allowed_operations
    @status = _task.status
    @created = _task.created
    @finished = _task.finished
    @progress = _task.progress

  cancel: =>
    debug "cancel()"

    new Promise (resolve, reject) =>
      unless _.contains @allowed_operations, Task.ALLOWED_OPERATIONS.CANCEL
        reject new Error "Operation is not allowed"
        return

      session.request("task.cancel", [@opaqueRef]).then (value) =>
        debug value
        resolve()
      .catch (e) ->
        debug e
        reject e

  Task.STATUS =
    PENDING: "pending",
    SUCCESS: "success",
    FAILURE: "failure",
    CANCELLING: "cancelling",
    CANCELLED: "cancelled"

  Task.ALLOWED_OPERATIONS =
    CANCEL: "cancel"

module.exports = Task
