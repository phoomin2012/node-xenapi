chai = require 'chai'
chaiAsPromised = require 'chai-as-promised'
expect = chai.expect
sinon = require 'sinon'
sinonChai = require 'sinon-chai'

chai.use sinonChai
chai.use chaiAsPromised

describe "APIClient", ->
	xmlrpc = undefined
	xmlrpcclient = undefined
	APIClient = undefined

	beforeEach ->
		xmlrpc =
			createClient: ->
				return xmlrpcclient
		xmlrpcclient =
			methodCall: ->

		APIClient = require '../lib/APIClient'

	describe "constructor", ->
		createClientStub = null

		beforeEach ->
			createClientStub = sinon.stub xmlrpc, "createClient", ->
				return null

		afterEach ->
			createClientStub.restore()

		it "should throw unless xmlrpc is provided", ->
			expect(-> new APIClient()).to.throw /Must provide xmlrpc/

		it "should throw unless options are provided", ->
			expect(-> new APIClient xmlrpc).to.throw /Must provide options/

		it "should throw unless `host` is provided in options", ->
			expect(-> new APIClient xmlrpc, {}).to.throw /Must provide `host` in options/

		it "should throw unless `port` is provided in options", ->
			expect(-> new APIClient xmlrpc, { host: "test" }).to.throw /Must provide `port` in options/

		it "should construct an xmlrpc-client using provided options", ->
			options =
				host: "testHost"
				port: 80

			new APIClient xmlrpc, options

			expect(createClientStub).to.have.been.calledWith(options)

	describe "request", ->
		apiClient = undefined
		methodCallStub = undefined

		beforeEach ->
			options =
				host: "testHost"
				port: 80

			methodCallStub = sinon.stub xmlrpcclient, "methodCall", (method, args, cb) ->
				cb null, {Value: ""}

			apiClient = new APIClient xmlrpc, options

		afterEach ->
			methodCallStub.restore()

		it "should pass on provided parameters to xmlrpc client", ->
			methodName = "testModule.testMethod"
			methodArgs = ["arrayArg1", "arrayArg2"]

			apiClient.request methodName, methodArgs

			expect(methodCallStub).to.have.been.calledWith(methodName, methodArgs)

		it "should resolve on successful requests", (done) ->
			promise = apiClient.request()

			expect(promise).to.eventually.be.fulfilled.and.notify done

		it "should reject on failed requests", (done) ->
			methodCallStub.restore()
			methodCallStub = sinon.stub xmlrpcclient, "methodCall", (method, args, cb) ->
				cb { error: "" }, null

			promise = apiClient.request()

			expect(promise).to.eventually.be.rejected.and.notify done
