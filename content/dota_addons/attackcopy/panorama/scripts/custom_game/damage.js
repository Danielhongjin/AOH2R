var players = {}; 
Object.size = function(obj) {
    var size = 0, key;
    for (key in obj) {
        if (obj.hasOwnProperty(key)) size++;
    }
    return size;
};
function AddDebugPlayer(color)
{
	var panel = $.CreatePanel('Panel', $('#Players'), '');
	panel.BLoadLayoutSnippet("Player");
	panel.FindChildTraverse('PlayerNameSignal').text = "assbutt";
	panel.FindChildTraverse('PlayerDamageDealth').text = "666"
	panel.FindChildTraverse('PlayerDamageTaken').text = "666";
	$.Msg("hello")
}  
function InitDamagePanels(data)
{
	for (const [key, index] of Object.entries(data.players)) {
		var panel = $.CreatePanel('Panel', $('#Players'), '');
		panel.BLoadLayoutSnippet("Player");
		panel.FindChildTraverse('PlayerHeroSignal').text = $.Localize(Players.GetPlayerSelectedHero(index)).toUpperCase();
		panel.FindChildTraverse('PlayerDamageDealt').text = "0"
		panel.FindChildTraverse('PlayerDamageTaken').text = "0";
		panel.FindChildTraverse('PlayerDamageHealed').text = "0";
		panel.FindChildTraverse('PlayerDPS').text = "0";
		players[index] = panel;
	}
	
	
	
}
function Delete()
{
	$("#Players").RemoveAndDeleteChildren();
}

function formatted_number(number) {
    var as_string = Math.floor(number).toString()
    if (number < 1000) {
		return as_string
	}
	
    var len = as_string.length
	if (number < 1000000) {
		var split_point = len - 3
		return as_string.substring(0, split_point) + "." + as_string.substring(split_point, split_point + 1) + "K"
	} else {
		var split_point = len - 6
		return as_string.substring(0, split_point) + "." + as_string.substring(split_point, split_point + 2) + "M"
	}
}

function OnDamageStatsChanged(table_name, paramkey, data)
{
	var key = parseInt(paramkey)
	players[key].FindChildTraverse('PlayerDamageDealt').text = formatted_number(data.damage);
    players[key].FindChildTraverse('PlayerDPS').text = formatted_number(data.dps);
    players[key].FindChildTraverse('PlayerDamageHealed').text = formatted_number(data.healing);
    players[key].FindChildTraverse('PlayerDamageTaken').text = formatted_number(data.damage_taken);
	var total = data.physical + data.magical + data.pure;
	var physpercent =  Math.floor(data.physical / total * 100)
	var magpercent =  Math.floor(data.magical / total * 100)
	var purepercent =  Math.floor(data.pure / total * 100)
	if (physpercent + magpercent + purepercent < 100)
	{
		if (physpercent > magpercent && physpercent > purepercent)
			physpercent = 100 - magpercent - purepercent;
		else if (magpercent > purepercent)
			magpercent = 100 - physpercent - purepercent;
		else purepercent = 100 - physpercent - magpercent;
	}
	players[key].FindChildTraverse('Playerphysdamagepercent').text = physpercent + "%";
	players[key].FindChildTraverse('Playermagdamagepercent').text = magpercent + "%";
	players[key].FindChildTraverse('Playerpuredamagepercent').text = purepercent + "%";
	
	players[key].FindChildTraverse("PlayerPhysical").style.width = physpercent + "%";
	players[key].FindChildTraverse("PlayerMagical").style.width = magpercent  + "%";
	players[key].FindChildTraverse("PlayerPure").style.width = purepercent + "%";
}

function debug()
{
	CustomNetTables.SubscribeNetTableListener("damage_stats", OnDamageStatsChanged);
	GameEvents.Subscribe("dps_init", InitDamagePanels);
	GameEvents.Subscribe("delete", Delete);
	$.Msg("Debug");
}

debug();