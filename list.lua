local List = {}

List.lists = {}

function List.new(choices, x, y, width, height, font, align, txtClr, bckClr)

	local newl = {}
	
	newl.x = x
	newl.y = y
	newl.width = width
	newl.height = height or width
	
	newl.font = font or love.graphics.getFont()
	newl.align = align or 'left'
	
	newl.padding = 2
	
	newl.txtClr = txtClr or {0,0,0}
	newl.bckClr = bckClr or {1,1,1}
	newl.nonBckClr = {0.6,0.6,0.6}
	newl.selectedTxtClr = {1,1,1}
	newl.selectedBckClr = {0,0.5,1}
	
	newl.choicesOffset = 0
	
	newl.choices = choices
	newl.choiceH = 13
	newl.index = 0
	
	newl.interactable = true
	
	newl.onSelect = function(i) end
	newl.onDeselect = function(i) end
	
	newl.stencil = function()
		love.graphics.rectangle("fill", newl.x, newl.y, newl.width, newl.height)
	end
	
	table.insert(List.lists, newl)
	
	return newl

end

function List.draw(l)
	
	if l ~= nil then
	
		love.graphics.stencil(l.stencil, "replace")
		
		love.graphics.setStencilTest("greater", 0)
	
		for i=1, #l.choices do
			
			if l.index == i then
				love.graphics.setColor(l.selectedBckClr)
			else
				if l.interactable then
					love.graphics.setColor(l.bckClr)
				else
					love.graphics.setColor(l.nonBckClr)
					l.index = 0
				end
			end
			love.graphics.rectangle('fill', l.x, (l.y + l.choiceH * (i-1)) - l.choicesOffset, l.width, l.choiceH)
			
			if l.index == i then
				love.graphics.setColor(l.selectedTxtClr)
			else
				love.graphics.setColor(l.txtClr)
			end
			love.graphics.printf(l.choices[i], l.font, l.x + l.padding, (l.y + l.choiceH * (i-1)) - l.choicesOffset, math.huge, l.align)
			
		end
		
		love.graphics.setStencilTest()
	
		love.graphics.setColor{0,0,0}
		love.graphics.rectangle('line', l.x, l.y, l.width, l.height)
	
	else
		for k,v in ipairs(List.lists) do
			List.draw(v)
		end
	end
	
end

function List.mousepressed(x, y, button)
	
	if button == 1 then
		for k,list in ipairs(List.lists) do
			if list.interactable then
			local hitIndex = false
			
			if x > list.x and x < list.x + list.width and y + list.choicesOffset < list.y + list.choiceH * #list.choices then
				for i=#list.choices,1,-1 do
					if y + list.choicesOffset > list.y + list.choiceH * (i-1) then
						list.onSelect(i)
						list.index = i
						hitIndex = true
						break
					end
				end
			end
			
			if hitIndex == false and x > list.x and x < list.x + list.width and y + list.choicesOffset > list.y and y + list.choicesOffset < list.y + list.height then
				list.onDeselect(list.index)
				list.index = 0
			end
			end
		end
	end
	
end

function List.wheelmoved(x, y)
	for k,list in ipairs(List.lists) do
		if list.choiceH * #list.choices > list.height then
		local mx, my = love.mouse.getPosition()
		if mx > list.x and mx < list.x + list.width and my > list.y and my < list.y + list.height then
			list.choicesOffset = List.clamp(list.choicesOffset - (y * 7), 0, (list.choiceH * #list.choices) - list.height + 2)
		end
		end
	end
end

function List.clamp(val, min, max)
	if val > max then
		return max
	elseif val < min then
		return min
	else
		return val
	end
end

return List