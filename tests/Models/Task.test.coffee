chai = require 'chai'
chaiAsPromised = require 'chai-as-promised'
expect = chai.expect
sinon = require 'sinon'
sinonChai = require 'sinon-chai'
Promise = require 'bluebird'

chai.use sinonChai
chai.use chaiAsPromised

describe "Task", ->
	session = undefined
	Task = undefined
	XenAPI = undefined
	requestStub = undefined

	beforeEach ->
		session =
			request: ->

		requestStub = sinon.stub session, "request", ->
			new Promise (resolve, reject) ->
				resolve()

		Task = require '../../lib/Models/Task'

		XenAPI =
			'session': session

	describe "constructor", ->
		beforeEach ->

		afterEach ->

		it "should throw unless session is provided", ->
			expect(-> new Task()).to.throw /Must provide `session`/

		it "should throw unless JSON task is provided", ->
			expect(-> new Task session).to.throw /Must provide `task`/

		it "should throw unless OpaqueRef is provided", ->
			expect(-> new Task session, {}).to.throw /Must provide `opaqueRef`/

		it "should throw unless XenAPI is provided", ->
			validTask =
				allowed_operations: []
				status: "success"
			expect(-> new Task session, validTask, "OpaqueRef").to.throw /Must provide `xenAPI`/

		it "should throw if a JSON task does not provide a valid representation of Task", ->
			invalidTask = {}

			expect(-> new Task session, invalidTask, "OpaqueRef", XenAPI).to.throw /`task` does not describe a valid Task/

		it "should not throw if a JSON task provides a valid representation of Task", ->
			validTask =
				allowed_operations: []
				status: "success"

			expect(-> new Task session, validTask, "OpaqueRef", XenAPI).not.to.throw()

		it "should assign the `uuid` property from the JSON representation to itself", ->
			validTask =
				allowed_operations: []
				status: "success"
				uuid: "abcd1234"

			task = new Task session, validTask, "OpaqueRef", XenAPI

			expect(task.uuid).to.equal validTask.uuid

		it "should assign the `name_label` property from the JSON representation to itself", ->
			validTask =
				allowed_operations: []
				status: "success"
				name_label: "abcd1234"

			task = new Task session, validTask, "OpaqueRef", XenAPI

			expect(task.name).to.equal validTask.name_label

		
		it "should assign the `name_description` property from the JSON representation to itself", ->
			validTask =
				allowed_operations: []
				status: "success"
				name_description: "abcd1234"

			task = new Task session, validTask, "OpaqueRef", XenAPI

			expect(task.description).to.equal validTask.name_description

		it "should assign the `allowed_operations` property from the JSON representation to itself", ->
			validTask =
				allowed_operations: []
				status: "success"

			task = new Task session, validTask, "OpaqueRef", XenAPI

			expect(task.allowed_operations).to.deep.equal validTask.allowed_operations

		it "should assign the `status` property from the JSON representation to itself", ->
			validTask =
				allowed_operations: []
				status: "success"

			task = new Task session, validTask, "OpaqueRef", XenAPI

			expect(task.status).to.equal validTask.status

		it "should assign the `created` property from the JSON representation to itself", ->
			validTask =
				allowed_operations: []
				status: "success"
				created: new Date()

			task = new Task session, validTask, "OpaqueRef", XenAPI

			expect(task.created).to.equal validTask.created

		it "should assign the `finished` property from the JSON representation to itself", ->
			validTask =
				allowed_operations: []
				status: "success"
				finished: new Date()

			task = new Task session, validTask, "OpaqueRef", XenAPI

			expect(task.finished).to.equal validTask.finished

		it "should assign the `progress` property from the JSON representation to itself", ->
			validTask =
				allowed_operations: []
				status: "success"
				progress: 0

			task = new Task session, validTask, "OpaqueRef", XenAPI

			expect(task.progress).to.equal validTask.progress

	describe "cancel()", ->
		task = undefined
		validTask = undefined

		beforeEach ->
			validTask =
				allowed_operations: ["cancel"]
				status: "success"

			task = new Task session, validTask, "OpaqueRef", XenAPI

		afterEach ->

		it "should return a Promise", ->
			expect(task.cancel()).to.be.an.instanceof Promise

		it "should reject its promise if `cancel` is not an allowed operation", (done) ->
			validTask =
				allowed_operations: []
				status: "success"

			task = new Task session, validTask, "OpaqueRef", XenAPI

			expect(task.cancel()).to.eventually.be.rejectedWith(/Operation is not allowed/).and.notify done

		it "should call `task.cancel` on the API", (done) ->
			task.cancel().then ->
				expect(requestStub).to.have.been.calledWith "task.cancel"
				done()
			.catch (e) ->
				done e

		it "should call `task.cancel` with the OpaqueRef of the Task", (done) ->
			opaqueRef = "abcd1234"
			task = new Task session, validTask, opaqueRef, XenAPI

			task.cancel().then ->
				expect(requestStub).to.have.been.calledWith "task.cancel", [opaqueRef]
				done()
			.catch (e) ->
				done e
