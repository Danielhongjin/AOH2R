
local function do_effect(hero1, hero2)
	local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_vengeful/vengeful_nether_swap.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero1)
	ParticleManager:SetParticleControlEnt(fx, 1, hero2, PATTACH_ABSORIGIN_FOLLOW, nil, hero2:GetOrigin(), false)
    ParticleManager:ReleaseParticleIndex(fx)
end



function cast_lone_druid_custom_bear_style(keys)
    local caster = keys.caster
    local ability = keys.ability

    local bear_list = Entities:FindAllByClassname("npc_dota_lone_druid_bear")

    if #bear_list < 1 then
        caster:Interrupt()
        caster:InterruptChannel()
        ability:RefundManaCost()
        return
    end

    local bear = bear_list[1]

    if not bear or not bear:IsAlive() then
        caster:Interrupt()
        caster:InterruptChannel()
        ability:RefundManaCost()
        return
    end

    -- Health
    local caster_hp_pct = caster:GetHealthPercent() + 1
    local bear_hp_pct = bear:GetHealthPercent() + 1
	
    bear:SetHealth(bear:GetMaxHealth() * caster_hp_pct * 0.01)
    caster:SetHealth(caster:GetMaxHealth() * bear_hp_pct * 0.01)

    -- Mana
    local caster_mp_pct = caster:GetManaPercent()
    local bear_mp_pct = bear:GetManaPercent()

    bear:SetMana(bear:GetMaxMana() * caster_mp_pct * 0.01)
    caster:SetMana(caster:GetMaxMana() * bear_mp_pct * 0.01)

    do_effect(caster, bear)
    do_effect(bear, caster)
	if caster:GetHealth() < 1 then
		caster:ForceKill(true)
	end
end

