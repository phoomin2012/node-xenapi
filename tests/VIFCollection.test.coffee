chai = require 'chai'
chaiAsPromised = require 'chai-as-promised'
expect = chai.expect
sinon = require 'sinon'
sinonChai = require 'sinon-chai'
Promise = require 'bluebird'

chai.use sinonChai
chai.use chaiAsPromised

describe "VIFCollection", ->
  session = undefined
  VIFCollection = undefined
  VIF = undefined
  XenAPI = undefined

  beforeEach ->
    session =
      request: ->

    VIFCollection = require '../lib/VIFCollection'
    VIF = require '../lib/Models/VIF'

    XenAPI =
      'session': session

  describe "constructor", ->
    beforeEach ->

    afterEach ->

    it "should throw unless session is provided", ->
      expect(-> new VIFCollection()).to.throw /Must provide session/

    it "should throw unless VIF is provided", ->
      expect(-> new VIFCollection session).to.throw /Must provide VIF/

    it "should throw unless XenAPI is provided", ->
      expect(-> new VIFCollection session, VIF).to.throw /Must provide xenAPI/

  describe "list()", (done) ->
    requestStub = undefined
    vifCollection = undefined

    beforeEach ->
      requestStub = sinon.stub session, "request", ->
        new Promise (resolve, reject) ->
          resolve([])

      vifCollection = new VIFCollection session, VIF, XenAPI

    afterEach ->
      requestStub.restore()

    it "should call `VIF.get_all_records` on the API", (done) ->
      vifCollection.list().then ->
        expect(requestStub).to.have.been.calledWith "VIF.get_all_records"
        done()
      .catch (e) ->
        done e

    it "should resolve if the API call is successful", (done) ->
      promise = vifCollection.list()

      expect(promise).to.eventually.be.fulfilled.and.notify done

    it "should reject if the API call resolves with undefined", (done) ->
      requestStub.restore()
      requestStub = sinon.stub session, "request", ->
        new Promise (resolve, reject) ->
          resolve()

      promise = vifCollection.list()

      expect(promise).to.eventually.be.rejected.and.notify done

    it "should reject if the API call fails", (done) ->
      requestStub.restore()
      requestStub = sinon.stub session, "request", ->
        new Promise (resolve, reject) ->
          reject()

      promise = vifCollection.list()

      expect(promise).to.eventually.be.rejected.and.notify done

    it "should resolve with an empty array if the API returns nothing", (done) ->
      vifCollection.list().then (vms) ->
        expect(vms).to.deep.equal([])
        done()
      .catch (e) ->
        done e
