-- Text Field v1.0
local utf8 = require("utf8")
local textfield = {}

textfield.focusedField = nil
textfield.fields = {}

textfield.useCursor = true
textfield.cursorLifetime = 0
textfield.cursorAlpha = 1

function textfield.new(fillerText, x, y, width, height, align, overflow, sx, sy)
	
	local tf = {}
	
	tf.fillerText = fillerText
	tf.x = x
	tf.y = y
	tf.width = width
	tf.height = height or width
	tf.currentHeight = tf.height
	
	tf.align = 'left'
	tf.overflow = overflow or "wrap"
	
	tf.sx = sx or 1
	tf.sy = sy or tf.sx
	tf.txtColor = {0,0,0}
	tf.ftColor = {0.6,0.6,0.6}
	tf.bgColor = {1,1,1}
	tf.image = nil
	
	tf.text = ""
	tf.font = love.graphics.getFont()
	tf.maxChar = math.huge
	
	tf.focused = false
	tf.cursorWidth = 1
	tf.blinkSpeed = 0.5
	
	tf.padding = { l = 0, r = 0, t = 0, b = 0 }
	tf.centerY = false
	
	tf.darkened = false
	
	tf.interactable = true
	
	function tf.setImage(i)
		if type(i) == 'string' then 	-- Convert string to Image
			tf.image = love.graphics.newImage(i)
		elseif type(i) == 'Image' then	-- Keep Image as Image
			tf.image = i
		else							-- Neither Image or string was given
			print('tf.setImage accepts types of string and Image, nothing else')
			return
		end
		
		-- Find scale factors to fit image to width and height
		local w, h = tf.image:getDimensions()
		tf.isx = tf.width / w
		tf.isy = tf.height / h
	end
	
	function tf.setFont(f)
		if type(f) == 'string' then		-- Convert string to Font
			tf.font = love.graphics.newFont(f)
		elseif type(f) == 'Font' then	-- Keep Font as Font
			tf.font = f
		else							-- Neither Font or string was given
			print('tf.setFont accepts types of string and Font, nothing else')
		end
	end
	
	function tf.destroy()
		textfield.fields[tf.index] = nil
		tf.font:release()
		tf.image:release()
		tf = nil
	end
	
	tf.onFocus = function() end
	tf.endFocus = function() end
	
	tf.onEndType = function(t) end
	tf.onType = function(t) end
	
	tf.index = #textfield.fields+1
	table.insert(textfield.fields, tf)
	
	return tf
	
end

function textfield.update(dt)
	if textfield.focusedField ~= nil then
		textfield.cursorLifetime = textfield.cursorLifetime + dt
		if textfield.cursorLifetime > textfield.focusedField.blinkSpeed then
			if textfield.cursorAlpha == 0 then
				textfield.cursorAlpha = 1
			else
				textfield.cursorAlpha = 0
			end
			textfield.cursorLifetime = 0
		end
	end
end

