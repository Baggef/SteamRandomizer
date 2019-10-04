-- True: Game is not playable
-- False: Game does not have alias

function alias(name)

	if name == 'MGS_TPP' then return 'Metal Gear Solid: The Phantom Pain' end
	
	if name == 'dota 2 beta' then return true end
	if name == 'AreYouReadyForValveIndex' then return true end
	if name == 'Source SDK Base 2013 Multiplayer' then return true end
	if name == 'Steamworks Shared' then return true end
	
	return false
	
end