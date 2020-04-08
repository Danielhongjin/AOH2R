
LinkLuaModifier("modifier_gyrocopter_custom_rocket_barrage", "abilities/heroes/gyrocopter_custom_rocket_barrage.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_gyrocopter_custom_rocket_barrage_mana", "abilities/heroes/gyrocopter_custom_rocket_barrage.lua", LUA_MODIFIER_MOTION_NONE)



gyrocopter_custom_rocket_barrage = class({})


function gyrocopter_custom_rocket_barrage:OnToggle()
	self.caster = self:GetCaster()
	self.damage = self:GetSpecialValueFor("rocket_damage")
	local talent = self.caster:FindAbilityByName("gyrocopter_custom_bonus_unique_1")
	if talent and talent:GetLevel() > 0 then
		self.damage = self.damage + talent:GetSpecialValueFor("value")
	end
    self.caster:EmitSound("Hero_Gyrocopter.Rocket_Barrage")
    if self:GetToggleState() then
        self.caster:AddNewModifier(self.caster, self, "modifier_gyrocopter_custom_rocket_barrage", {})
        self.caster:AddNewModifier(self.caster, self, "modifier_gyrocopter_custom_rocket_barrage_mana", {})
    else
        self.caster:RemoveModifierByName("modifier_gyrocopter_custom_rocket_barrage")
        self.caster:RemoveModifierByName("modifier_gyrocopter_custom_rocket_barrage_mana")
    end
end
function gyrocopter_custom_rocket_barrage:OnUpgrade()
    if self:GetToggleState() then
        self:ToggleAbility()
        self:ToggleAbility()
	end
end

if IsServer() then


    function gyrocopter_custom_rocket_barrage:OnProjectileHit(target)
        if target and self.caster and not self.caster:IsIllusion() then
            ApplyDamage({
                attacker = self.caster,
                victim = target,
                damage = self.damage,
                damage_type = self:GetAbilityDamageType(),
                ability = self
            })
            target:EmitSound("Hero_Gyrocopter.Rocket_Barrage.Impact")
        end
    end
end


modifier_gyrocopter_custom_rocket_barrage_mana = class({})


function modifier_gyrocopter_custom_rocket_barrage_mana:IsHidden()
    return true
end


if IsServer() then
    function modifier_gyrocopter_custom_rocket_barrage_mana:OnCreated()
        self.parent = self:GetParent()
		self.ability = self:GetAbility()
		self.mana_cost = self.ability:GetManaCost(-1)
        self:StartIntervalThink(1.0)
    end


    function modifier_gyrocopter_custom_rocket_barrage_mana:OnIntervalThink()
        if self.parent:GetMana() >= self.mana_cost then
            self.parent:SpendMana(self.mana_cost, ability)
        else
            self.ability:ToggleAbility()
        end
    end
end



modifier_gyrocopter_custom_rocket_barrage = class({})


function modifier_gyrocopter_custom_rocket_barrage:GetTexture()
    return "gyrocopter_rocket_barrage"
end


function modifier_gyrocopter_custom_rocket_barrage:GetEffectName()
    return "particles/econ/items/gyrocopter/hero_gyrocopter_atomic/gyro_rocket_barrage_atomic_hit.vpcf"
end


if IsServer() then
    function modifier_gyrocopter_custom_rocket_barrage:SetIntervalThink()
		local baseInterval = (1 / self.ability:GetSpecialValueFor("attack_mult"))
        self:StartIntervalThink(baseInterval / self.parent:GetAttacksPerSecond())
    end

    function modifier_gyrocopter_custom_rocket_barrage:OnCreated()
		self.ability = self:GetAbility()
        self.parent = self:GetParent()
		self.radius = self.ability:GetSpecialValueFor("radius") + self.parent:GetCastRangeBonus()
        self:SetIntervalThink()
    end


    function modifier_gyrocopter_custom_rocket_barrage:OnIntervalThink()
		local count = 0
        local units = FindUnitsInRadius(self.parent:GetTeam(), 
			self.parent:GetAbsOrigin(), 
			nil, 
			self.radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY, 
			DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 
			DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, 
			0, 
			false)
        
        for _, unit in ipairs(units) do
            if unit then
                self:LaunchRocket(unit)
				count = count + 1
                if not self.parent:HasModifier("modifier_gyrocopter_flak_cannon") then
                    break
                end
				if count > 1 then
					break
				end
            end
        end
        self:SetIntervalThink()
    end


    function modifier_gyrocopter_custom_rocket_barrage:LaunchRocket(target)
        self.parent:EmitSound("Hero_Gyrocopter.Rocket_Barrage.Launch")
		local distance = CalcDistanceBetweenEntityOBB(target,self.parent)
        ProjectileManager:CreateTrackingProjectile({
            Ability = self.ability,
            Target = target,
            Source = self.parent,
            EffectName = "particles/units/heroes/hero_gyrocopter/gyro_rocket_barrage.vpcf",
            iMoveSpeed = distance * 5,
            iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
            bDodgeable = false,
            flExpireTime = GameRules:GetGameTime() + 5.0,
        })
    end
end
