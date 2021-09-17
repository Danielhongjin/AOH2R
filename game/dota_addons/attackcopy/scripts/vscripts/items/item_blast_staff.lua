
item_blast_staff = class({})


function item_blast_staff:GetIntrinsicModifierName()
    return "modifier_item_blast_staff"
end

function item_blast_staff:OnUpgrade()
local parent = self:GetParent()
	parent:FindModifierByName("modifier_item_blast_staff"):ForceRefresh()
end
function item_blast_staff:OnSpellStart()
	local parent = self:GetParent()
	local target = self:GetCursorPosition()
	local strikes = self:GetSpecialValueFor("strikes")
	for count = 1, strikes do
		local tempTarget = target + Vector(RandomInt(-150,150),RandomInt(-150,150),0)
		local direction = (tempTarget - parent:GetAbsOrigin()):Normalized()
		
		ProjectileManager:CreateLinearProjectile(
			{
				EffectName = "particles/custom/blast_staff_active.vpcf",
				Ability = self,
				vSpawnOrigin = parent:GetAbsOrigin() + Vector(0,0,100),
				vVelocity = direction * 4100,
				fDistance = 1200 + parent:GetCastRangeBonus(),
				fStartRadius = 120,
				fEndRadius = 120,
				Source = parent,
				fExpireTime = GameRules:GetGameTime() + 5,
				bDeleteOnHit = false,
				bHasFrontalCone = false,
				bReplaceExisiting = false,
				iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
				iUnitTargetFlags = DOTA_UNIT_TARGET_FLAGS_NONE,
				iUnitTargetType = self:GetAbilityTargetType(),


			}
		)
	end
	parent:EmitSound("Hero_Alchemist.UnstableConcoction.Stun")
	parent:EmitSound("Hero_Alchemist.UnstableConcoction.Stun")
	
end

if IsServer() then
    function item_blast_staff:OnProjectileHit(target, location)
        if target and target:IsAlive() and not target:IsMagicImmune() then
            local parent = self:GetParent()
			local particleIndex = ParticleManager:CreateParticle("particles/custom/blast_staff_explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
			ParticleManager:SetParticleControl(particleIndex, 3, target:GetAbsOrigin())
            local damage = self:GetSpecialValueFor("int_multiplier") * parent:GetIntellect()

            ApplyDamage({
                ability = self,
                attacker = parent,
                damage = damage,
                damage_type = self:GetAbilityDamageType(),
                victim = target
            })

        end
    end
end

item_blast_staff_1 = class(item_blast_staff)
item_blast_staff_2 = class(item_blast_staff)

LinkLuaModifier("modifier_item_blast_staff", "items/item_blast_staff.lua", LUA_MODIFIER_MOTION_NONE)

modifier_item_blast_staff = class({})

function modifier_item_blast_staff:IsHidden()
    return true
end

function modifier_item_blast_staff:IsPurgable()
	return false
end

if IsServer() then
    function modifier_item_blast_staff:OnCreated(keys)
        local parent = self:GetParent()
        if parent then
			parent:RemoveModifierByName("modifier_item_blast_staff_proc")
            parent:AddNewModifier(parent, self:GetAbility(), "modifier_item_blast_staff_proc", {})
        end
    end
end

function modifier_item_blast_staff:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_blast_staff:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    }
end

function modifier_item_blast_staff:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("bonus_agility")
end


function modifier_item_blast_staff:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_intellect")
end

function modifier_item_blast_staff:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("bonus_strength")
end

LinkLuaModifier("modifier_item_blast_staff_proc", "items/item_blast_staff.lua", LUA_MODIFIER_MOTION_NONE)

modifier_item_blast_staff_proc = class({})

function modifier_item_blast_staff_proc:IsHidden()
    return true
end
function modifier_item_blast_staff_proc:IsPurgable()
	return false
end


function modifier_item_blast_staff_proc:DeclareFunctions()
    return {
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
    }
end

if IsServer() then
	function modifier_item_blast_staff_proc:OnCreated()
		self.parent = self:GetParent()
		self.ability = self:GetAbility()
	end
	function modifier_item_blast_staff_proc:OnAbilityFullyCast(keys)
		local used_ability = keys.ability
		local unit = keys.unit
		if unit == self.parent and used_ability:GetCooldown(0) > 0 and keys.ability ~= self.ability and keys.ability:GetAbilityName() ~= "invoker_invoke" then
			if not self.parent:HasModifier("modifier_item_blast_staff") then
				self:Destroy()
				return nil
			end
			local target = used_ability:GetCursorPosition()
			local direction = (target - self.parent:GetAbsOrigin()):Normalized()
			if target == Vector(0,0,0) or direction == Vector(0,0,0) then
				direction = self.parent:GetForwardVector()
			end
			local projTable = 
			{
				EffectName = "particles/custom/blast_staff_passive.vpcf",
				Ability = self.ability,
				vSpawnOrigin = self.parent:GetAbsOrigin() + Vector(0,0,100),
				vVelocity = direction * 4100,
				fDistance = 1200 + self.parent:GetCastRangeBonus(),
				fStartRadius = 100,
				fEndRadius = 100,
				fExpireTime = GameRules:GetGameTime() + 5,
				Source = self.parent,
				bHasFrontalCone = false,
				bReplaceExisiting = false,
				bDeleteOnHit = true,
				iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
				iUnitTargetFlags = DOTA_UNIT_TARGET_FLAGS_NONE,
				iUnitTargetType = DOTA_UNIT_TARGET_HERO
			}
			local projID = ProjectileManager:CreateLinearProjectile(projTable)
		end
	end

	
	
	
end







