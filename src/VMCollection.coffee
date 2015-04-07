debug = require('debug') 'XenAPI:VMCollection'
Promise = require 'bluebird'
_ = require 'lodash'

class VMCollection
  session = undefined
  VM = undefined

  createVMInstance = (vm, key) =>
    if !vm.is_a_template && !vm.is_control_domain
      return new VM session, vm, key

  ###*
  * Construct VMCollection
  * @class
  * @param      {Object}   session - An instance of Session
  * @param      {Object}   VM - Dependency injection of the VM class.
  ###
  constructor: (_session, _VM) ->
    debug "constructor()"
    unless _session
      throw Error "Must provide session"
    else
      session = _session

    unless _VM
      throw Error "Must provide VM"
    else
      VM = _VM

  ###*
   * List all VMs
   * @return     {Promise}
  ###
  list: =>
    debug "list()"
    new Promise (resolve, reject) =>
      session.request("VM.get_all_records").then (value) =>
        unless value
          reject()
        debug "Received #{Object.keys(value).length} records"

        VMs = _.map value, createVMInstance
        resolve _.filter VMs, (vm) -> vm
      .catch (e) ->
        debug e
        reject e


  findOpaqueRef: (opaqueRef) =>
    debug "findOpaqueRef(#{opaqueRef})"
    new Promise (resolve, reject) =>
      session.request("VM.get_record", [opaqueRef]).then (value) =>
        unless value
          reject()

        vm = createVMInstance value, opaqueRef
        resolve vm
      .catch (e) ->
        debug e
        reject e

module.exports = VMCollection
