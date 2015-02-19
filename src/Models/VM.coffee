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
