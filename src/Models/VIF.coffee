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

		@MAC = vif.MAC
		@MTU = vif.MTU
		@device = vif.device
		@network = vif.network
		@vm = vif.VM

		@uuid = vif.uuid
		@attached = vif.currently_attached

	toJSON: =>
		{
			MAC: @MAC,
			MTU: @MTU,
			device: @device,
			VM: @vm,
			network: @network,
			other_config: {},
			qos_algorithm_type: "",
			qos_algorithm_params: {}
		}

	push: =>
		new Promise (resolve, reject) =>
			session.request("VIF.create", [@.toJSON()]).then (value) =>
				debug value
				resolve()
			.catch (e) ->
				debug e
				reject e

module.exports = VIF
