debug = require('debug') 'XenAPI:Network'
Promise = require 'bluebird'

class Network
	key = undefined
	session = undefined
	network = undefined

	###*
	* Construct VM
	* @class
	* @param      {Object}   session - An instance of Session
	* @param      {Object}   network - A JSON object representing this Network
	* @param      {String}   key - The OpaqueRef handle to this Network
	###
	constructor: (_session, _network, _key) ->
		debug "constructor()"
		unless _session
			throw Error "Must provide `session`"
		else
			session = _session

		unless _network
			throw Error "Must provide `network`"

		network = _network

		unless _key
			throw Error "Must provide `key`"
		else
			key = _key

		@uuid = network.uuid
		@name = network.name_label
		@VIFs = network.VIFs
		@PIFs = network.PIFs
		@MTU = network.MTU

	getOpaqueRef: =>
		return key

module.exports = Network
