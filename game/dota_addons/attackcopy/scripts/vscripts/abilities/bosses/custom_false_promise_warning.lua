require("lib/timers")
require("lib/timers")
require("lib/my")
LinkLuaModifier("modifier_anim", "abilities/other/generic.lua", LUA_MODIFIER_MOTION_NONE)

custom_false_promise_warning = class({})


function custom_false_promise_warning:OnSpellStart()
	local caster = self:GetCaster()
	local health = caster:GetHealthPercent()
	
	if caster:GetHealthPercent() < 40 then
		self:StartCooldown(45)
		local promise = caster:FindAbilityByName("custom_false_promise")
		local heroes = ai_all_heroes()
		for _, hero in ipairs(heroes) do
			caster:SetCursorCastTarget(hero)
			promise:OnSpellStart()
		end
		if #heroes > 1 then
			caster:AddNewModifier(caster, self, "modifier_false_promise_warning", {duration = 10})
		end
	end
end



LinkLuaModifier("modifier_false_promise_warning", "abilities/bosses/custom_false_promise_warning.lua", LUA_MODIFIER_MOTION_NONE)

modifier_false_promise_warning = class({})


function modifier_false_promise_warning:IsHidden()
    return false
end

function modifier_false_promise_warning:GetEffectName()
	return "particles/units/heroes/hero_doom_bringer/doom_infernal_blade_debuff.vpcf"
end

function modifier_false_promise_warning:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

if IsServer() then
    function modifier_false_promise_warning:OnCreated()
        self.parent = self:GetParent()
		self.ability = self:GetAbility()
		self.flame = self.parent:FindAbilityByName("custom_purifying_flames")
		self.radius = self.ability:GetSpecialValueFor("radius")
        self:StartIntervalThink(0.5)
    end


    function modifier_false_promise_warning:OnIntervalThink()
        local units = FindUnitsInRadius(self.parent:GetTeam(), self.parent:GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, 1, false)
		for _, unit in ipairs(units) do
			self.parent:SetCursorCastTarget(unit)
			self.flame:OnSpellStart()
			StartAnimation(self.parent, {duration = 1, activity = ACT_DOTA_CAST_ABILITY_1, rate = 1})
			self.parent:AddNewModifier(self.parent, self.ability, "modifier_anim", {duration = 1.1})
			break
		end
    end
end

