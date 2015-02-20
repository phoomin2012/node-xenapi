chai = require 'chai'
chaiAsPromised = require 'chai-as-promised'
expect = chai.expect
sinon = require 'sinon'
sinonChai = require 'sinon-chai'
Promise = require 'bluebird'

chai.use sinonChai
chai.use chaiAsPromised

describe "Session", ->
	Session = undefined
	apiClient = undefined

	beforeEach ->
		Session = require '../../lib/Models/Session'
		apiClient =
			request: ->

	describe "constructor", ->
		it "should throw unless apiClient is provided", ->
			expect(-> new Session()).to.throw /Must provide apiClient/

	describe "login", ->
		session = undefined
		requestStub = undefined

		beforeEach ->
			requestStub = sinon.stub apiClient, "request", ->
				new Promise (resolve, reject) ->
					resolve()
			session = new Session apiClient

		afterEach ->
			requestStub.restore()

		it "should call `session.login_with_password` from the API", (done) ->
			session.login().finally ->
				expect(requestStub).to.have.been.calledWith "session.login_with_password"
				done()
			.catch (e) ->
				done e

		it "should pass `username` and `password` to the API", (done) ->
			session.login("test", "pass").finally ->
				expect(requestStub).to.have.been.calledWith "session.login_with_password", ["test", "pass"]
				done()
			.catch (e) ->
				done e

		it "should reject if already logged in", (done) ->
			session.login().then ->
				promise = session.login()
				expect(promise).to.eventually.be.rejected.and.notify done
			.catch (e) ->
				done e

	describe "logout", ->
		session = undefined
		requestStub = undefined

		beforeEach ->
			requestStub = sinon.stub apiClient, "request", ->
				new Promise (resolve, reject) ->
					resolve()
			session = new Session apiClient

		afterEach ->
			requestStub.restore()

		it "should reject if not currently logged in", (done) ->
			promise = session.logout()

			expect(promise).to.eventually.be.rejected.and.notify done

		it "should call `session.logout` from the API if currently logged in", (done) ->
			session.login().then ->
				session.logout().finally ->
					expect(requestStub).to.have.been.calledWith "session.logout"
					done()
				.catch (e) ->
					done e

		it "should pass the session ref from `login` to the API", (done) ->
			sessionRef = "abcd1234"
			requestStub.restore()
			requestStub = sinon.stub apiClient, "request", (method) ->
				new Promise (resolve, reject) ->
					unless method == "session.logout"
						resolve(sessionRef)
					else
						resolve()

			session.login().then ->
				session.logout().finally ->
					expect(requestStub).to.have.been.calledWith "session.logout", [sessionRef]
					done()
				.catch (e) ->
					done e

		it "should resolve when logout is complete", (done) ->
			session.login().then ->
				promise = session.logout()
				expect(promise).to.eventually.be.fulfilled.and.notify done
			.catch (e) ->
				done e

	describe "request", ->
		session = undefined
		requestStub = undefined

		beforeEach ->
			requestStub = sinon.stub apiClient, "request", ->
				new Promise (resolve, reject) ->
					resolve()
			session = new Session apiClient

		afterEach ->
			requestStub.restore()

		it "should throw if not logged in", ->
			expect(-> session.request()).to.throw /Must be logged in to make API requests/

		it "should call `request` on apiClient if logged in", (done) ->
			session.login().then ->
				session.request()
				expect(requestStub).to.have.been.called
				done()
			.catch (e) ->
				done e

		it "should call `request` with the method name passed to it", (done) ->
			session.login().then ->
				session.request "test.method"
				expect(requestStub).to.have.been.calledWith "test.method"
				done()
			.catch (e) ->
				done e

		it "should call `request` with the args passed to it and sessionID", (done) ->
			sessionRef = "abcd1234"
			requestStub.restore()
			requestStub = sinon.stub apiClient, "request", (method) ->
				new Promise (resolve, reject) ->
					resolve(sessionRef)

			session.login().then ->
				session.request "test.method"
				expect(requestStub).to.have.been.calledWith "test.method", [sessionRef]
				done()
			.catch (e) ->
				done e

		it "should resolve with the value resolved by apiClient if successful", (done) ->
			resolveValue = "test123"
			requestStub.restore()
			requestStub = sinon.stub apiClient, "request", (method) ->
				new Promise (resolve, reject) ->
					unless method == "test.method"
						resolve()
					else
						resolve(resolveValue)

			session.login().then ->
				session.request("test.method").then (value) ->
					expect(value).to.equal(resolveValue)
					done()
			.catch (e) ->
				done e

		it "should reject with the error rejected by apiClient if failure", (done) ->
			rejectValue = "test123"
			requestStub.restore()
			requestStub = sinon.stub apiClient, "request", (method) ->
				new Promise (resolve, reject) ->
					unless method == "test.method"
						resolve()
					else
						reject(rejectValue)

			session.login().then ->
				session.request("test.method").catch (e) ->
					expect(e).to.equal(rejectValue)
					done()
			.catch (e) ->
				done e
