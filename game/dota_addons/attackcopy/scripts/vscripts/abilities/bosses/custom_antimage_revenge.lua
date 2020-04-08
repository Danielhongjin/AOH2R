require("lib/my")
require("lib/timers")
LinkLuaModifier( "modifier_dummy", "modifiers/modifier_dummy.lua", LUA_MODIFIER_MOTION_NONE )


custom_antimage_revenge = class({})

function custom_antimage_revenge:OnSpellStart()
	local caster = self:GetCaster()
	local delay = self:GetSpecialValueFor("delay")
	find_item(caster, "item_black_king_bar_boss"):CastAbility()
	find_item(caster, "item_black_king_bar_boss"):EndCooldown()
	local particle = ParticleManager:CreateParticle("particles/econ/items/lich/frozen_chains_ti6/lich_frozenchains_frostnova_g2.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster) 
	EmitSoundOn("Hero_Antimage.ManaVoidCast", caster)
	Timers:CreateTimer(
		delay, 
		function()
			EmitSoundOn("Hero_ElderTitan.EarthSplitter.Destroy", caster)
			caster:CastAbilityOnPosition(Entities:FindByName(nil, "dota_goodguys_fort"):GetAbsOrigin(), caster:FindAbilityByName("custom_blink"), -1)
			caster:AddNewModifier(caster,self, "modifier_custom_antimage_revenge", {duration = self:GetSpecialValueFor("duration")})
		end
	)
end


LinkLuaModifier("modifier_custom_antimage_revenge", "abilities/bosses/custom_antimage_revenge.lua", LUA_MODIFIER_MOTION_NONE)

modifier_custom_antimage_revenge = class({})

function modifier_custom_antimage_revenge:IsHidden()
    return true
end
if IsServer() then
    function modifier_custom_antimage_revenge:OnCreated()
        self.ability = self:GetAbility()
		self.caster = self:GetCaster()
        self.radius = self.ability:GetSpecialValueFor("radius")
		self.explosion_radius = self.ability:GetSpecialValueFor("explosion_radius")
        self.interval = self.ability:GetSpecialValueFor("interval")
		self.explosion_delay = self.ability:GetSpecialValueFor("explosion_delay")
		self.damage = self.ability:GetSpecialValueFor("damage")
        self:StartIntervalThink(self.interval)
    end


    function modifier_custom_antimage_revenge:OnIntervalThink()
		local casterLocation = self.caster:GetAbsOrigin()
		local castLocation = casterLocation + Vector(RandomInt(-self.radius, self.radius), RandomInt(-self.radius, self.radius), 0)
		self:StartIntervalThink(self.interval)
		local dummy = CreateUnitByName("npc_dummy_unit", castLocation, false, self.caster, self.caster, self.caster:GetTeamNumber())
		dummy:AddNewModifier(self.caster,self:GetAbility(), "modifier_dummy", {})
		local particle = "particles/econ/generic/generic_aoe_shockwave_1/generic_aoe_shockwave_1.vpcf"
		local particleIndex = ParticleManager:CreateParticleForTeam( particle, PATTACH_CUSTOMORIGIN, nil,DOTA_TEAM_GOODGUYS )
		ParticleManager:SetParticleControl(particleIndex, 0, castLocation )
		ParticleManager:SetParticleControl(particleIndex, 1, Vector(350, 0,0))
		ParticleManager:SetParticleControl(particleIndex, 2, Vector(6, 0,1))
		ParticleManager:SetParticleControl(particleIndex, 3, Vector(200, 0,0))
		Timers:CreateTimer(self.explosion_delay, function()
				local particleEndIndex = ParticleManager:CreateParticleForTeam("particles/units/heroes/hero_antimage/antimage_manavoid.vpcf", PATTACH_CUSTOMORIGIN, nil,DOTA_TEAM_GOODGUYS)
				ParticleManager:SetParticleControl(particleEndIndex, 0, castLocation + Vector(0,0,75))
				local units = FindUnitsInRadius(self.caster:GetTeam(), dummy:GetAbsOrigin(), nil, self.explosion_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, 0, false)
				local damage_table = {}
				damage_table.attacker = self.caster
				damage_table.damage_type = DAMAGE_TYPE_MAGICAL
				damage_table.ability = self.ability
				for _, u in ipairs(units) do
					damage_table.victim = u
					damage_table.damage = self.damage
					ApplyDamage(damage_table)
					EmitSoundOn("Hero_Nevermore.Shadowraze.Arcana", u)
				end
				ParticleManager:DestroyParticle(particleIndex, true)
				EmitSoundOn("Hero_Antimage.ManaVoid", dummy)
				
				dummy:ForceKill(false)
			end
		)
    end

end
