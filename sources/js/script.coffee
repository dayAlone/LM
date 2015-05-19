end = 'transitionend webkitTransitionEnd oTransitionEnd otransitionend MSTransitionEnd'

delay = (ms, func) -> setTimeout func, ms

sizeAction = ->
	$('.tabs').elem('content').height $(window).height() - 50

debounce = (func, wait, immediate) ->
	timeout = undefined
	->
		context = this
		args = arguments

		later = ->
			timeout = null
			if !immediate
				func.apply context, args
			return

		callNow = immediate and !timeout
		clearTimeout timeout
		timeout = setTimeout(later, wait)
		if callNow
			func.apply context, args
		return
triggerNav = ->
	if $('.toolbar').elem('trigger').hasMod 'active'
		$('.toolbar').elem('trigger').mod 'active', false
	else
		$('.toolbar').elem('trigger').mod 'active', true

	if $('body').hasClass 'open'
		$('body').removeClass 'open', false
	else
		$('body').addClass 'open', true

	sizeAction()

$(document).ready ->
	$('.sidebar').elem('trigger').on 'click scroll touchstart mousewheel', (e)->
		debounce triggerNav(), 400

	$('.toolbar').elem('trigger').on 'click', (e)->
		console.log 1
		triggerNav()
		e.preventDefault()
	
	$('.present').elem('slider').on('fotorama:showend', (e, f)->
		id = f.activeFrame.id
		$('.present').elem('content').mod 'active', false
		$("#p-#{id}").mod 'active', true
		console.log $("#p-#{id}")
	).fotorama()
	
	x = undefined
	$(window).resize ->
		clearTimeout(x)
		x = delay 200, ()->
			sizeAction()

	scrollTimer = false
	$(window).scroll ->
		clearTimeout scrollTimer
		if !$('.scroll-fix').hasMod 'on'
			$('.scroll-fix').mod 'on', true
		scrollTimer = delay 300, ()->
			$('.scroll-fix').mod 'on', false

	delay 300, ()->
		sizeAction()