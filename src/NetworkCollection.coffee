debug = require('debug') 'XenAPI:NetworkCollection'
Promise = require 'bluebird'
_ = require 'lodash'

class NetworkCollection
	session = undefined
	Network = undefined

	###*
	* Construct NetworkCollection
	* @class
	* @param      {Object}   session - An instance of Session
	* @param      {Object}   Network - Dependency injection of the Network class.
	###
	constructor: (_session, _Network) ->
		debug "constructor()"
		unless _session
			throw Error "Must provide session"
		else
			session = _session

		unless _Network
			throw Error "Must provide Network"
		else
			Network = _Network

	###*
	 * List all Networks
	 * @return     {Promise}
	###
	list: =>
		debug "list()"
		new Promise (resolve, reject) =>
			session.request("network.get_all_records").then (value) =>
				unless value
					reject()
				debug "Received #{Object.keys(value).length} records"
				createNetworkInstance = (network, key) =>
					unless network.other_config &&
					  (network.other_config.is_guest_installer_network ||
					   network.other_config.is_host_internal_management_network)
						return new Network session, network, key

				Networks = _.map value, createNetworkInstance
				resolve _.filter Networks, (network) -> network
			.catch (e) ->
				debug e
				reject e

module.exports = NetworkCollection
