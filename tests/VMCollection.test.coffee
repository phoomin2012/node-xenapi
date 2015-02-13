chai = require 'chai'
chaiAsPromised = require 'chai-as-promised'
expect = chai.expect
sinon = require 'sinon'
sinonChai = require 'sinon-chai'
Promise = require 'bluebird'

chai.use sinonChai
chai.use chaiAsPromised

describe "VMCollection", ->
	session = undefined
	VMCollection = undefined

	beforeEach ->
		session =
			request: ->

		VMCollection = require '../lib/VMCollection'

	describe "constructor", ->
		beforeEach ->

		afterEach ->

		it "should throw unless session is provided", ->
			expect(-> new VMCollection()).to.throw /Must provide session/

		it "should throw unless VM is provided", ->
			expect(-> new VMCollection session).to.throw /Must provide VM/

	describe "list()", (done) ->
		requestStub = undefined
		vmCollection = undefined

		beforeEach ->
			requestStub = sinon.stub session, "request", ->
				new Promise (resolve, reject) ->
					resolve()

			vmCollection = new VMCollection session, {}

		afterEach ->
			requestStub.restore()

		it "should call `VM.get_all_records` on the API", (done) ->
			vmCollection.list().then ->
				expect(requestStub).to.have.been.calledWith "VM.get_all_records"
				done()
			.catch (e) ->
				done e

		it "should resolve if the API call is successful", (done) ->
			promise = vmCollection.list()

			expect(promise).to.eventually.be.fulfilled.and.notify done

		it "should reject if the API call fails", (done) ->
			requestStub.restore()
			requestStub = sinon.stub session, "request", ->
				new Promise (resolve, reject) ->
					reject()

			promise = vmCollection.list()

			expect(promise).to.eventually.be.rejected.and.notify done

		it "should resolve with an empty array if the API returns nothing", (done) ->
			vmCollection.list().then (vms) ->
				expect(vms).to.deep.equal([])
				done()
			.catch (e) ->
				done e

		it "should not return VMs that are actually templates", (done) ->
			requestStub.restore()
			requestStub = sinon.stub session, "request", ->
				new Promise (resolve, reject) ->
					resolve([{ is_a_template: true }])

			vmCollection.list().then (vms) ->
				expect(vms).to.deep.equal([])
				done()
			.catch (e) ->
				done e

		it "should not return VMs that are a control domain", (done) ->
			requestStub.restore()
			requestStub = sinon.stub session, "request", ->
				new Promise (resolve, reject) ->
					resolve([{ is_control_domain: true }])

			vmCollection.list().then (vms) ->
				expect(vms).to.deep.equal([])
				done()
			.catch (e) ->
				done e

		it "should return VMs that are not templates or control domains", (done) ->
			validVM =
				is_control_domain: false
				is_a_template: false

			requestStub.restore()
			requestStub = sinon.stub session, "request", ->
				new Promise (resolve, reject) ->
					resolve([validVM])

			vmCollection.list().then (vms) ->
				expect(vms).to.deep.equal([validVM])
				done()
			.catch (e) ->
				done e
