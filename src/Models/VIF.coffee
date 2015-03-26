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

module.exports = VIF
