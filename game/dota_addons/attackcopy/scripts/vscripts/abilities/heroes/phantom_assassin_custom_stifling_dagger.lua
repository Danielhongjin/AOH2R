require("lib/my")


phantom_assassin_custom_stifling_dagger = class({})

function phantom_assassin_custom_stifling_dagger:GetCooldown(iLevel)
	local caster = self:GetCaster()
	if caster:HasModifier("modifier_phantom_assassin_talent") then
		return 0
	end
	return self.BaseClass.GetCooldown(self, iLevel)
end
function phantom_assassin_custom_stifling_dagger:GetManaCost(iLevel)
	local caster = self:GetCaster()
	if caster:HasModifier("modifier_phantom_assassin_talent") then
		return 160
	end
	return self.BaseClass.GetManaCost(self, iLevel)
end
if IsServer() then
   

    function phantom_assassin_custom_stifling_dagger:OnSpellStart()	
		self.caster = self:GetCaster()
        self.duration = self:GetSpecialValueFor("duration")
        self.dagger_speed = self:GetSpecialValueFor("dagger_speed")
        self.dagger_offset = self:GetSpecialValueFor("dagger_offset")
		self.dagger_rate = self:GetSpecialValueFor("dagger_rate_base") * ((1/self.caster:GetAttacksPerSecond()) / self.caster:GetBaseAttackTime())
        self.dagger_range = self:GetSpecialValueFor("dagger_range") + self.caster:GetCastRangeBonus()
        self.target_location = self:GetCursorPosition()
        self.accumulated_time = 0.0
        self.daggers_thrown = 0
		
        local direction = self.caster:GetForwardVector() * self.dagger_range
        direction.z = 0.0
        direction = direction:Normalized()
        local talent = self.caster:FindAbilityByName("phantom_assassin_custom_bonus_unique_1")
		if talent and talent:GetLevel() > 0 then
			print("heyo")
			self.caster:AddNewModifier(self.caster, self, "modifier_phantom_assassin_talent", {})
		end
        self:ThrowDagger(direction)
    end


    function phantom_assassin_custom_stifling_dagger:OnChannelThink(flInterval)
        self.accumulated_time = self.accumulated_time + flInterval 
        if self.accumulated_time >= self.dagger_rate then
            self.accumulated_time = self.accumulated_time - self.dagger_rate

            local offset = RandomVector(self.dagger_offset)
            offset.z = 0.0
            
            local direction = self.caster:GetForwardVector() * self.dagger_range + offset
            direction.z = 0.0
            direction = direction:Normalized()

            self:ThrowDagger(direction)
        end
    end


    function phantom_assassin_custom_stifling_dagger:OnProjectileHit(target, pos)
        if target ~= nil and (not target:IsInvulnerable()) then
            self.caster:AddNewModifier(self.caster, self, "modifier_phantom_assassin_stiflingdagger_caster", {})
            self.caster:PerformAttack(target, false, true, true, true, true, false, true)
            self.caster:RemoveModifierByName("modifier_phantom_assassin_stiflingdagger_caster")
            target:AddNewModifier(self.caster, self, "modifier_phantom_assassin_stiflingdagger", { duration = self.duration })
            EmitSoundOn("Hero_PhantomAssassin.Dagger.Target", target)
        end
        return true
    end

    function phantom_assassin_custom_stifling_dagger:ThrowDagger(direction)
        ProjectileManager:CreateLinearProjectile({
            EffectName = "particles/custom/phantom_assassin_stifling_dagger_custom.vpcf",
            Ability = self,
            vSpawnOrigin = self.caster:GetOrigin() + Vector(0,0,100), 
            fStartRadius = 50.0,
            fEndRadius = 50.0,
            vVelocity = direction * self.dagger_speed,
            fDistance = self.dagger_range,
            Source = self.caster,
            iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        })
        EmitSoundOn("Hero_PhantomAssassin.Dagger.Cast", caster)
        self.daggers_thrown = self.daggers_thrown + 1
		self.caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1, 1.33)
    end
end

LinkLuaModifier( "modifier_phantom_assassin_talent", "abilities/heroes/phantom_assassin_custom_stifling_dagger.lua", LUA_MODIFIER_MOTION_NONE )
modifier_phantom_assassin_talent = class({})
function modifier_phantom_assassin_talent:IsHidden()
	return true
end

function modifier_phantom_assassin_talent:IsPurgable()
	return true
end