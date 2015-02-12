chai = require 'chai'
chaiAsPromised = require 'chai-as-promised'
expect = chai.expect
sinon = require 'sinon'
sinonChai = require 'sinon-chai'

chai.use sinonChai
chai.use chaiAsPromised

describe "APIClient", ->
	xmlrpc =
		createClient: ->
			return xmlrpcclient
	xmlrpcclient =
		methodCall: ->

	APIClient = require '../lib/APIClient'

	describe "constructor", ->
		createClientStub = null

		after ->
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
			createClientStub = sinon.stub xmlrpc, "createClient", ->
				return null

			options =
				host: "testHost"
				port: 80

			new APIClient xmlrpc, options

			expect(createClientStub).to.have.been.calledWith(options)
