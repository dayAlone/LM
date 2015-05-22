end = 'transitionend webkitTransitionEnd oTransitionEnd otransitionend MSTransitionEnd'

delay = (ms, func) -> setTimeout func, ms

sizeAction = ->
	$('.tabs').elem('content').height $(window).height() - 50

	scroll = $('.packages').elem('scroll')

	if scroll.length > 0
		el = scroll.find('a:nth-child(2)')
		left = ( el.position().left + el.width()/2) - $('body').width()/2
		$('.packages').elem('scroll').animate({
			scrollLeft: left
		}, 300);

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

triggerNav = (trigger)->
	el = $("[data-target='#{trigger.data('target')}']")
	if el.hasMod 'active'
		el.mod 'active', false
	else
		el.mod 'active', true

	mod = 'open--'+ trigger.data('target')
	if $('body').hasClass mod
		$('body').removeClass 'open'
		$('body').removeClass mod
	else
		$('body').addClass mod + ' open'

	sizeAction()

$(document).ready ->
	$('.sidebar').elem('trigger').on 'click scroll touchstart mousewheel', (e)->
		debounce triggerNav($(this)), 400

	$('.toolbar').elem('trigger').on 'click', (e)->
		triggerNav $(this)
		e.preventDefault()

	$('.toolbar').elem('profile').on 'click', (e)->
		triggerNav $(this)
		e.preventDefault()

	$('.present').elem('slider').on('fotorama:showend', (e, f)->
		id = f.activeFrame.id
		$('.present').elem('content').mod 'active', false
		$("#p-#{id}").mod 'active', true
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