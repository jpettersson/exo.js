Spine ?= require('spine')
Ajax ?= Spine.Ajax

class SessionHelper extends Spine.Module
	@extend Spine.Events
	
	@ON_SESSION = "SessionHelper:onSession"
	@AJAX_ERROR = "SessionHelper:ajaxError"
	@NO_SESSION_ERROR = "SessionHelper:noSessionError"
	
	constructor: ->
		super
		
		@url ?= ''
		@globalEvents = false
	
	@checkSession: ->
		
		ajaxProperties =
			xhrFields:
				withCredentials: true
			contentType: 'application/json'
			dataType: 'json'
			processData: false
			headers: {'X-Requested-With': 'XMLHttpRequest'}
			type: "GET",
			error: @ajaxError,
			success: @ajaxSuccess

		$.ajax($.extend({}, ajaxProperties, {url: @url}))	
		
	@ajaxSuccess: (data, status, xhr) ->
		console.log data
		
		if data.user and data.user.id
			SessionHelper.trigger(SessionHelper.ON_SESSION, data.user.id)			
		else
			SessionHelper.trigger(SessionHelper.NO_SESSION_ERROR)

	@ajaxError: (xhr, statusText, error) ->
		SessionHelper.trigger(SessionHelper.AJAX_ERROR)
 	
module.exports = SessionHelper