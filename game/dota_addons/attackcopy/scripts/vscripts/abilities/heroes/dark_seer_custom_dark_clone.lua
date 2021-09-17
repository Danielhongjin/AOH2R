require("lib/my")


LinkLuaModifier("modifier_dark_seer_custom_dark_clone", "abilities/heroes/dark_seer_custom_dark_clone.lua", LUA_MODIFIER_MOTION_NONE)




function cast_dark_clone(keys)
	local ability = keys.ability
    local caster = keys.caster
    local target = keys.target
	local outgoing = keys.outgoing - 100
	local incoming = keys.incoming - 100
	local duration = keys.duration
    local n_clones = ability:GetSpecialValueFor("n_clones")
	local ion_shell = caster:FindAbilityByName("dark_seer_custom_ion_shell")
	local surge = caster:FindAbilityByName("dark_seer_surge")
    local talent = caster:FindAbilityByName("dark_seer_custom_bonus_unique_1")

    if talent and talent:GetLevel() > 0 then
        n_clones = n_clones + talent:GetSpecialValueFor("value")
    end

	local illusions = CreateIllusions(caster, target,{duration = duration, outgoing_damage = outgoing, incoming_damage = incoming}, n_clones, 50, true, true )
	for _,illusion in pairs(illusions) do
		caster:SetCursorCastTarget(illusion)
		ion_shell:OnSpellStart()
		surge:OnSpellStart()
	end
end


