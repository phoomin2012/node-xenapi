debug = require('debug') 'XenAPI:Template'
Promise = require 'bluebird'

class Template
  key = undefined
  session = undefined
  template = undefined
  xenAPI = undefined

  ###*
  * Construct Template. Very similar to a VM, but not yet set up.
  * @class
  * @param      {Object}   session - An instance of Session
  * @param      {Object}   template - A JSON object representing this Template
  * @param      {String}   key - The OpaqueRef handle to this template
  ###
  constructor: (_session, _template, _key, _xenAPI) ->
    debug "constructor()"
    debug _template
    unless _session
      throw Error "Must provide `session`"
    unless _template
      throw Error "Must provide `template`"
    unless _template.is_a_template && !_template.is_control_domain && _template.uuid
      throw Error "`template` does not describe a valid Template"
    unless _key
      throw Error "Must provide `key`"

    session = _session
    template = _template
    key = _key
    xenAPI = _xenAPI

    @uuid = template.uuid
    @name = template.name_label
    @description = template.name_description
    @VIFs = template.VIFs || []
    @other_config = template.other_config

  toJSON: =>
    {
      name: @name
      description: @description
    }

  ###*
   * Return the OpaqueRef that represents this Template
   * @return     {String}
  ###
  getOpaqueRef: =>
    return key

  ###*
   * Clone this Template, creates a new Template
   * @param     {String}  name - A name for the new clone
   * @return    {Promise}
  ###
  clone: (name) =>
    debug "clone()"
    new Promise (resolve, reject) =>
      unless name
        reject "Must provide a name for the clone"
      else
        session.request("VM.clone", [key, name]).then (value) =>
          debug value
          xenAPI.templateCollection.findOpaqueRef(value).then (clonedTemplate) ->
            resolve clonedTemplate
        .catch (e) ->
          debug e
          reject e

  pushOtherConfig: =>
    debug "pushOtherConfig()"
    new Promise (resolve, reject) =>
      session.request("VM.set_other_config", [key, @other_config]).then (value) =>
        debug value
        resolve()
      .catch (e) ->
        debug e
        reject e

  provision: =>
    debug "provision()"
    new Promise (resolve, reject) =>
      session.request("VM.provision", [key]).then (value) =>
        debug value
        resolve()
      .catch (e) ->
        debug e
        reject e

module.exports = Template
