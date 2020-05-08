var players = {}; 
var panel;
var length = -1;
function AddDebugDifficulty(color)
{
	panel = $.CreatePanel('Panel', $('#Difficulties'), '');
	panel.BLoadLayoutSnippet("Difficulty");
	$.Msg("hello")
}  
function InitDifficulty(name)
{
	panel = $.CreatePanel('Panel', $('#Difficulties'), '');
	panel.BLoadLayoutSnippet("Difficulty");
	players[name.id]= panel;
	length = length + 1;
}
function Delete()
{
	for (i = 0; i <= length; i++) {
	  players[i].RemoveAndDeleteChildren();
	  $.Msg(i)
	}
	length = -1;
}
function debug()
{
	GameEvents.Subscribe("game_begin", InitPlayer);
	GameEvents.Subscribe("damage_update", SetDamageDealt);
	GameEvents.Subscribe("damage_taken_update", SetDamageTaken);
	GameEvents.Subscribe("heal_update", SetDamageHealed);
	GameEvents.Subscribe("dps_update", SetDPS);
	GameEvents.Subscribe("damage_type_update", SetDamageTypes);
	GameEvents.Subscribe("delete", Delete);
	$.Msg("Debug");
}

debug();