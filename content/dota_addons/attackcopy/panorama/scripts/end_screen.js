

var GAME_RESULT = {};
var _ = GameUI.CustomUIConfig()._;


function FinishGame() {
	Game.FinishGame();
}



/**
 * Creates Panel snippet and sets all player-releated information
 *
 * @param {Number} playerId Player ID
 * @param {Panel} rootPanel Panel that will be parent for that player
 */
function Snippet_Player(playerId, rootPanel, index) {
	var panel = $.CreatePanel("Panel", rootPanel, "");
	panel.BLoadLayoutSnippet("Player");
    panel.SetHasClass("IsLocalPlayer", playerId === Game.GetLocalPlayerID());

	var playerData = GAME_RESULT.players[playerId];
	var playerInfo = Game.GetPlayerInfo(playerId);
	panel.FindChildTraverse("PlayerAvatar").steamid = playerInfo.player_steamid;
	panel.FindChildTraverse("PlayerNameScoreboard").steamid = playerInfo.player_steamid;
	panel.index = index; // For backwards compatibility
	panel.style.animationDelay = index * 0.3 + "s";
	$.Schedule(index * 0.3, function() {
		try {
			panel.AddClass("AnimationEnd");
		} catch(e) {};
	});
    $.Msg(playerId);
	panel.FindChildTraverse("HeroIcon").SetImage('file://{images}/heroes/' + playerData.heroName + '.png');
	panel.SetDialogVariableInt("hero_level", Players.GetLevel(playerId));
	panel.SetDialogVariable("hero_name", $.Localize(playerData.heroName));

	panel.SetDialogVariableInt("deaths", Players.GetDeaths(playerId));
	panel.SetDialogVariableInt("saves", playerData.saves);
	panel.SetDialogVariableInt("goldBags", playerData.goldBags);

	panel.SetDialogVariable("damageTaken", playerData.damageTaken);
	panel.SetDialogVariable("bossDamage", playerData.bossDamage);
	panel.SetDialogVariable("heroHealing", playerData.heroHealing);

	panel.SetDialogVariableInt("strength", playerData.str);
	panel.SetDialogVariableInt("agility", playerData.agi);
    panel.SetDialogVariableInt("intellect", playerData.int);
	for (var i = 0; i < 7; i++) {
		var item = playerData.items[i];
		var itemPanel = $.CreatePanel("DOTAItemImage", panel.FindChildTraverse(i >= 6 ? "NeutralItemContainer" : "ItemsContainer"), "");
		if (item) {
			itemPanel.itemname = item;
        }
    }
    for (var i = 7; i < 10; i++) {
        var item = playerData.items[i];
        $.Msg(item);
        var itemPanel = $.CreatePanel("DOTAItemImage", panel.FindChildTraverse("BackpackItemsContainer"), "");
        if (item) {
            itemPanel.itemname = item;
        }
    }
}

function Snippet_Award(playerId, rootPanel, index, text) {
    var panel = $.CreatePanel("Panel", rootPanel, "");
    panel.BLoadLayoutSnippet("Award");
    panel.SetHasClass("IsLocalPlayer", playerId === Game.GetLocalPlayerID());

    var playerData = GAME_RESULT.players[playerId];
    var playerInfo = Game.GetPlayerInfo(playerId);
    panel.FindChildTraverse("AwardPlayerNameScoreboard").steamid = playerInfo.player_steamid;
    panel.FindChildTraverse("AwardPlayerAvatar").steamid = playerInfo.player_steamid;
    panel.index = index; // For backwards compatibility
    panel.style.animationDelay = index * 0.3 + "s";
    $.Schedule(index * 0.3, function () {
        try {
            panel.AddClass("AnimationEnd");
        } catch (e) { };
    });
    $.Msg(index);
    panel.SetDialogVariable("award_label", $.Localize(text));
    switch (index) {
        case 1: {
            panel.SetDialogVariable("award_stat", playerData.bossDamage);
            break;
        }
        case 2: {
            panel.SetDialogVariable("award_stat", playerData.damageTaken);
            break;
        }
        case 3: {
            panel.SetDialogVariable("award_stat", playerData.heroHealing);
            break;
        }
        case 4: {
            panel.SetDialogVariable("award_stat", playerData.highestDPS);
            break;
        }
    }
    

    panel.FindChildTraverse("AwardHeroIcon").SetImage('file://{images}/heroes/' + playerData.heroName + '.png');
    panel.SetDialogVariable("hero_name", $.Localize(playerData.heroName));

}

/**
 * Creates Team snippet and all in-team information
 *
 * @param {Number} team Team Index
 */
function Snippet_Team(team) {
	var panel = $.CreatePanel("Panel", $("#TeamsContainer"), "");
	panel.BLoadLayoutSnippet("Team");
	panel.SetHasClass("IsRight", true);
	panel.SetHasClass("IsWinner", GAME_RESULT.isWinner);

	var ids = Game.GetPlayerIDsOnTeam(team)

	for(var i = 0; i < ids.length; i++) { 
		Snippet_Player(ids[i], panel, i + 1);
    }

    var panel = $.CreatePanel("Panel", $("#AwardContainer"), "");
    panel.BLoadLayoutSnippet("Achievements");
    Snippet_Award(GAME_RESULT.highestDamage, panel, 1, "damage_dealt_award")
    Snippet_Award(GAME_RESULT.highestDamageTaken, panel, 2, "damage_taken_award")
    Snippet_Award(GAME_RESULT.highestHealing, panel, 3, "healing_award")
    Snippet_Award(GAME_RESULT.highestDPS, panel, 4, "dps_award")
}



function OnGameResult(table, key, gameResult) {
	if (!gameResult || key !== "game_info") {
		FinishGame();
		return;
	}


	$("#LoadingPanel").visible = false;
    $("#EndScreenWindow").visible = true;
    $("#InfoContainer").visible = true;
    $("#TeamsContainer").RemoveAndDeleteChildren();
    $("#AwardContainer").RemoveAndDeleteChildren();
	
	GAME_RESULT = gameResult;

	Snippet_Team(2);


	var result_label = $("#EndScreenVictory")
	
	if (GAME_RESULT.isWinner) {
		result_label.text = $.Localize("end_screen_victory");
		result_label.style.color = "#008000";
	} else {
		result_label.text = $.Localize("end_screen_defeat");
		result_label.style.color = "#FF0000";
    }

    var duration_label = $("#EndScreenDurationLabel")
    duration_label.text = GAME_RESULT.duration + " " + $.Localize("seconds");
}



(function() {
	GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ENDGAME, false);
	GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ENDGAME_CHAT, false);
	find_hud_element("GameEndContainer").visible = false;

	$.GetContextPanel().RemoveClass("FadeOut");
	$("#LoadingPanel").visible = true;
	$("#EndScreenWindow").visible = false;

	CustomNetTables.SubscribeNetTableListener("end_game_scoreboard", OnGameResult);
	OnGameResult(null, "game_info", CustomNetTables.GetTableValue("end_game_scoreboard", "game_info"));
})();
