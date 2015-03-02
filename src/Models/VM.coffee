debug = require('debug') 'XenAPI:VM'
Promise = require 'bluebird'

class VM
	key = undefined
	session = undefined
	vm = undefined

	###*
	* Construct VM
	* @class
	* @param      {Object}   session - An instance of Session
	* @param      {Object}   vm - A JSON object representing this VM
	* @param      {String}   key - The OpaqueRef handle to this VM
	###
	constructor: (_session, _vm, _key) ->
		debug "constructor()"
		unless _session
			throw Error "Must provide `session`"
		else
			session = _session

		unless _vm
			throw Error "Must provide `vm`"

		unless !_vm.is_a_template && !_vm.is_control_domain && _vm.uuid
			throw Error "`vm` does not describe a valid VM"
		else
			vm = _vm

		unless _key
			throw Error "Must provide `key`"
		else
			key = _key

		@uuid = vm.uuid
		@name = vm.name_label
		@description = vm.name_description
		@xenToolsInstalled = !(vm.guest_metrics == 'OpaqueRef:NULL')
		@powerState = vm.power_state

		@POWER_STATES =
			HALTED: 'Halted',
			PAUSED: 'Paused',
			RUNNING: 'Running',
			SUSPENDED: 'Suspended'

	###*
	 * Refresh the power state of this VM
	 * @return     {Promise}
	###
	refreshPowerState: =>
		debug "refreshPowerState()"

		new Promise (resolve, reject) =>
			session.request("VM.get_power_state", [key]).then (value) =>
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
				unless currentPowerState == @POWER_STATES.RUNNING
					reject "VM not in #{@POWER_STATES.RUNNING} power state."
				else
					session.request("VM.pause", [key]).then (value) =>
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
				unless currentPowerState == @POWER_STATES.PAUSED
					reject "VM not in #{@POWER_STATES.PAUSED} power state."
				else
					session.request("VM.unpause", [key]).then (value) =>
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
				unless currentPowerState == @POWER_STATES.RUNNING
					reject "VM not in #{@POWER_STATES.RUNNING} power state."
				else
					session.request("VM.suspend", [key]).then (value) =>
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
				unless currentPowerState == @POWER_STATES.SUSPENDED
					reject "VM not in #{@POWER_STATES.SUSPENDED} power state."
				else
					startPaused = false
					force = false

					session.request("VM.resume", [key, startPaused, force]).then (value) =>
						resolve()
					.catch (e) ->
						debug e
						reject e
			.catch (e) ->
				debug e
				reject e

module.exports = VM