function textfield.draw(f)
	if f ~= nil then
		-- ONCLICK DARKENING
		
		local c = {f.bgColor[1], f.bgColor[2], f.bgColor[3], f.bgColor[4]}
		if f.darkened == true then
			c[1] = textfield.clamp(f.bgColor[1] - 0.1, 0, 1)
			c[2] = textfield.clamp(f.bgColor[2] - 0.1, 0, 1)
			c[3] = textfield.clamp(f.bgColor[3] - 0.1, 0, 1)
		end
		
		-- BACKGROUND
		
		love.graphics.setColor(c)
		if f.image == nil then
			love.graphics.setColor({0,0,0})
			
			local h = f.height
			if f.overflow == "fit" then
				h =	h + f.font:getHeight() * math.floor((f.font:getWidth(f.text)) / (f.width - f.padding.l)) + f.padding.b
			end
			
			love.graphics.rectangle('line', f.x, f.y, f.width, h, 3)
			love.graphics.setColor(c)
			love.graphics.rectangle('fill', f.x, f.y, f.width, h, 3)
			
			f.currentHeight = h
			
		else
			love.graphics.draw(f.image, f.x, f.y, 0, f.isx, f.isy)
		end
		
		-- PRINT TEXT
		
		local texty = f.y
		if f.centerY == true then texty = f.y + f.height/2 - f.font:getHeight()/2 end
		
		if f.text ~= "" then
			local textf = { f.txtColor, f.text }
			love.graphics.printf(textf, f.font, f.x + f.padding.l, texty, f.width - f.padding.r)
		else
			local textf = { f.ftColor, f.fillerText }
			love.graphics.printf(textf, f.font, f.x + f.padding.l, texty, f.width - f.padding.r)
		end
		
		-- TYPING CURSOR
		
		if f.focused == true and textfield.useCursor == true then
			local fh = f.font:getHeight()
			local cx = f.x + (f.font:getWidth(f.text) % (f.width - f.padding.l + f.padding.r + 0.01)) + f.padding.l
			local cy = f.y + (f.height - fh) / 2 + f.font:getHeight() * textfield.clamp(math.floor((f.font:getWidth(f.text) - 0.01) / (f.width - f.padding.l)), 0, math.huge)
			
			love.graphics.setColor({0.1,0.1,0.1, textfield.cursorAlpha})
			love.graphics.rectangle('fill', cx, cy, f.cursorWidth, fh)
		end
		
		-- ONRELEASE DARKENING
		
		if f.darkened == true and love.mouse.isDown(1) == false then
			f.darkened = false
		end

		return
	end

	for k, field in ipairs(textfield.fields) do
		textfield.draw(field)
	end
end

function textfield.textinput(t)
	if textfield.focusedField ~= nil then
		--print(#textfield.focusedField.text)
		if #textfield.focusedField.text >= textfield.focusedField.maxChar then
			return
		end
		textfield.focusedField.onType(t)
		textfield.focusedField.text = textfield.focusedField.text .. t
	end
end

function textfield.keypressed(key)
	if key == "backspace" and textfield.focusedField ~= nil then
        local byteoffset = utf8.offset(textfield.focusedField.text, -1)
        if byteoffset then
            textfield.focusedField.text = string.sub(textfield.focusedField.text, 1, byteoffset - 1)
        end
    end
	if key == 'c' and love.keyboard.isDown('lctrl') and textfield.focusedField ~= nil then
		love.system.setClipboardText(textfield.focusedField.text)
	end
	if key == 'v' and love.keyboard.isDown('lctrl') and textfield.focusedField ~= nil then
		textfield.focusedField.text = textfield.focusedField.text .. love.system.getClipboardText()
	end
	if key == 'x' and love.keyboard.isDown('lctrl') and textfield.focusedField ~= nil then
		love.system.setClipboardText(textfield.focusedField.text)
		textfield.focusedField.text = ""
	end
	if key == 'return' and textfield.focusedField ~= nil then
		textfield.focusedField.onEndType(textfield.focusedField.text)
	end
end

function textfield.mousepressed(x, y, button)
	local foundField = false
	
	for k, field in ipairs(textfield.fields) do
		if field.x < x and field.x + field.width > x and field.y < y and field.y + field.currentHeight > y and field.interactable == true then
			if textfield.focused ~= field then
		
				if textfield.focusedField ~= nil then
					textfield.focusedField.focused = false
					textfield.focusedField.endFocus()
				end
				
				textfield.focusedField = field
				field.focused = true
				field.darkened = true
				field.onFocus()
				
				foundField = true
				
				textfield.cursorLifetime = 0
				textfield.cursorAlpha = 1
				
				break
			end
		end
	end
	
	if foundField == false and textfield.focusedField ~= nil then
		textfield.focusedField.focused = false
		textfield.focusedField.endFocus()
		textfield.focusedField.onEndType(textfield.focusedField.text)
		textfield.focusedField = nil
	end
end

function textfield.lerp(v0, v1, t)
  return (1 - t) * v0 + t * v1
end

function textfield.clamp(val, lower, upper)
    if lower > upper then lower, upper = upper, lower end
    return math.max(lower, math.min(upper, val))
end

return textfield