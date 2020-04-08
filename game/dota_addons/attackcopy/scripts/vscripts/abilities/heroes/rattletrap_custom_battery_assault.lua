require("lib/my")
LinkLuaModifier("modifier_rattletrap_custom_battery_assault", "abilities/heroes/rattletrap_custom_battery_assault.lua", LUA_MODIFIER_MOTION_NONE)
rattletrap_custom_battery_assault = class({})


function rattletrap_custom_battery_assault:OnSpellStart()
    self.caster = self:GetCaster()
    self.caster:EmitSound("Hero_Rattletrap.Battery_Assault")
	self.attack_as_damage = self:GetSpecialValueFor("attack_as_damage") * 0.01
	self.damage_bonus = 0
    self.caster:AddNewModifier(self.caster, self, "modifier_rattletrap_custom_battery_assault", {
        duration = self:GetSpecialValueFor("duration")
    })
	local talent = self:GetCaster():FindAbilityByName("special_bonus_unique_clockwerk_3")
	if talent and talent:GetLevel() > 0 then
		self.damage_bonus = talent:GetSpecialValueFor("value")
	end
end


if IsServer() then
    function rattletrap_custom_battery_assault:OnProjectileHit(target)
        if target and self.caster and not self.caster:IsIllusion() then
			local caster_base = (self.caster:GetBaseDamageMax() + self.caster:GetBaseDamageMin()) / 2
			local caster_base = (self.caster:GetAverageTrueAttackDamage(self.caster) - caster_base) / 2 + caster_base
            local damage = caster_base * self.attack_as_damage
            ApplyDamage({
                attacker = self.caster,
                victim = target,
                damage = damage + self.damage_bonus,
                damage_type = self:GetAbilityDamageType(),
                ability = self
            })
            target:EmitSound("Hero_Rattletrap.Battery_Assault_Impact")
        end
    end
end


modifier_rattletrap_custom_battery_assault = class({})


if IsServer() then
    function modifier_rattletrap_custom_battery_assault:OnDestroy()
        self:GetParent():StopSound("Hero_Rattletrap.Battery_Assault")
    end


    function modifier_rattletrap_custom_battery_assault:OnCreated()
        self.ability = self:GetAbility()
		self.parent = self:GetParent()
        self.radius = self.ability:GetSpecialValueFor("radius")
        self.interval = self.ability:GetSpecialValueFor("interval") + talent_value(self:GetCaster(), "rattletrap_custom_bonus_unique_1")
        self:StartIntervalThink(self.interval)
    end


    function modifier_rattletrap_custom_battery_assault:OnIntervalThink()

        local units = FindUnitsInRadius(self.parent:GetTeam(), self.parent:GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, 0, false)
        
        for _, unit in ipairs(units) do
            if unit then
                self:LaunchRocket(unit)
                break
            end
        end

        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_rattletrap/rattletrap_battery_assault.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
        ParticleManager:ReleaseParticleIndex(particle)
    end


    function modifier_rattletrap_custom_battery_assault:LaunchRocket(target)
        self.parent:EmitSound("Hero_Rattletrap.Battery_Assault_Launch")

        ProjectileManager:CreateTrackingProjectile({
            Ability = self.ability,
            Target = target,
            Source = self.parent,
            EffectName = "particles/units/heroes/hero_rattletrap/rattletrap_battery_shrapnel.vpcf",
            iMoveSpeed = 1000,
            iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
            bDodgeable = false,
            flExpireTime = GameRules:GetGameTime() + 5.0,
        })
    end
end
