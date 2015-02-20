debug = require('debug') 'XenAPI:VM'
Promise = require 'bluebird'

class module.exports
	key = undefined
	session = undefined
	vm = undefined

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
