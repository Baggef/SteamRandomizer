local tf = require('textfield')
local sb = require('simplebutton')
local dp = require('dropdown')
local ls = require('list')
local saveData = require("saveData")
require('alias')

love.window.setMode(300, 300)
screen = { x = love.graphics.getWidth(), y = love.graphics.getHeight() }

love.keyboard.setKeyRepeat(true)

function love.load()
	
	-- VARIABLES
	
	gameDir = ""
	
	games = {}
	groups = {"All"}
	
	selectedGame = "None"
	rolls = 0
	
	menuState = "Main"
	
	-- Get game list
	
	games["All"] = setgamedir([[C:\Program Files (x86)\Steam\steamapps\common]])
	
	print('Found games: \n-----------------------------------')
	for k,v in ipairs(games["All"]) do
		print(v)
	end
	print('\n')
	
	-- Load game
	
	if love.filesystem.getInfo("saveFile.sav") ~= nil then
		loadGame()
	end
	
	-- GRAPHICAL USER INTERFACE
	
	sb.default.alignment = 'center'
	
	groupDrop = dp.new(groups, 7, 7, ((screen.x / 5) * 4) - 14, (screen.y / 5) - 7)
	groupDrop.choiceH = 25
	groupDrop.choiceBckClr = {0.9,0.9,0.9}
	
	settingsButton = sb.new("Fuck", (screen.x / 5) * 4, 7, (screen.y / 5) - 7, (screen.y / 5) - 7)
	function settingsButton.onClick()
		if menuState == "Settings" then
			setMenuState("Main")
		else
			setMenuState("Settings")
		end
	end
	
	newRanGame = sb.new("ANOTHER GAME!", screen.x / 2 - 55, ((screen.y / 5) * 2) + 20, 110, 50)
	function newRanGame.onClick()
	
		local currentGroup = games[groups[groupDrop.index]]
		selectedGame = getRandomGame(currentGroup)
		
		print("Game: " .. (selectedGame or "None"))
		
	end
	
	randomGameB = sb.new("GIVE ME A FUCKIN' GAME!", 7, (screen.y / 5) + 14, screen.x - 14, ((screen.y / 5) * 4) - 28)
	function randomGameB.onClick()
		setMenuState("Reroll")
	
		local currentGroup = games[groups[groupDrop.index]]
		selectedGame = getRandomGame(currentGroup)
		
		print("Game: " .. (selectedGame or "None"))
		
	end
	
	returnToMain = sb.new("X", screen.x - 27, (screen.y / 5) + 14, 20, 20)
	returnToMain.disabledColor = {1,1,1}
	function returnToMain.onRelease()
		setMenuState("Main")
		randomGameB.currentColor = randomGameB.color
	end
	
	gameDirInput = tf.new("Game Directory", 7, (screen.y / 5) + 32, screen.x - 14, 60)
	gameDirInput.text = [[C:\Program Files (x86)\Steam\steamapps\common]]
	
	scanDirBut = sb.new("Scan", 7, gameDirInput.y + gameDirInput.height + 3, 50, 20)
	scanDirBut.interactable = false
	function scanDirBut.onClick()
		setgamedir(gameDirInput.text)
	end
	
	editGroups = sb.new("Edit groups", 7, screen.y - 45, 100, 25)
	function editGroups.onRelease()
		setMenuState("Group")
		add2GroupB.interactable = editGroupDrop.index ~= 1
		groupList.interactable = editGroupDrop.index ~= 1
		removeFromGroupB.interactable = editGroupDrop.index ~= 1
		deleteGroup.interactable = editGroupDrop.index ~= 1
		renameGroup.interactable = editGroupDrop.index ~= 1
	end
	
	editGroupDrop = dp.new(groups, 7, 7, screen.x - 14, 20)
	editGroupDrop.choiceBckClr = {0.95,0.95,0.95}
	function editGroupDrop.onChoose(i)
		groupList.choices = games[groups[editGroupDrop.index]]
		
		add2GroupB.interactable = i ~= 1
		groupList.interactable = i ~= 1
		removeFromGroupB.interactable = i ~= 1
		deleteGroup.interactable = i ~= 1
		renameGroup.interactable = i ~= 1
	end
	
	allList = ls.new(games["All"], 7, 34, 125 - 7, 207)
	allList.interactable = false
	function allList.onSelect(i)
		groupList.index = 0
	end
	
	groupList = ls.new(games[groups[editGroupDrop.index]], 175, 34, 125 - 7, 207)
	groupList.interactable = false
	function groupList.onSelect(i)
		allList.index = 0
	end
	
	add2GroupB = sb.new(">", 125 + 3, 34 + 50 + 3, 44, 44)
	add2GroupB.interactable = false
	function add2GroupB.onClick()
		local contains = table.contains(games[groups[editGroupDrop.index]], games["All"][allList.index])
		if contains == false then
			table.insert(games[groups[editGroupDrop.index]], games["All"][allList.index])
		end
	end
	
	removeFromGroupB = sb.new("<", 125 + 3, 34 + 100 + 3, 44, 44)
	removeFromGroupB.interactable = false
	function removeFromGroupB.onClick()
		table.remove(games[groups[editGroupDrop.index]], groupList.index)
	end
	
	deleteGroup = sb.new("Delete", 7, screen.y - 27, 50, 20)
	deleteGroup.interactable = false
	function deleteGroup.onClick()
		local indexToDelete = editGroupDrop.index
		table.remove(groups, indexToDelete)
		editGroupDrop.index = indexToDelete - 1
		
		groupList.choices = games[groups[editGroupDrop.index]]
		
		add2GroupB.interactable = editGroupDrop.index ~= 1
		groupList.interactable = editGroupDrop.index ~= 1
		removeFromGroupB.interactable = editGroupDrop.index ~= 1
		deleteGroup.interactable = editGroupDrop.index ~= 1
		renameGroup.interactable = editGroupDrop.index ~= 1
	end
	
	newGroup = sb.new("New", 64, screen.y - 27, 50, 20)
	newGroup.interactable = false
	function newGroup.onClick()
		if #groups > 8 then return end
	
		local groupName = "New Group " .. #groups+1
		table.insert(groups, groupName)
		games[groupName] = {}
		
		editGroupDrop.index = #groups
		
		groupList.choices = games[groups[editGroupDrop.index]]
		
		add2GroupB.interactable = true
		groupList.interactable = true
		removeFromGroupB.interactable = true
		deleteGroup.interactable = true
		renameGroup.interactable = true
	end
	
	renameGroup = sb.new("Rename", 121, screen.y - 27, 55, 20)
	renameGroup.interactable = false
	function renameGroup.onClick()
		local contains = table.contains(games[groups[editGroupDrop.index]], groupName.text)
		if contains == false and groupName.text ~= "" then
			local t = games[groups[editGroupDrop.index]]
			games[groupName.text] = t
			games[groups[editGroupDrop.index]] = nil
			
			groups[editGroupDrop.index] = groupName.text
			groupName.text = ""
		end
	end
	
	groupName = tf.new("Group Name", 7, screen.y - 53, screen.x - 14, 20)
	groupName.centerY = true
	
	confirmGroupMenu = sb.new("Ok", screen.x - 52, screen.y - 27, 45, 20)
	confirmGroupMenu.interactable = false
	function confirmGroupMenu.onClick()
		settingsButton.onClick()
		saveGame()
		loadGame()
	end
	
	add2GroupB.interactable = editGroupDrop.index ~= 1
	groupList.interactable = editGroupDrop.index ~= 1
	removeFromGroupB.interactable = editGroupDrop.index ~= 1
	deleteGroup.interactable = editGroupDrop.index ~= 1
	renameGroup.interactable = editGroupDrop.index ~= 1
	
