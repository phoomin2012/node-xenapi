debug = require('debug') 'XenAPI:Console'
Promise = require 'bluebird'
net = require 'net'
url = require 'url'

class Console
  session = undefined
  xenAPI = undefined

  ###*
  * Construct Console
  * @class
  * @param      {Object}   session - An instance of Session
  * @param      {Object}   cosnole - A JSON object representing this Console
  * @param      {String}   opaqueRef - The OpaqueRef handle to this Console
  * @param      {Object}   xenAPI - An instance of XenAPI
  ###
  constructor: (_session, _console, _opaqueRef, _xenAPI) ->
    debug "constructor()"
    debug _console, _opaqueRef

    unless _session
      throw Error "Must provide `session`"
    unless _console
      throw Error "Must provide `console`"
    unless _opaqueRef
      throw Error "Must provide `opaqueRef`"

    #These can safely go into class scope because there is only one instance of each.
    session = _session
    xenAPI = _xenAPI

    @opaqueRef = _opaqueRef
    @uuid = _console.uuid
    @protocol = _console.protocol
    @other_config = _console.other_config
    @location = _console.location

  connect: =>
    debug "connect()"
    new Promise (resolve, reject) =>
      parsedLocation = url.parse @location

      options =
        host: parsedLocation.host
        port: 80

      socket = net.connect options, =>
        socket.write "CONNECT #{parsedLocation.path}&session_id=#{session.sessionID} HTTP/1.0\r\n\r\n"

      socket.on 'readable', =>
        #The first 78 bytes are HTTP response and are not needed
        N = 78
        chunk = socket.read(N);

        if (chunk.toString().indexOf("HTTP/1.1 200 OK") == 0)
          socket.removeAllListeners 'readable'
          #It is now safe for someone to take the socket and listen for 'data', as the HTTP junk is gone.
          resolve(socket)

module.exports = Console
