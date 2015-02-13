debug = require('debug') 'XenAPI:VMCollection'
Promise = require 'bluebird'
_ = require 'lodash'

class module.exports
	VM = undefined

	constructor: (@session, _VM) ->
		debug "constructor()"
		unless @session
			throw Error "Must provide session"

		unless _VM
			throw Error "Must provide VM"
		else
			VM = _VM

	list: =>
		debug "list()"
		new Promise (resolve, reject) =>
			@session.request("VM.get_all_records").then (value) =>
				validateVM = (vm) ->
					return !vm.is_a_template && !vm.is_control_domain

				resolve _.filter value, validateVM
			.catch (e) ->
				debug e
				reject e
