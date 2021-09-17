
LinkLuaModifier("modifier_gyrocopter_custom_rocket_barrage_effect", "abilities/heroes/gyrocopter_custom_rocket_barrage.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_gyrocopter_custom_rocket_barrage", "abilities/heroes/gyrocopter_custom_rocket_barrage.lua", LUA_MODIFIER_MOTION_NONE)



gyrocopter_custom_rocket_barrage = class({})


function gyrocopter_custom_rocket_barrage:OnToggle()
	self.caster = self:GetCaster()
	self.damage = self:GetSpecialValueFor("rocket_damage")
	self.shard = self.caster:HasModifier("modifier_item_aghanims_shard")
	local talent = self.caster:FindAbilityByName("gyrocopter_custom_bonus_unique_1")
	if talent and talent:GetLevel() > 0 then
		self.damage = self.damage + talent:GetSpecialValueFor("value")
	end
    if self:GetToggleState() then
		self.caster:EmitSound("Hero_Gyrocopter.Rocket_Barrage")
        self.caster:AddNewModifier(self.caster, self, "modifier_gyrocopter_custom_rocket_barrage", {})
    else
        self.caster:RemoveModifierByName("modifier_gyrocopter_custom_rocket_barrage")
    end
end

function gyrocopter_custom_rocket_barrage:OnUpgrade()
    if self:GetToggleState() then
        self:ToggleAbility()
        self:ToggleAbility()
	end
end

function gyrocopter_custom_rocket_barrage:OnInventoryContentsChanged()
	if self.shard then
		if self.shard ~= true and self:GetToggleState() and self:GetCaster():HasModifier("modifier_item_aghanims_shard") then
			self:ToggleAbility()
			self:ToggleAbility()
		end
	else
		if self:GetCaster():HasModifier("modifier_item_aghanims_shard") then
			self.shard = true
			self:ToggleAbility()
			self:ToggleAbility()
		else
			self.shard = false
		end
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


modifier_gyrocopter_custom_rocket_barrage = class({})

function modifier_gyrocopter_custom_rocket_barrage:IsHidden()
    return true
end

if IsServer() then
	function modifier_gyrocopter_custom_rocket_barrage:OnCreated()
		self.parent = self:GetParent()
		self.ability = self:GetAbility()
		self.mana_cost = self.ability:GetManaCost(-1) / 3
		self.modifier = self.parent:AddNewModifier(self.parent, self.ability, "modifier_gyrocopter_custom_rocket_barrage_effect", {})
		self:StartIntervalThink(0.33)
	end

	function modifier_gyrocopter_custom_rocket_barrage:OnDestroy()
		if self.modifier then
			self.modifier:Destroy()
		end
	end

	function modifier_gyrocopter_custom_rocket_barrage:OnIntervalThink()
		if self.parent:GetMana() >= self.mana_cost then
			self.parent:SpendMana(self.mana_cost, self.ability)
			self.modifier:ForceRefresh()
		else
			self.ability:ToggleAbility()
		end
	end
end


modifier_gyrocopter_custom_rocket_barrage_effect = class({})

function modifier_gyrocopter_custom_rocket_barrage_effect:GetTexture()
    return "gyrocopter_rocket_barrage"
end


function modifier_gyrocopter_custom_rocket_barrage_effect:GetEffectName()
    return "particles/econ/items/gyrocopter/hero_gyrocopter_atomic/gyro_rocket_barrage_atomic_hit.vpcf"
end


if IsServer() then
    function modifier_gyrocopter_custom_rocket_barrage_effect:SetIntervalThink()
		local baseInterval = (1 / self.ability:GetSpecialValueFor("attack_mult"))
		self.update = false
      self:StartIntervalThink(baseInterval / self.speed)
    end
	
	function modifier_gyrocopter_custom_rocket_barrage_effect:OnRefresh()
		local newSpeed = self.parent:GetAttacksPerSecond()
		if newSpeed ~= self.speed then
			self.update = true
			self.speed = newSpeed
		end
		self.radius = self.base_radius + self.parent:GetCastRangeBonus()
    end
	
    function modifier_gyrocopter_custom_rocket_barrage_effect:OnCreated()
		self.ability = self:GetAbility()
      self.parent = self:GetParent()
		self.base_radius = self.ability:GetSpecialValueFor("radius")
		self.radius = self.base_radius + self.parent:GetCastRangeBonus()
		self.maxCount = 1
		self.speed = self.parent:GetAttacksPerSecond()
		self.update = false
		if self.parent:HasModifier("modifier_item_aghanims_shard") then
			self.maxCount = 2
		end
        self:SetIntervalThink()
    end


    function modifier_gyrocopter_custom_rocket_barrage_effect:OnIntervalThink()
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
				if count >= self.maxCount then
					break
				end
            end
        end
		if self.update == true then
			self:SetIntervalThink()
		end
    end


    function modifier_gyrocopter_custom_rocket_barrage_effect:LaunchRocket(target)
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
