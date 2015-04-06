debug = require('debug') 'XenAPI:TemplateCollection'
Promise = require 'bluebird'
minimatch = require 'minimatch'
_ = require 'lodash'

class TemplateCollection
  session = undefined
  Template = undefined
  xenAPI = undefined

  createTemplateInstance = (template, key) =>
    if template.is_a_template && !template.is_control_domain
      return new Template session, template, key, xenAPI

  ###*
  * Construct TemplateCollection
  * @class
  * @param      {Object}   session - An instance of Session
  * @param      {Object}   Template - Dependency injection of the Template class.
  * @param      {Object}   XenAPI - Dependecy injection of the XenAPI object.
  ###
  constructor: (_session, _Template, _XenAPI) ->
    debug "constructor()"
    unless _session
      throw Error "Must provide session"
    unless _Template
      throw Error "Must provide Template"
    unless _XenAPI
      throw Error "Must provide XenAPI"

    session = _session
    Template = _Template
    xenAPI = _XenAPI

  ###*
  * List all Templates
  * @return     {Promise}
  ###
  list: =>
    debug "list()"
    new Promise (resolve, reject) =>
      session.request("VM.get_all_records").then (value) =>
        unless value
          reject()
        debug "Received #{Object.keys(value).length} records"

        Templates = _.map value, createTemplateInstance
        resolve _.filter Templates, (template) -> template
      .catch (e) ->
        debug e
        reject e

  findNamed: (name) =>
    debug "findNamed(#{name})"
    new Promise (resolve, reject) =>
      @list().then (templates) =>
        matchTemplateName = (template) ->
          if minimatch(template.name, name, {nocase: true})
            return template

        matches = _.map templates, matchTemplateName
        resolve _.filter matches, (template) -> template
      .catch (e) ->
        debug e
        reject e

  findOpaqueRef: (opaqueRef) =>
    debug "findOpaqueRef(#{opaqueRef})"
    new Promise (resolve, reject) =>
      session.request("VM.get_record", [opaqueRef]).then (value) =>
        unless value
          reject()

        template = createTemplateInstance value, opaqueRef
        resolve template
      .catch (e) ->
        debug e
        reject e

module.exports = TemplateCollection
