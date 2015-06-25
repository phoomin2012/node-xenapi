debug = require('debug') 'XenAPI:VM'
Promise = require 'bluebird'

class VM
  session = undefined
  xenAPI = undefined

  ###*
  * Construct VM
  * @class
  * @param      {Object}   session - An instance of Session
  * @param      {Object}   vm - A JSON object representing this VM
  * @param      {String}   opaqueRef - The OpaqueRef handle to this VM
  * @param      {Object}   xenAPI - An instance of XenAPI.
  ###
  constructor: (_session, _vm, _opaqueRef, _xenAPI) ->
    debug "constructor()"
    debug _vm, _opaqueRef

    unless _session
      throw Error "Must provide `session`"
    unless _vm
      throw Error "Must provide `vm`"
    unless _opaqueRef
      throw Error "Must provide `opaqueRef`"
    unless _xenAPI
      throw Error "Must provide `xenAPI`"
    unless !_vm.is_a_template && !_vm.is_control_domain && _vm.uuid
      throw Error "`vm` does not describe a valid VM"

    #These can safely go into class scope because there is only one instance of each.
    session = _session
    xenAPI = _xenAPI

    @opaqueRef = _opaqueRef
    @uuid = _vm.uuid
    @name = _vm.name_label
    @description = _vm.name_description
    @other_config = _vm.other_config
    @xenToolsInstalled = !(_vm.guest_metrics == 'OpaqueRef:NULL')
    @powerState = _vm.power_state
    @VIFs = _vm.VIFs || []
    @VBDs = _template.VBDs || []
    @guest_metrics = _vm.guest_metrics

  ###*
   * Refresh the power state of this VM
   * @return     {Promise}
  ###
  refreshPowerState: =>
    debug "refreshPowerState()"

    new Promise (resolve, reject) =>
      session.request("VM.get_power_state", [@opaqueRef]).then (value) =>
        debug value
        @powerState = value
        resolve value
      .catch (e) ->
        debug e
        reject e

  ###*
   * Pause this VM. Can only be applied to VMs in the Running state.
   * @return     {Promise}
  ###
  pause: =>
    debug "pause()"
    new Promise (resolve, reject) =>
      @refreshPowerState().then (currentPowerState) =>
        unless currentPowerState == VM.POWER_STATES.RUNNING
          reject "VM not in #{VM.POWER_STATES.RUNNING} power state."
        else
          session.request("VM.pause", [@opaqueRef]).then (value) =>
            resolve()
          .catch (e) ->
            debug e
            reject e
      .catch (e) ->
        debug e
        reject e

  ###*
   * Unpause this VM. Can only be applied to VMs in the Paused state.
   * @return     {Promise}
  ###
  unpause: =>
    debug "unpause()"
    new Promise (resolve, reject) =>
      @refreshPowerState().then (currentPowerState) =>
        unless currentPowerState == VM.POWER_STATES.PAUSED
          reject "VM not in #{VM.POWER_STATES.PAUSED} power state."
        else
          session.request("VM.unpause", [@opaqueRef]).then (value) =>
            resolve()
          .catch (e) ->
            debug e
            reject e
      .catch (e) ->
        debug e
        reject e

  ###*
   * Suspend this VM. Can only be applied to VMs in the Running state.
   * @return     {Promise}
  ###
  suspend: =>
    debug "suspend()"
    new Promise (resolve, reject) =>
      @refreshPowerState().then (currentPowerState) =>
        unless currentPowerState == VM.POWER_STATES.RUNNING
          reject "VM not in #{VM.POWER_STATES.RUNNING} power state."
        else
          session.request("VM.suspend", [@opaqueRef]).then (value) =>
            resolve()
          .catch (e) ->
            debug e
            reject e
      .catch (e) ->
        debug e
        reject e

  ###*
   * Resume this VM. Can only be applied to VMs in the Suspended state.
   * @return     {Promise}
  ###
  resume: =>
    debug "resume()"
    new Promise (resolve, reject) =>
      @refreshPowerState().then (currentPowerState) =>
        unless currentPowerState == VM.POWER_STATES.SUSPENDED
          reject "VM not in #{VM.POWER_STATES.SUSPENDED} power state."
        else
          startPaused = false
          force = false

          session.request("VM.resume", [@opaqueRef, startPaused, force]).then (value) =>
            resolve()
          .catch (e) ->
            debug e
            reject e
      .catch (e) ->
        debug e
        reject e

  start: =>
    debug "start()"
    new Promise (resolve, reject) =>
      session.request("VM.start", [@opaqueRef, false, false]).then (value) =>
        resolve()
      .catch (e) ->
        debug e
        reject e

  cleanReboot: =>
    debug "cleanReboot()"
    new Promise (resolve, reject) =>
      @refreshPowerState().then (currentPowerState) =>
        unless currentPowerState == VM.POWER_STATES.RUNNING
          reject "VM not in #{VM.POWER_STATES.RUNNING} power state."
        else
          session.request("VM.clean_reboot", [@opaqueRef]).then (value) =>
            resolve()
          .catch (e) ->
            debug e
            reject e
      .catch (e) ->
        debug e
        reject e

  cleanShutdown: =>
    debug "cleanShutdown()"
    new Promise (resolve, reject) =>
      @refreshPowerState().then (currentPowerState) =>
        unless currentPowerState == VM.POWER_STATES.RUNNING
          reject "VM not in #{VM.POWER_STATES.RUNNING} power state."
        else
          session.request("VM.clean_shutdown", [@opaqueRef]).then (value) =>
            resolve()
          .catch (e) ->
            debug e
            reject e
      .catch (e) ->
        debug e
        reject e


  VM.POWER_STATES =
    HALTED: 'Halted',
    PAUSED: 'Paused',
    RUNNING: 'Running',
    SUSPENDED: 'Suspended'

  VM.DEFAULT_CONFIG =
    user_version: "0",
    is_a_template: false,
    is_control_domain: false,
    affinity: undefined,
    VCPUs_params: {},
    VCPUs_at_startup: "1",
    actions_after_shutdown: "destroy",
    actions_after_reboot: "restart",
    actions_after_crash: "restart",
    PV_bootloader: "pygrub",
    PV_kernel: undefined,
    PV_ramdisk: undefined,
    PV_args: "console=hvc0",
    PV_bootloader_args: undefined,
    PV_legacy_args: undefined,
    HVM_boot_policy: "",
    HVM_boot_params: {},
    platform: {},
    PCI_bus: undefined,
    other_config: {},
    recommendations: ""

module.exports = VM
