debug = require('debug') 'XenAPI:VIF'
Promise = require 'bluebird'

class VIF
	key = undefined
	session = undefined
	vif = undefined

	###*
	* Construct VIF
	* @class
	* @param      {Object}   session - An instance of Session
	* @param      {Object}   vif - A JSON object representing this VIF
	* @param      {String}   key - The OpaqueRef handle to this VIF
	###
	constructor: (_session, _vif, _key) ->
		debug "constructor()"
		unless _session
			throw Error "Must provide `session`"
		else
			session = _session

		unless _vif
			throw Error "Must provide `vif`"

		vif = _vif

		unless _key
			throw Error "Must provide `key`"
		else
			key = _key

		@ALLOWED_OPERATIONS =
			ATTACH: "attach",
			UNPLUG: "unplug"

		@uuid = vif.uuid
		@device = vif.device
		@MAC = vif.MAC
		@MTU = vif.MTU
		@attached = vif.currently_attached
		@allowed_operations = vif.allowed_operations
		@network = vif.network
		@vm = vif.VM

	toJSON: =>
		{
			allowed_operations: @allowed_operations,
			current_operations: @current_operations,
			MAC: @MAC,
			MTU: @MTU,
			device: @device,
			VM: @vm,
			network: @network,
			other_config: {},
			qos_algorithm_type: "",
			qos_algorithm_params: {}
		}

	make: =>
		new Promise (resolve, reject) =>
			debug @.toJSON()
			session.request("VIF.create", [@.toJSON()]).then (value) =>
				debug value
			.catch (e) ->
				debug e
				reject e

module.exports = VIF
