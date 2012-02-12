# inspired by http://safalra.com/web-design/javascript/mac-style-dock/

``
(($, window, document) ->

	pluginName = 'dock'

	defaults =
		range: 2
		openCloseSpeed: 0.2
		minSize: 100
		maxSize: 150
		itemClass: '.item'
	
	class Plugin

		plugin = undefined

		constructor: (@element, options) ->

			@options = $.extend {}, defaults, options
			@element = $(element)

			@sizes = []
			@items = @closeTimeout = @closeInterval = @openInterval = null
			@scale = 0

			plugin = @

			@init()
		
		init: ->
			@items = @element.find(@options.itemClass)

			@items.each (i) ->
				$(this).css('background-color', '#'+Math.floor(Math.random()*16777215).toString(16))
				$(this).bind('mousemove', itemMouseMoveHandler)
				$(this).bind('mouseleave', itemMouseLeaveHandler)
		
		# private
		open = ->
				window.clearTimeout @closeTimeout
				@closeTimeout = null
				window.clearInterval @closeInterval
				@closeInterval = null
		
				if @scale != 1 && !@openInterval
					@openInterval = window.setInterval(openLoop, 20)
		
		openLoop = ->
			if plugin.scale < 1
				 plugin.scale += plugin.options.openCloseSpeed
			
			if plugin.scale >= 1
				plugin.scale = 1
				window.clearInterval @openInterval
				@openInterval = null
			
			updateItems()
		
		close = ->
			if !@closeTimeout && !@closeInterval
				@closeTimeout = window.setTimeout(closeLoop, 100)

		closeLoop = ->
			@closeTimeout = null
				
			if @openInterval
				window.clearInterval @openInterval
				@openInterval = null;
			
			@closeInterval = window.setInterval(closeLoop2, 20)

		closeLoop2 = ->
			if plugin.scale > 0
				plugin.scale -= plugin.options.openCloseSpeed
						
				if plugin.scale <= 0 
					plugin.scale = 0
					window.clearInterval @closeInterval
					@closeInterval = null;
						
				updateItems()

		updateItems = ->
			plugin.items.each (i) ->
				size = plugin.options.minSize + plugin.scale * (plugin.sizes[i] - plugin.options.minSize)
				$(this).css({width: size, height: size, marginTop: (plugin.options.maxSize - size), zIndex: size})

		# event handlers
		itemMouseMoveHandler = (e) ->
			
			open()

			minSize = plugin.options.minSize
			maxSize = plugin.options.maxSize
			range = plugin.options.range

			index = $(this).index()
			across = e.offsetX / (plugin.sizes[index] || minSize)

			if across
				plugin.items.each (i) ->
					if i < index - range || i > index + range
						size = minSize
					else if i == index
						size = maxSize
					else if i < index
						size = minSize + Math.round((maxSize - minSize - 1) * (Math.cos((i - index - across + 1) / range * Math.PI) + 1) / 2)
					else
						size = minSize + Math.round((maxSize - minSize - 1) * (Math.cos((i - index - across) / range * Math.PI) + 1) / 2)

					plugin.sizes[i] = size;
			
			updateItems()

		itemMouseLeaveHandler = (e) ->
			close()
		

	$.fn[pluginName] = (options) ->
		@each ->
			if !$.data(this, "plugin_#{pluginName}")
				$.data(@, "plugin_#{pluginName}", new Plugin(@, options))
)(jQuery, window, document)