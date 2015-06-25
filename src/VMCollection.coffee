debug = require('debug') 'XenAPI:VMCollection'
Promise = require 'bluebird'
minimatch = require 'minimatch'
_ = require 'lodash'

class VMCollection
  VM = undefined
  session = undefined
  xenAPI = undefined

  createVMInstance = (vm, opaqueRef) =>
    try
      return new VM session, vm, opaqueRef, xenAPI
    catch e
      debug "caught error"
      debug e
      return null

  ###*
  * Construct VMCollection
  * @class
  * @param      {Object}   session - An instance of Session
  * @param      {Object}   VM - Dependency injection of the VM class.
  * @param      {Object}   xenAPI - An instance of XenAPI
  ###
  constructor: (_session, _VM, _xenAPI) ->
    debug "constructor()"
    unless _session
      throw Error "Must provide session"
    unless _VM
      throw Error "Must provide VM"
    unless _xenAPI
      throw Error "Must provide xenAPI"

    #These can safely go into shared class scope because this constructor is only called once.
    session = _session
    xenAPI = _xenAPI
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

  createVM: (ram, cpuCount, label) =>
      debug "createVM()"
      unless ram
        throw Error "Must provide RAM specification"
      unless cpuCount
        throw Error "Must provide CPU specification"
      unless label
        throw Error "Must provide label"

      new Promise (resolve, reject) =>
        memoryValue = ram * 1048576;
        vCPUMax = cpuCount;
        extraConfig =
          name_label: label,
          memory_static_max: memoryValue.toString(),
          memory_static_min: memoryValue.toString(),
          memory_dynamic_max: memoryValue.toString(),
          memory_dynamic_min: memoryValue.toString(),
          VCPUs_max: vCPUMax.toString()

        config = _.extend VM.DEFAULT_CONFIG, extraConfig

        session.request("VM.create", [config]).then (value) =>
          unless value
            reject()

          @findOpaqueRef(value).then (vm) ->
            resolve vm
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
