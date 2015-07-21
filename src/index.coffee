APIClient = require './APIClient'
ConsoleCollection = require './ConsoleCollection'
Console = require './Models/Console'
GuestMetricsCollection = require './GuestMetricsCollection'
GuestMetrics = require './Models/GuestMetrics'
MetricsCollection = require './MetricsCollection'
Metrics = require './Models/Metrics'
NetworkCollection = require './NetworkCollection'
Network = require './Models/Network'
PoolCollection = require './PoolCollection'
Pool = require './Models/Pool'
Session = require './Models/Session'
SRCollection = require './SRCollection'
SR = require './Models/SR'
TaskCollection = require './TaskCollection'
Task = require './Models/Task'
TemplateCollection = require './TemplateCollection'
Template = require './Models/Template'
VBDCollection = require './VBDCollection'
VBD = require './Models/VBD'
VDICollection = require './VDICollection'
VDI = require './Models/VDI'
VIFCollection = require './VIFCollection'
VIF = require './Models/VIF'
VMCollection = require './VMCollection'
VM = require './Models/VM'
xmlrpc = require 'xmlrpc'

module.exports = (options) ->
  apiClient = new APIClient xmlrpc, options
  session = new Session apiClient

  xenAPI = {
    session: session
  }

  consoleCollection = new ConsoleCollection session, Console, xenAPI
  guestMetricsCollection = new GuestMetricsCollection session, GuestMetrics, xenAPI
  metricsCollection = new MetricsCollection session, Metrics, xenAPI
  networkCollection = new NetworkCollection session, Network, xenAPI
  poolCollection = new PoolCollection session, Pool, xenAPI
  srCollection = new SRCollection session, SR, xenAPI
  taskCollection = new TaskCollection session, Task, xenAPI
  templateCollection = new TemplateCollection session, Template, xenAPI
  vbdCollection = new VBDCollection session, VBD, xenAPI
  vdiCollection = new VDICollection session, VDI, xenAPI
  vifCollection = new VIFCollection session, VIF, xenAPI
  vmCollection = new VMCollection session, VM, xenAPI

  xenAPI.consoleCollection = consoleCollection
  xenAPI.guestMetricsCollection = guestMetricsCollection
  xenAPI.metricsCollection = metricsCollection
  xenAPI.networkCollection = networkCollection
  xenAPI.poolCollection = poolCollection
  xenAPI.srCollection = srCollection
  xenAPI.taskCollection = taskCollection
  xenAPI.templateCollection = templateCollection
  xenAPI.vbdCollection = vbdCollection
  xenAPI.vdiCollection = vdiCollection
  xenAPI.vifCollection = vifCollection
  xenAPI.vmCollection = vmCollection

  xenAPI.models =
    Console: Console,
    GuestMetrics: GuestMetrics,
    Metrics: Metrics,
    Network: Network,
    Pool: Pool,
    SR: SR,
    Task: Task,
    VBD: VBD,
    VDI: VDI,
    VIF: VIF,
    VM: VM

  return xenAPI
