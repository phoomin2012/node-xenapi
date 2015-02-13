APIClient = require './APIClient'
Session = require './Models/Session'
VMCollection = require './VMCollection'
VM = require './Models/VM'
xmlrpc = require 'xmlrpc'

module.exports = (options) ->
	apiClient = new APIClient xmlrpc, options
	session = new Session apiClient
	vmCollection = new VMCollection session, VM

	return {
		session: session,
		vmCollection: vmCollection
	}
