function metamorphosis_threshold(keys)
	local caster = keys.caster
	local ability = keys.ability
	local threshold = ability:GetLevelSpecialValueFor("threshold", (ability:GetLevel() - 1)) * 0.01
	local health = caster:GetHealth() / caster:GetMaxHealth()
	if health < threshold and ability:GetCooldownTimeRemaining() == 0 then
		ability:StartCooldown(ability:GetCooldown(ability:GetLevel()))
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_metamorphosis", nil)
		EmitSoundOn("Hero_Terrorblade.Metamorphosis", caster)
	end
end


function ModelSwapStart( keys )
	local caster = keys.caster
	local model = keys.model
	local projectile_model = keys.projectile_model
	StartAnimation(caster, {duration = 0.35, activity = ACT_DOTA_CAST_ABILITY_3})
	-- Saves the original model and attack capability
	if caster.caster_model == nil then 
		caster.caster_model = caster:GetModelName()
	end
	caster.caster_attack = caster:GetAttackCapability()
	-- Sets the new model and projectile
	caster:SetOriginalModel(model)
	caster:SetModelScale(caster:GetModelScale() - 0.1)
	caster:SetRangedProjectileName(projectile_model)

	-- Sets the new attack type
	caster:SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK)
end

function ModelSwapEnd( keys )
	local caster = keys.caster

	caster:SetModel(caster.caster_model)
	caster:SetOriginalModel(caster.caster_model)
	caster:SetAttackCapability(caster.caster_attack)
end

function HideWearables( event )
	local hero = event.caster
	local ability = event.ability
	
	hero.hiddenWearables = {} -- Keep every wearable handle in a table to show them later
	Timers:CreateTimer(0.35, function()
			local model = hero:FirstMoveChild()
			while model ~= nil do
				if model:GetClassname() == "dota_item_wearable" then
					model:AddEffects(EF_NODRAW) -- Set model hidden
					table.insert(hero.hiddenWearables, model)
				end
				model = model:NextMovePeer()
			end
		end
	)
end

function ShowWearables( event )
	local hero = event.caster

	for i,v in pairs(hero.hiddenWearables) do
		v:RemoveEffects(EF_NODRAW)
	end
end