# inspired by http://safalra.com/web-design/javascript/mac-style-dock/

``
(($, window, document) ->

	pluginName = 'dock'

	defaults =
		range: 2
		openCloseSpeed: 0.2
		minSize: 100
		itemClass: '.item'
	
	class Plugin

		plugin = undefined

		constructor: (@element, options) ->

			@options = $.extend {}, defaults, options
			@element = $(element)

			@sizes = []
			@minSize = []
			@maxSize = []

			@items = @closeTimeout = @closeInterval = @openInterval = null
			@scale = 0
			plugin = @

			@init()

		init: ->
			@items = @element.find(@options.itemClass)
			@items.each (i) ->

				img = $(this).find('img')
				img.data('size', {width: img.width(), height: img.height()})

				plugin.minSize[i] = if $(this).data('min') then $(this).data('min') else plugin.options.minSize
				plugin.maxSize[i] = img.height()

				$(this).bind('mousemove', itemMouseMoveHandler).bind('mouseleave', itemMouseLeaveHandler)
				$(this).css('margin-top', plugin.maxSize[i] - plugin.minSize[i])
				resizeImage(img, plugin.minSize[i])


		# private
		open = ->
				window.clearTimeout @closeTimeout
				@closeTimeout = null
				window.clearInterval @closeInterval
				@closeInterval = null
				
				if @scale != 1 && !@openInterval
					@openInterval = window.setInterval( ->
						if plugin.scale < 1
						 plugin.scale += plugin.options.openCloseSpeed
						
						if plugin.scale >= 1
							plugin.scale = 1
							window.clearInterval @openInterval
							@openInterval = null
						
						updateItems()
					, 20)
		
		close = ->
			if !@closeTimeout && !@closeInterval
				@closeTimeout = window.setTimeout( ->
					@closeTimeout = null
				
					if @openInterval
						window.clearInterval @openInterval
						@openInterval = null;
					
					@closeInterval = window.setInterval( ->
						if plugin.scale > 0
							plugin.scale -= plugin.options.openCloseSpeed
									
							if plugin.scale <= 0 
								plugin.scale = 0
								window.clearInterval @closeInterval
								@closeInterval = null;
									
							updateItems()
					, 20)
				, 100)

		updateItems = ->
			plugin.items.each (i) ->

				# log plugin.minSize[i] / plugin.options.minSize
				# if plugin.minSize[i] != plugin.options.minSize
				#	size = Math.min(plugin.minSize[i] + plugin.scale * (plugin.sizes[i] - plugin.minSize[i]), plugin.maxSize[i])
				
				size = Math.min(plugin.minSize[i] + plugin.scale * (plugin.sizes[i] - plugin.minSize[i]), plugin.maxSize[i])

				$(this).css('margin-top', plugin.maxSize[i] - size)
				resizeImage($(this).find('img'), size)

		resizeImage = (img, height) ->
			width = img.data('size').width * (height / img.data('size').height)
			size = {width: Math.round(width), height: Math.round(height)}
			img.attr(size).css(size)


		# event handlers
		itemMouseMoveHandler = (e) ->
			
			open()

			index = $(this).index()
			minSize = plugin.minSize[index]
			maxSize = plugin.maxSize[index]
			range = plugin.options.range
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