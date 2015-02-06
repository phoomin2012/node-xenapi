chai = require 'chai'
chaiAsPromised = require 'chai-as-promised'
expect = chai.expect
sinon = require 'sinon'
sinonChai = require 'sinon-chai'

chai.use sinonChai
chai.use chaiAsPromised

describe "APIClient", ->
	APIClient = require '../lib/APIClient'

	describe "constructor", ->
		it "should throw unless xmlrpc is provided", ->
			expect(-> new APIClient()).to.throw /Must provide xmlrpc/

		it "should throw unless options are provided", ->
			expect(-> new APIClient({})).to.throw /Must provide options/
