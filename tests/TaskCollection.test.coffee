chai = require 'chai'
chaiAsPromised = require 'chai-as-promised'
expect = chai.expect
sinon = require 'sinon'
sinonChai = require 'sinon-chai'
Promise = require 'bluebird'

chai.use sinonChai
chai.use chaiAsPromised

describe "TaskCollection", ->
	session = undefined
	TaskCollection = undefined
	Task = undefined

	beforeEach ->
		session =
			request: ->

		TaskCollection = require '../lib/TaskCollection'
		Task = require '../lib/Models/Task'

	describe "constructor", ->
		beforeEach ->

		afterEach ->

		it "should throw unless session is provided", ->
			expect(-> new TaskCollection()).to.throw /Must provide session/

		it "should throw unless Task is provided", ->
			expect(-> new TaskCollection session).to.throw /Must provide Task/

	describe "list()", (done) ->
		requestStub = undefined
		taskCollection = undefined

		beforeEach ->
			requestStub = sinon.stub session, "request", ->
				new Promise (resolve, reject) ->
					resolve([])

			taskCollection = new TaskCollection session, Task

		afterEach ->
			requestStub.restore()

		it "should call `task.get_all_records` on the API", (done) ->
			taskCollection.list().then ->
				expect(requestStub).to.have.been.calledWith "task.get_all_records"
				done()
			.catch (e) ->
				done e

		it "should resolve if the API call is successful", (done) ->
			promise = taskCollection.list()

			expect(promise).to.eventually.be.fulfilled.and.notify done

		it "should reject if the API call resolves with undefined", (done) ->
			requestStub.restore()
			requestStub = sinon.stub session, "request", ->
				new Promise (resolve, reject) ->
					resolve()

			promise = taskCollection.list()

			expect(promise).to.eventually.be.rejected.and.notify done

		it "should reject if the API call fails", (done) ->
			requestStub.restore()
			requestStub = sinon.stub session, "request", ->
				new Promise (resolve, reject) ->
					reject()

			promise = taskCollection.list()

			expect(promise).to.eventually.be.rejected.and.notify done

		it "should resolve with an empty array if the API returns nothing", (done) ->
			taskCollection.list().then (tasks) ->
				expect(tasks).to.deep.equal([])
				done()
			.catch (e) ->
				done e

		it "should return instances of Task", (done) ->
			validTask =
				uuid: 'abcd'
				name_label: "test123"
				created: "Thu Jan 01 1970 00:00:00 GMT+0000 (GMT)"
				allowed_operations: []
				status: "pending"

			requestStub.restore()
			requestStub = sinon.stub session, "request", ->
				new Promise (resolve, reject) ->
					resolve({ 'abcd': validTask })

			taskCollection.list().then (tasks) ->
				expect(tasks[0]).to.be.an.instanceof(Task)
				expect(tasks[0]).to.not.be.an.instanceof(TaskCollection)
				done()
			.catch (e) ->
				done e

		it "should not return Tasks that fail validation", (done) ->
			invalidTask =
				uuid: 'abcd'

			requestStub.restore()
			requestStub = sinon.stub session, "request", ->
				new Promise (resolve, reject) ->
					resolve({ 'abcd': invalidTask })

			taskCollection.list().then (tasks) ->
				expect(tasks).to.deep.equal([])
				done()
			.catch (e) ->
				done e
