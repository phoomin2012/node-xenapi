chai = require 'chai'
chaiAsPromised = require 'chai-as-promised'
expect = chai.expect
sinon = require 'sinon'
sinonChai = require 'sinon-chai'
Promise = require 'bluebird'

chai.use sinonChai
chai.use chaiAsPromised

describe "VM", ->
	session = undefined
	VM = undefined
	XenAPI = undefined

	beforeEach ->
		session =
			request: ->

		VM = require '../../lib/Models/VM'

		XenAPI =
			'session': session

	describe "constructor", ->
		validVM = undefined
		opaqueRef = undefined

		beforeEach ->
			validVM = 
				uuid: 'abcd'
				is_a_template: false
				is_control_domain: false
			opaqueRef = 'OpaqueRef:abcd'

		afterEach ->

		it "should throw unless session is provided", ->
			expect(-> new VM()).to.throw /Must provide `session`/

		it "should throw unless vm is provided", ->
			expect(-> new VM session).to.throw /Must provide `vm`/

		it "should throw unless opaqueRef is provided", ->
			expect(-> new VM session, validVM).to.throw /Must provide `opaqueRef`/

		it "should throw unless XenAPI is provided", ->
			expect(-> new VM session, validVM, "OpaqueRef").to.throw /Must provide `xenAPI`/

		it "should throw if vm does not have a UUID", ->
			expect(-> new VM session, { is_a_template: false, is_control_domain: false }, opaqueRef, XenAPI).to.throw /`vm` does not describe a valid VM/

		it "should throw if vm is a template", ->
			expect(-> new VM session, { uuid: 'abcd', is_a_template: true, is_control_domain: false }, opaqueRef, XenAPI).to.throw /`vm` does not describe a valid VM/

		it "should throw if vm is a control domain", ->
			expect(-> new VM session, { uuid: 'abcd', is_a_template: false, is_control_domain: true }, opaqueRef, XenAPI).to.throw /`vm` does not describe a valid VM/

		it "should assign the passed uuid to `uuid` property", ->
			vmTemplate = validVM

			vmTemplate.uuid = 'abcd'
			vm = new VM session, vmTemplate, opaqueRef, XenAPI

			expect(vm.uuid).to.equal(vmTemplate.uuid)

		it "should assign the passed label to `name` property", ->
			vmTemplate = validVM

			vmTemplate.name_label = 'abcd'
			vm = new VM session, vmTemplate, opaqueRef, XenAPI

			expect(vm.name).to.equal(vmTemplate.name_label)

		it "should assign the passed description to `description` property", ->
			vmTemplate = validVM

			vmTemplate.name_description = 'abcd'
			vm = new VM session, vmTemplate, opaqueRef, XenAPI

			expect(vm.description).to.equal(vmTemplate.name_description)

		it "should set the `xenToolsInstalled` property based on whether guest_metrics are available", ->
			vmTemplate = validVM

			vmTemplate.guest_metrics = 'OpaqueRef:NULL'
			vm = new VM session, vmTemplate, opaqueRef, XenAPI

			expect(vm.xenToolsInstalled).to.equal(false)

			vmTemplate.guest_metrics = 'OpaqueRef:abcd'
			vm = new VM session, vmTemplate, opaqueRef, XenAPI

			expect(vm.xenToolsInstalled).to.equal(true)

		it "should assign the passed power state to `powerState` property", ->
			vmTemplate = validVM

			vmTemplate.power_state = 'abcd'
			vm = new VM session, vmTemplate, opaqueRef, XenAPI

			expect(vm.powerState).to.equal(vmTemplate.power_state)

	describe "refreshPowerState()", ->
		opaqueRef = undefined
		vm = undefined
		requestStub = undefined

		beforeEach ->
			validVM =
				uuid: 'abcd'
				is_a_template: false
				is_control_domain: false
			opaqueRef = 'OpaqueRef:abcd'

			vm = new VM session, validVM, opaqueRef, XenAPI
			requestStub = sinon.stub session, "request", ->
				new Promise (resolve, reject) ->
					resolve()

		afterEach ->

		it "should call VM.get_power_state on the API", (done) ->
			vm.refreshPowerState().then ->
				expect(requestStub).to.have.been.calledWith "VM.get_power_state"
				done()
			.catch (e) ->
				done e

		it "should pass the OpaqueRef of the VM to the API", (done) ->
			vm.refreshPowerState().then ->
				expect(requestStub).to.have.been.calledWith sinon.match.any, [opaqueRef]
				done()
			.catch (e) ->
				done e

		it "should reject if the API call fails", (done) ->
			requestStub.restore()
			requestStub = sinon.stub session, "request", ->
				new Promise (resolve, reject) ->
					reject()

			promise = vm.refreshPowerState()

			expect(promise).to.eventually.be.rejected.and.notify done

		it "should resolve if the API call is successfull", (done) ->
			promise = vm.refreshPowerState()

			expect(promise).to.eventually.be.fulfilled.and.notify done

		it "should resolve with the latest power state of the VM", (done) ->
			requestStub.restore()
			requestStub = sinon.stub session, "request", ->
				new Promise (resolve, reject) ->
					resolve("Suspended")

			vm.refreshPowerState().then (powerState) ->
				expect(powerState).to.equal("Suspended")
				done()
			.catch (e) ->
				done e

		it "should update the VM to the latest power state", (done) ->
			requestStub.restore()
			requestStub = sinon.stub session, "request", ->
				new Promise (resolve, reject) ->
					resolve("Suspended")

			vm.refreshPowerState().then () ->
				expect(vm.powerState).to.equal("Suspended")
				done()
			.catch (e) ->
				done e

	describe "pause()", ->
		opaqueRef = undefined
		vm = undefined
		requestStub = undefined
		refreshPowerStateStub = undefined

		beforeEach ->
			validVM =
				uuid: 'abcd'
				is_a_template: false
				is_control_domain: false
			opaqueRef = 'OpaqueRef:abcd'

			vm = new VM session, validVM, opaqueRef, XenAPI
			requestStub = sinon.stub session, "request", ->
				new Promise (resolve, reject) ->
					resolve()
			refreshPowerStateStub = sinon.stub vm, "refreshPowerState", ->
				new Promise (resolve, reject) ->
					resolve("Running")

		afterEach ->
			requestStub.restore()
			refreshPowerStateStub.restore()

		it "should initially refresh the powerState of the VM", (done) ->
			vm.pause().then ->
				expect(refreshPowerStateStub).to.have.been.calledOnce
				done()
			.catch (e) ->
				done e

		it "should reject if the powerState of the VM is `Paused`", (done) ->
			refreshPowerStateStub.restore()
			refreshPowerStateStub = sinon.stub vm, "refreshPowerState", ->
				new Promise (resolve, reject) ->
					resolve("Paused")

			promise = vm.pause()

			expect(promise).to.eventually.be.rejected.and.notify done

		it "should reject if the powerState of the VM is `Suspended`", (done) ->
			refreshPowerStateStub.restore()
			refreshPowerStateStub = sinon.stub vm, "refreshPowerState", ->
				new Promise (resolve, reject) ->
					resolve("Suspended")

			promise = vm.pause()

			expect(promise).to.eventually.be.rejected.and.notify done

		it "should reject if the powerState of the VM is `Halted`", (done) ->
			refreshPowerStateStub.restore()
			refreshPowerStateStub = sinon.stub vm, "refreshPowerState", ->
				new Promise (resolve, reject) ->
					resolve("Halted")

			promise = vm.pause()

			expect(promise).to.eventually.be.rejected.and.notify done

		it "should resolve if the powerState of the VM is `Running`", (done) ->
			promise = vm.pause()

			expect(promise).to.eventually.be.fulfilled.and.notify done

		it "should call `VM.pause` on the API", (done) ->
			vm.pause().then ->
				expect(requestStub).to.have.been.calledWith "VM.pause"
				done()
			.catch (e) ->
				done e

		it "should pass OpaqueRef for the VM to the API", (done) ->
			vm.pause().then ->
				expect(requestStub).to.have.been.calledWith sinon.match.any, [opaqueRef]
				done()
			.catch (e) ->
				done e

	describe "unpause()", ->
		opaqueRef = undefined
		vm = undefined
		requestStub = undefined
		refreshPowerStateStub = undefined

		beforeEach ->
			validVM =
				uuid: 'abcd'
				is_a_template: false
				is_control_domain: false
			opaqueRef = 'OpaqueRef:abcd'

			vm = new VM session, validVM, opaqueRef, XenAPI
			requestStub = sinon.stub session, "request", ->
				new Promise (resolve, reject) ->
					resolve()
			refreshPowerStateStub = sinon.stub vm, "refreshPowerState", ->
				new Promise (resolve, reject) ->
					resolve("Paused")

		afterEach ->
			requestStub.restore()
			refreshPowerStateStub.restore()

		it "should initially refresh the powerState of the VM", (done) ->
			vm.unpause().then ->
				expect(refreshPowerStateStub).to.have.been.calledOnce
				done()
			.catch (e) ->
				done e

		it "should reject if the powerState of the VM is `Running`", (done) ->
			refreshPowerStateStub.restore()
			refreshPowerStateStub = sinon.stub vm, "refreshPowerState", ->
				new Promise (resolve, reject) ->
					resolve("Running")

			promise = vm.unpause()

			expect(promise).to.eventually.be.rejected.and.notify done

		it "should reject if the powerState of the VM is `Suspended`", (done) ->
			refreshPowerStateStub.restore()
			refreshPowerStateStub = sinon.stub vm, "refreshPowerState", ->
				new Promise (resolve, reject) ->
					resolve("Suspended")

			promise = vm.unpause()

			expect(promise).to.eventually.be.rejected.and.notify done

		it "should reject if the powerState of the VM is `Halted`", (done) ->
			refreshPowerStateStub.restore()
			refreshPowerStateStub = sinon.stub vm, "refreshPowerState", ->
				new Promise (resolve, reject) ->
					resolve("Halted")

			promise = vm.unpause()

			expect(promise).to.eventually.be.rejected.and.notify done

		it "should resolve if the powerState of the VM is `Paused`", (done) ->
			promise = vm.unpause()

			expect(promise).to.eventually.be.fulfilled.and.notify done

		it "should call `VM.unpause` on the API", (done) ->
			vm.unpause().then ->
				expect(requestStub).to.have.been.calledWith "VM.unpause"
				done()
			.catch (e) ->
				done e

		it "should pass OpaqueRef for the VM to the API", (done) ->
			vm.unpause().then ->
				expect(requestStub).to.have.been.calledWith sinon.match.any, [opaqueRef]
				done()
			.catch (e) ->
				done e

	describe "suspend()", ->
		opaqueRef = undefined
		vm = undefined
		requestStub = undefined
		refreshPowerStateStub = undefined

		beforeEach ->
			validVM =
				uuid: 'abcd'
				is_a_template: false
				is_control_domain: false
			opaqueRef = 'OpaqueRef:abcd'

			vm = new VM session, validVM, opaqueRef, XenAPI
			requestStub = sinon.stub session, "request", ->
				new Promise (resolve, reject) ->
					resolve()
			refreshPowerStateStub = sinon.stub vm, "refreshPowerState", ->
				new Promise (resolve, reject) ->
					resolve("Running")

		afterEach ->
			requestStub.restore()
			refreshPowerStateStub.restore()

		it "should initially refresh the powerState of the VM", (done) ->
			vm.suspend().then ->
				expect(refreshPowerStateStub).to.have.been.calledOnce
				done()
			.catch (e) ->
				done e

		it "should reject if the powerState of the VM is `Paused`", (done) ->
			refreshPowerStateStub.restore()
			refreshPowerStateStub = sinon.stub vm, "refreshPowerState", ->
				new Promise (resolve, reject) ->
					resolve("Paused")

			promise = vm.suspend()

			expect(promise).to.eventually.be.rejected.and.notify done

		it "should reject if the powerState of the VM is `Suspended`", (done) ->
			refreshPowerStateStub.restore()
			refreshPowerStateStub = sinon.stub vm, "refreshPowerState", ->
				new Promise (resolve, reject) ->
					resolve("Suspended")

			promise = vm.suspend()

			expect(promise).to.eventually.be.rejected.and.notify done

		it "should reject if the powerState of the VM is `Halted`", (done) ->
			refreshPowerStateStub.restore()
			refreshPowerStateStub = sinon.stub vm, "refreshPowerState", ->
				new Promise (resolve, reject) ->
					resolve("Halted")

			promise = vm.suspend()

			expect(promise).to.eventually.be.rejected.and.notify done

		it "should resolve if the powerState of the VM is `Running`", (done) ->
			promise = vm.suspend()

			expect(promise).to.eventually.be.fulfilled.and.notify done

		it "should call `VM.suspend` on the API", (done) ->
			vm.suspend().then ->
				expect(requestStub).to.have.been.calledWith "VM.suspend"
				done()
			.catch (e) ->
				done e

		it "should pass OpaqueRef for the VM to the API", (done) ->
			vm.suspend().then ->
				expect(requestStub).to.have.been.calledWith sinon.match.any, [opaqueRef]
				done()
			.catch (e) ->
				done e

	describe "resume()", ->
		opaqueRef = undefined
		vm = undefined
		requestStub = undefined
		refreshPowerStateStub = undefined

		beforeEach ->
			validVM =
				uuid: 'abcd'
				is_a_template: false
				is_control_domain: false
			opaqueRef = 'OpaqueRef:abcd'

			vm = new VM session, validVM, opaqueRef, XenAPI
			requestStub = sinon.stub session, "request", ->
				new Promise (resolve, reject) ->
					resolve()
			refreshPowerStateStub = sinon.stub vm, "refreshPowerState", ->
				new Promise (resolve, reject) ->
					resolve("Suspended")

		afterEach ->
			requestStub.restore()
			refreshPowerStateStub.restore()

		it "should initially refresh the powerState of the VM", (done) ->
			vm.resume().then ->
				expect(refreshPowerStateStub).to.have.been.calledOnce
				done()
			.catch (e) ->
				done e

		it "should reject if the powerState of the VM is `Paused`", (done) ->
			refreshPowerStateStub.restore()
			refreshPowerStateStub = sinon.stub vm, "refreshPowerState", ->
				new Promise (resolve, reject) ->
					resolve("Paused")

			promise = vm.resume()

			expect(promise).to.eventually.be.rejected.and.notify done

		it "should reject if the powerState of the VM is `Running`", (done) ->
			refreshPowerStateStub.restore()
			refreshPowerStateStub = sinon.stub vm, "refreshPowerState", ->
				new Promise (resolve, reject) ->
					resolve("Running")

			promise = vm.resume()

			expect(promise).to.eventually.be.rejected.and.notify done

		it "should reject if the powerState of the VM is `Halted`", (done) ->
			refreshPowerStateStub.restore()
			refreshPowerStateStub = sinon.stub vm, "refreshPowerState", ->
				new Promise (resolve, reject) ->
					resolve("Halted")

			promise = vm.resume()

			expect(promise).to.eventually.be.rejected.and.notify done

		it "should resolve if the powerState of the VM is `Suspended`", (done) ->
			promise = vm.resume()

			expect(promise).to.eventually.be.fulfilled.and.notify done

		it "should call `VM.resume` on the API", (done) ->
			vm.resume().then ->
				expect(requestStub).to.have.been.calledWith "VM.resume"
				done()
			.catch (e) ->
				done e

		it "should pass OpaqueRef for the VM to the API", (done) ->
			vm.resume().then ->
				expect(requestStub).to.have.been.calledWith sinon.match.any, [opaqueRef, sinon.match.any, sinon.match.any]
				done()
			.catch (e) ->
				done e

		it "should pass `false` as the default value for `start_paused` to the API", (done) ->
			vm.resume().then ->
				expect(requestStub).to.have.been.calledWith sinon.match.any, [sinon.match.any, false, sinon.match.any]
				done()
			.catch (e) ->
				done e

		it "should pass `false` as the default value for `force` to the API", (done) ->
			vm.resume().then ->
				expect(requestStub).to.have.been.calledWith sinon.match.any, [sinon.match.any, sinon.match.any, false]
				done()
			.catch (e) ->
				done e
