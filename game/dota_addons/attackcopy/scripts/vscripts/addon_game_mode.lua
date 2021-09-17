require("AOHGameMode")
require( "lib/animations")



function do_precache(elements, handle)
	for _, e in ipairs(elements) do
		handle(e)
	end
end


function Precache(context)
	local items = {
		"item_bag_of_gold",
		"item_tombstone",
	}

	local models = {

	}

	local particles = {

	}

	local soundevents = {	
		"soundevents/game_sounds.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_abyssal_underlord.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_antimage.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_bane.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_elder_titan.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_alchemist.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_earthshaker.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_invoker.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_huskar.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_legion_commander.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_leshrac.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_lina.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_lone_druid.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_mars.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_phoenix.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_silencer.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_stormspirit.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_techies.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_terrorblade.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_void_spirit.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_oracle.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_zuus.vsndevts",
		"soundevents/game_sounds_custom.vsndevts"
	}

	local units = { 

	}



	do_precache(items, 
		function(e) 
			PrecacheItemByNameSync(e, context) 
		end
	)

	do_precache(models, 
		function(e) 
			PrecacheModel(e, context)
		end
	)

	do_precache(particles, 
		function(e) 
			PrecacheResource("particle", e, context)
		end
	)

	do_precache(soundevents, 
		function(e) 
			PrecacheResource("soundfile", e, context)
		end
	)

	do_precache(units, 
		function(e) 
			PrecacheUnitByNameSync(e, context)
		end
	)
end


function Activate()
	GameRules.GameMode = AOHGameMode()
	GameRules.GameMode:InitGameMode()
end
