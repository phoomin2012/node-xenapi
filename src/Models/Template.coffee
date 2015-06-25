debug = require('debug') 'XenAPI:Template'
Promise = require 'bluebird'
_ = require 'lodash'

class Template
  session = undefined
  xenAPI = undefined

  ###*
  * Construct Template. Very similar to a VM, but not yet set up.
  * @class
  * @param      {Object}   session - An instance of Session
  * @param      {Object}   template - A JSON object representing this Template
  * @param      {String}   opaqueRef - The OpaqueRef handle to this template
  * @param      {Object}   xenAPI - An instance of XenAPI.
  ###
  constructor: (_session, _template, _opaqueRef, _xenAPI) ->
    debug "constructor()"
    debug _template, _opaqueRef

    unless _session
      throw Error "Must provide `session`"
    unless _template
      throw Error "Must provide `template`"
    unless _opaqueRef
      throw Error "Must provide `opaqueRef`"
    unless _xenAPI
      throw Error "Must provide `xenAPI`"
    unless _template.is_a_template && !_template.is_control_domain && _template.uuid
      throw Error "`template` does not describe a valid Template"

    #These can safely go into class scope because there is only one instance of each.
    session = _session
    xenAPI = _xenAPI

    @opaqueRef = _opaqueRef
    @uuid = _template.uuid
    @name = _template.name_label
    @description = _template.name_description
    @VIFs = _template.VIFs || []
    @VBDs = _template.VBDs || []
    @other_config = _template.other_config
    #We imply the minimum RAM from the maximum RAM the template supports. XenCenter does this.
    @ram_minimum = _template.memory_static_max
    #Same with CPU count.
    @vcpu_minimum = _template.VCPUs_max

  toJSON: =>
    {
      name: @name
      description: @description
    }

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
        session.request("VM.clone", [@opaqueRef, name]).then (value) =>
          debug value
          xenAPI.templateCollection.findOpaqueRef(value).then (clonedTemplate) ->
            resolve clonedTemplate
        .catch (e) ->
          debug e
          reject e

  pushOtherConfig: =>
    debug "pushOtherConfig()"
    new Promise (resolve, reject) =>
      session.request("VM.set_other_config", [@opaqueRef, @other_config]).then (value) =>
        debug value
        resolve()
      .catch (e) ->
        debug e
        reject e

  provision: =>
    debug "provision()"
    new Promise (resolve, reject) =>
      session.request("VM.provision", [@opaqueRef]).then (value) =>
        debug value
        xenAPI.vmCollection.findOpaqueRef(@opaqueRef).then (vm) ->
          resolve vm
      .catch (e) ->
        debug e
        reject e

  getVBDs: =>
    debug "getVBDs()"
    new Promise (resolve, reject) =>
      vbdSearchPromises = []
      _.each @VBDs, (vbd) ->
        vbdSearchPromise = xenAPI.vbdCollection.findOpaqueRef(vbd)
        vbdSearchPromises.push vbdSearchPromise

      Promise.all(vbdSearchPromises).then (vbdObjects) ->
        debug vbdObjects
        resolve(vbdObjects)
      .catch (e) ->
        debug e
        reject e


module.exports = Template
