var panel;
var playerID;
function AddDebugDifficulty(color)
{
	panel = $.CreatePanel('Panel', $('#Difficulties'), '');
	panel.BLoadLayoutSnippet("Difficulty");
	$.Msg("hello")
}  
function InitDifficulty(name)
{   
    $.Msg("hello initDifficulty");
    playerID = name.id;
    panel = $.CreatePanel('Panel', $('#Difficulties'), '');
    panel.BLoadLayoutSnippet("Difficulty");
    $('#Normal').style.backgroundColor = '#e03e2e';
    $('#Easy').SetPanelEvent('onactivate', () => {
        GameEvents.SendCustomGameEventToServer('difficulty_clicked', {
            id: playerID,
            choice: 0,
        });
        $('#Easy').style.backgroundColor = '#e03e2e';
        $('#Normal').style.backgroundColor = '#000000';
        $('#Hard').style.backgroundColor = '#000000';
    });
    $('#Normal').SetPanelEvent('onactivate', () => {
        GameEvents.SendCustomGameEventToServer('difficulty_clicked', {
            id: playerID,
            choice: 1,
        });
        $('#Easy').style.backgroundColor = '#000000';
        $('#Normal').style.backgroundColor = '#e03e2e';
        $('#Hard').style.backgroundColor = '#000000';
    });
    $('#Hard').SetPanelEvent('onactivate', () => {
        GameEvents.SendCustomGameEventToServer('difficulty_clicked', {
            id: playerID,
            choice: 2,
        });
        $('#Easy').style.backgroundColor = '#000000';
        $('#Normal').style.backgroundColor = '#000000';
        $('#Hard').style.backgroundColor = '#e03e2e';
    });
    $('#DifficultyTextLabel').text = $.Localize("difficulty_text_label");
    $('#EasyLabel').text = $.Localize("easy_label");
    $('#NormalLabel').text = $.Localize("normal_label");
    $('#HardLabel').text = $.Localize("hard_label");
    $('#EasyDescription').text = $.Localize("easy_description");
    $('#MediumDescription').text = $.Localize("medium_description");
    $('#HardDescription').text = $.Localize("hard_description");
}
function Delete()
{
    $('#Difficulties').RemoveAndDeleteChildren();
}
function AddName(data)
{
	switch (data.id) {
		case 0:
			$('#playerLabel0').text = $.Localize(data.name);
			$('#playerLabelChoice0').text = 'Normal';
		break;
		case 1:
			$('#playerLabel1').text = $.Localize(data.name);
			$('#playerLabelChoice1').text = 'Normal';
		break;
		case 2:
			$('#playerLabel2').text = $.Localize(data.name);
			$('#playerLabelChoice2').text = 'Normal';
		break;
		case 3:
			$('#playerLabel3').text = $.Localize(data.name);
			$('#playerLabelChoice3').text = 'Normal';
		break;
		case 4:
			$('#playerLabel4').text = $.Localize(data.name);
			$('#playerLabelChoice4').text = 'Normal';
		break;
	}
}
function GetDifficulty(id)
{
	switch (id) {
		case 0:
			return 'Easy';
		break;
		case 1:
			return 'Normal';
		break;
		case 2:
			return 'Hard';
		break;
	}
	return 'N/A';
}
function Update(data)
{
	switch (data.id) {
		case 0:
			$('#playerLabelChoice0').text = GetDifficulty(data.difficulty);
		break;
		case 1:
			$('#playerLabelChoice1').text = GetDifficulty(data.difficulty);
		break;
		case 2:
			$('#playerLabelChoice2').text = GetDifficulty(data.difficulty);
		break;
		case 3:
			$('#playerLabelChoice3').text = GetDifficulty(data.difficulty);
		break;
		case 4:
			$('#playerLabelChoice4').text = GetDifficulty(data.difficulty);
		break;
	}
}
function debug()
{
    GameEvents.Subscribe("vote_begin", InitDifficulty);
    GameEvents.Subscribe("vote_end", Delete);
	GameEvents.Subscribe("vote_name", AddName);
	GameEvents.Subscribe("vote_update", Update);
	$.Msg("Debug");
}

debug();