APIClient = require './APIClient'
Session = require './Models/Session'
xmlrpc = require 'xmlrpc'

apiClient = new APIClient xmlrpc
session = new Session apiClient

module.exports = (options) ->
	return {}
