debug = require('debug') 'XenAPI:VIFCollection'
Promise = require 'bluebird'
_ = require 'lodash'

class VIFCollection
	session = undefined
	VIF = undefined

	###*
	* Construct VIFCollection
	* @class
	* @param      {Object}   session - An instance of Session
	* @param      {Object}   VIF - Dependency injection of the VIF class.
	###
	constructor: (_session, _VIF) ->
		debug "constructor()"
		unless _session
			throw Error "Must provide session"
		else
			session = _session

		unless _VIF
			throw Error "Must provide VIF"
		else
			VIF = _VIF

	###*
	* List all VIFs
	* @return     {Promise}
	###
	list: =>
		debug "list()"
		new Promise (resolve, reject) =>
			session.request("VIF.get_all_records").then (value) =>
				unless value
					reject()

				debug "Received #{Object.keys(value).length} records"
				createVIFInstance = (vif, key) =>
					debug vif

				VIFs = _.map value, createVIFInstance
				resolve _.filter VIFs, (vif) -> vif
			.catch (e) ->
				debug e
				reject e

	create: (network, vm) =>
		debug "create()"

		new Promise (resolve, reject) =>
			vif =
				uuid: null,
				device: vm.VIFs.length.toString(),
				MAC: "",
				MTU: "1500",
				currently_attached: false,
				network: network.getOpaqueRef(),
				VM: vm.getOpaqueRef()

			newVIF = new VIF session, vif, "OpaqueRef:NULL"

			resolve newVIF

module.exports = VIFCollection