end

function love.draw()
	
	love.graphics.setColor{1,1,1}
	love.graphics.rectangle('fill', 0, 0, 1000, 1000)
	
	if menuState == "Main" then
		
		sb.draw(randomGameB)
		
	elseif menuState == "Reroll" then
		
		love.graphics.setColor{0,0,0}
		love.graphics.printf(selectedGame or "Your group contains no games!", 0, (screen.y / 5) * 2, screen.x, 'center')
		
		sb.draw(newRanGame)
		sb.draw(returnToMain)
		
	elseif menuState == "Settings" then
		
		love.graphics.setColor{0,0,0}
		love.graphics.print("Game Directory:", 7, (screen.y / 5) + 15)
		tf.draw(gameDirInput)
		sb.draw(scanDirBut)
		
		love.graphics.setColor{0,0,0}
		love.graphics.print("Game Groups:", 7, gameDirInput.y + gameDirInput.height + 35)
		
		local grps = {}
		for k,v in ipairs(groups) do
			if k > 1 then v = ', ' .. v	end
			table.insert(grps, v)
		end
		
		love.graphics.setColor{0.5,0.5,0.5}
		love.graphics.printf(grps, 7, gameDirInput.y + gameDirInput.height + 50, screen.x - 14)
		
		sb.draw(editGroups)
		
	elseif menuState == "Group" then
		
		sb.draw(add2GroupB)
		sb.draw(removeFromGroupB)
		
		ls.draw(allList)
		ls.draw(groupList)
		
		sb.draw(deleteGroup)
		sb.draw(newGroup)
		sb.draw(renameGroup)
		sb.draw(confirmGroupMenu)
		
		tf.draw(groupName)
		
		dp.draw(editGroupDrop)
		
	end
	
	if menuState ~= "Group" then
	
		love.graphics.setColor{0,0,0}
		love.graphics.line(0, (screen.y / 5) + 7, screen.x, (screen.y / 5) + 7)
	
		dp.draw(groupDrop)
		sb.draw(settingsButton)
		
		love.graphics.printf("Games: " .. #games["All"] .. " | Game Groups: " .. #groups .. " | Rolls: " .. rolls, 7, screen.y - 14, screen.x, 'left')
	
	end
	
end

function love.update(dt)
	tf.update(dt)
end

function love.keypressed(k)
	tf.keypressed(k)
end

function love.textinput(t)
	tf.textinput(t)
end

function love.mousepressed(x, y, button)

	local notHit, select = dp.mousepressed(x, y, button)
	if select == true then
		return
	end
	
	ls.mousepressed(x, y, button)
	tf.mousepressed(x, y, button)
	sb.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
	sb.mousereleased(x, y, button)
end

function love.wheelmoved(x, y)
	ls.wheelmoved(x,y)
end

function getRandomGame(grp)
	rolls = rolls + 1
	
	-- Get a different game every time
	local gme = ""
	repeat
		gme = grp[love.math.random(#grp)]
	until(gme ~= selectedGame)
	return gme
end

function saveGame()
	local data = {groups}
	for i=1,#groups do
		if #games[groups[i]] == 0 then
			games[groups[i]][1] = "None"
		end
		data[i+1] = games[groups[i]]
	end
	saveData.save(data, "saveFile.sav")
end

function loadGame()
	local data = saveData.load("saveFile.sav")
	groups = data[1]
	for i=1,#groups do
		if data[i+1][1] ~= "None" then
			games[groups[i]] = data[i+1]
		else
			games[groups[i]] = {}
		end
	end
end

function setMenuState(menu)
	
	-- Menu, Reroll, Settings, Group
	
	menuState = menu
	
	groupDrop.enabled = menu ~= "Group"
	settingsButton.interactable = menu ~= "Group"
	
	randomGameB.interactable = menu == "Main"
	
	newRanGame.interactable = menu == "Reroll"
	returnToMain.interactable = menu == "Reroll"
	
	scanDirBut.interactable = menu == "Settings"
	
	allList.interactable = menu == "Group"
	groupList.interactable = menu == "Group"
	add2GroupB.interactable = menu == "Group"
	removeFromGroupB.interactable = menu == "Group"
	deleteGroup.interactable = menu == "Group"
	newGroup.interactable = menu == "Group"
	renameGroup.interactable = menu == "Group"
	confirmGroupMenu.interactable = menu == "Group"
	
end

function setgamedir(dir)
	local gameDir_exist = isdir(dir)
	print("Does the game directory exist? " .. (gameDir_exist and 'true' or 'false') .. "\n")
	
	if gameDir_exist then
		gameDir = dir
		local temp = {}
		local g = scandir(gameDir)
		for k,v in ipairs(g) do
			local s = alias(v)
			if s ~= true then
				if s == false then
					s = string.gsub(v, "_", " ")
				end
				table.insert(temp, s)
			end
		end
		return temp
	end
	
	return { "None" }
end

--- Check if a file or directory exists in this path
function exists(file)
   local ok, err, code = os.rename(file, file)
   if not ok then
      if code == 13 then
         -- Permission denied, but it exists
         return true
      end
   end
   return ok, err
end

--- Check if a directory exists in this path
function isdir(path)
   -- "/" works on both Unix and Windows
   return exists(path.."/")
end

function scandir(directory)
    local i, t, popen = 0, {}, io.popen
    local pfile = popen('dir "'..directory..'" /b /ad')
    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename
    end
    pfile:close()
    return t
end

function math.lerp(v0, v1, t)
  return (1 - t) * v0 + t * v1
end

function table.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end