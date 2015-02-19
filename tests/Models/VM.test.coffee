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

	beforeEach ->
		session =
			request: ->

		VM = require '../../lib/Models/VM'

	describe "constructor", ->
		validVM = undefined
		key = undefined

		before ->
			validVM = 
				uuid: 'abcd',
				is_a_template: false,
				is_control_domain: false
			key = 'OpaqueRef:abcd'

		beforeEach ->

		afterEach ->

		it "should throw unless session is provided", ->
			expect(-> new VM()).to.throw /Must provide `session`/

		it "should throw unless vm is provided", ->
			expect(-> new VM session).to.throw /Must provide `vm`/

		it "should throw if vm does nto have a UUID", ->
			expect(-> new VM session, { is_a_template: false, is_control_domain: false }).to.throw /`vm` does not describe a valid VM/

		it "should throw if vm is a template", ->
			expect(-> new VM session, { uuid: 'abcd', is_a_template: true, is_control_domain: false }).to.throw /`vm` does not describe a valid VM/

		it "should throw if vm is a control domain", ->
			expect(-> new VM session, { uuid: 'abcd', is_a_template: false, is_control_domain: true }).to.throw /`vm` does not describe a valid VM/

		it "should throw unless key is provided", ->
			expect(-> new VM session, validVM).to.throw /Must provide `key`/

		it "should assign the passed uuid to `uuid` property", ->
			vmTemplate = validVM

			vmTemplate.uuid = 'abcd'
			vm = new VM session, vmTemplate, key

			expect(vm.uuid).to.equal(vmTemplate.uuid)

		it "should assign the passed label to `name` property", ->
			vmTemplate = validVM

			vmTemplate.name_label = 'abcd'
			vm = new VM session, vmTemplate, key

			expect(vm.name).to.equal(vmTemplate.name_label)

		it "should assign the passed description to `description` property", ->
			vmTemplate = validVM

			vmTemplate.name_description = 'abcd'
			vm = new VM session, vmTemplate, key

			expect(vm.description).to.equal(vmTemplate.name_description)

		it "should set the `xenToolsInstalled` property based on whether guest_metrics are available", ->
			vmTemplate = validVM

			vmTemplate.guest_metrics = 'OpaqueRef:NULL'
			vm = new VM session, vmTemplate, key

			expect(vm.xenToolsInstalled).to.equal(false)

			vmTemplate.guest_metrics = 'OpaqueRef:abcd'
			vm = new VM session, vmTemplate, key

			expect(vm.xenToolsInstalled).to.equal(true)

		it "should assign the passed power state to `powerState` property", ->
			vmTemplate = validVM

			vmTemplate.power_state = 'abcd'
			vm = new VM session, vmTemplate, key

			expect(vm.powerState).to.equal(vmTemplate.power_state)