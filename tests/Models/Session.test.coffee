chai = require 'chai'
chaiAsPromised = require 'chai-as-promised'
expect = chai.expect
sinon = require 'sinon'
sinonChai = require 'sinon-chai'

chai.use sinonChai
chai.use chaiAsPromised

describe "Session", ->
	Session = require '../../lib/Models/Session'

	describe "constructor", ->
		it "should throw unless apiClient is provided", ->
			expect(-> new Session()).to.throw /Must provide apiClient/

	describe "logout", ->
		session = undefined

		beforeEach ->
			session = new Session {}

		it "should reject if not currently logged in", (done) ->
			promise = session.logout()

			expect(promise).to.eventually.be.rejected.and.notify(done)
