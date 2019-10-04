local Drop = {}

Drop.dropdowns = {}
Drop.selected = nil

function Drop.new(choices, x, y, width, height, font, align, textClr, backClr)
	
	local d = {}
	
	d.x = x
	d.y = y
	d.width = width
	d.height = height or d.width
	d.choiceH = d.height	
	
	d.font = font or love.graphics.getFont()
	d.fh = d.font:getHeight()
	d.align = align or 'center'
	d.textClr = textClr or {0,0,0}
	d.backClr = backClr or {1,1,1}
	d.choiceTxtClr = d.textClr
	d.choiceBckClr = d.backClr
	
	d.index = 1
	d.choices = choices or {"Dropdown", "Test A", "Test B", "Test C"}
	
	d.enabled = true
	
	d.draw = true
	d.drawn = false
	
	d.isSelected = false
	
	d.onSelect = function() end
	d.onDeselect = function() end
	d.onChoose = function(i) end
	
	d.setChoices = function(c)
		d.choices = c
	end
	
	d.setFont = function(f)
		d.font = love.graphics.newFont(f)
		d.fh = d.font:getHeight()
	end
	
	table.insert(Drop.dropdowns, d)
	
	return d
	
end

function Drop.draw(d)
	if d ~= nil and d.enabled then
		
		if d.index > #d.choices then d.index = 1 end
		
		if d.isSelected then
			love.graphics.setColor{d.backClr[1] - 0.2,d.backClr[2] - 0.2,d.backClr[3] - 0.2}
		else
			love.graphics.setColor(d.backClr)
		end
		love.graphics.rectangle('fill', d.x, d.y, d.width, d.height)
		
		love.graphics.setColor(d.textClr)
		love.graphics.printf(d.choices[d.index], d.font, d.x, d.y + d.height/2 - d.fh/2, d.width, d.align)
		
		if d.isSelected then
			for i=1,#d.choices do
				love.graphics.setColor(d.choiceBckClr)
				love.graphics.rectangle('fill', d.x, d.y + d.height + d.choiceH * (i-1), d.width, d.choiceH)
				
				love.graphics.setColor(d.choiceTxtClr)
				love.graphics.printf(d.choices[i], d.font, d.x, d.y + d.choiceH/2 - d.fh/2 + d.height + d.choiceH * (i-1), d.width, d.align)
				
				love.graphics.rectangle('line', d.x, d.y + d.height + d.choiceH * (i-1), d.width, d.choiceH)
			end
		end
		
		love.graphics.rectangle('line', d.x, d.y, d.width, d.height)
		
		d.drawn = true
	else
		for k,d in ipairs(Drop.dropdowns) do
			if d.draw == true and d.drawn == false and d.enabled then
				Drop.draw(d)
			end
		end
	end
	if Drop.selected == nil then
		for k,v in ipairs(Drop.dropdowns) do
			v.isSelected = false
		end
	end	
	-- Reset drawn status on dropdowns
	for k,v in ipairs(Drop.dropdowns) do
		v.drawn = false
	end
end

function Drop.mousepressed(x,y,button)

	local clickedNothing = true
	local selectOption = false
	
	for k,d in ipairs(Drop.dropdowns) do
		if d.enabled == true then
		if d.x < x and d.x + d.width > x and d.y < y and d.y + d.height > y then
			if d.isSelected then
				break
			end
			Drop.selected = d
			d.onSelect()
			d.isSelected = true
			clickedNothing = false
		end
		end
	end
	
	if Drop.selected ~= nil then
		for i=1,#Drop.selected.choices do
			if Drop.selected.x < x and Drop.selected.x + Drop.selected.width > x and y > Drop.selected.y + Drop.selected.height + Drop.selected.choiceH * (i-1) and y < Drop.selected.y + Drop.selected.height + Drop.selected.choiceH * i then
				Drop.selected.index = i
				Drop.selected.onChoose(i)
				selectOption = true
				break
			end
		end
	end
	
	if clickedNothing == true and Drop.selected ~= nil then
		Drop.selected.onDeselect()
		Drop.selected.isSelected = false
		Drop.selected = nil
	end
	
	return clickedNothing, selectOption
end

return Drop