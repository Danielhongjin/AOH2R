var players = {}; 
var panel;
var length = -1;
function AddDebugPlayer(color)
{
	panel = $.CreatePanel('Panel', $('#Players'), '');
	panel.BLoadLayoutSnippet("Player");
	panel.FindChildTraverse('PlayerNameSignal').text = "assbutt";
	panel.FindChildTraverse('PlayerDamageDealth').text = "666"
	panel.FindChildTraverse('PlayerDamageTaken').text = "666";
	$.Msg("hello")
}  
function InitPlayer(name)
{
	panel = $.CreatePanel('Panel', $('#Players'), '');
	panel.BLoadLayoutSnippet("Player");
	
	panel.FindChildTraverse('PlayerHeroSignal').text = $.Localize(name.name);
	panel.FindChildTraverse('PlayerDamageDealt').text = "0"
	panel.FindChildTraverse('PlayerDamageTaken').text = "0";
	panel.FindChildTraverse('PlayerDamageHealed').text = "0";
	panel.FindChildTraverse('PlayerDPS').text = "0";
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


function SetDamageDealt(damage)
{
    players[damage.id].FindChildTraverse('PlayerDamageDealt').text = damage.damage;
    players[damage.id].FindChildTraverse('PlayerDPS').text = damage.dps;
    players[damage.id].FindChildTraverse('PlayerDamageHealed').text = damage.healing;
    players[damage.id].FindChildTraverse('PlayerDamageTaken').text = damage.damage_taken;
}	
function SetDamageTypes(damage)
{
	var total = damage.physical + damage.magical + damage.pure;
	var physpercent =  Math.floor(damage.physical / total * 100)
	var magpercent =  Math.floor(damage.magical / total * 100)
	var purepercent =  Math.floor(damage.pure / total * 100)
	if (physpercent + magpercent + purepercent < 100)
	{
		if (physpercent > magpercent && physpercent > purepercent)
			physpercent = 100 - magpercent - purepercent;
		else if (magpercent > purepercent)
			magpercent = 100 - physpercent - purepercent;
		else purepercent = 100 - physpercent - magpercent;
	}
	players[damage.id].FindChildTraverse('Playerphysdamagepercent').text = physpercent + "%";
	players[damage.id].FindChildTraverse('Playermagdamagepercent').text = magpercent + "%";
	players[damage.id].FindChildTraverse('Playerpuredamagepercent').text = purepercent + "%";
	
	players[damage.id].FindChildTraverse("PlayerPhysical").style.width = physpercent + "%";
	players[damage.id].FindChildTraverse("PlayerMagical").style.width = magpercent  + "%";
	players[damage.id].FindChildTraverse("PlayerPure").style.width = purepercent + "%";
}	

function debug()
{
	GameEvents.Subscribe("game_begin", InitPlayer);
	GameEvents.Subscribe("damage_update", SetDamageDealt);
	GameEvents.Subscribe("damage_type_update", SetDamageTypes);
	GameEvents.Subscribe("delete", Delete);
	$.Msg("Debug");
}

debug();