

huskar_sacred_flame = class({})


function huskar_sacred_flame:GetIntrinsicModifierName()
    return "modifier_huskar_sacred_flame"
end
if IsServer() then

function huskar_sacred_flame:OnUpgrade()
	self.caster = self:GetCaster()
	self.damage = self:GetSpecialValueFor("damage")
	if self.caster:IsIllusion() then
		self.damage = self.damage / 2
	end
	self.spear = self.caster:FindAbilityByName("huskar_burning_spear")
end

function huskar_sacred_flame:OnProjectileHit(target, pos)
	if target ~= nil then
		if not target:HasModifier("modifier_huskar_burning_spear_debuff") then
			if not self.caster:IsIllusion() then
				local debuff = target:AddNewModifier(self.caster, self.spear, "modifier_huskar_burning_spear_debuff", {duration = self.spear:GetDuration()})
			else
				return
			end
		end
		target:EmitSoundParams("Hero_Huskar.Life_Break.Impact", 0, 0.3, 0)
		local modifier = target:FindModifierByName("modifier_huskar_burning_spear_debuff")
		local count = modifier:GetStackCount()
		if self.caster:HasScepter() then
			local debuff = target:FindModifierByName("modifier_huskar_burning_spear_debuff")
			debuff:SetDuration(self.spear:GetDuration(), true)
			target:AddNewModifier(self.caster, self.spear, "modifier_huskar_burning_spear_counter", {duration = self.spear:GetDuration()})
		end
		ApplyDamage({
			ability = self,
			attacker = self.caster,
			damage = self.damage * count,
			damage_type = self:GetAbilityDamageType(),
			victim = target
		})
			
	end
end
end
LinkLuaModifier("modifier_huskar_sacred_flame", "abilities/heroes/huskar_sacred_flame.lua", LUA_MODIFIER_MOTION_NONE)
modifier_huskar_sacred_flame = class({})

function modifier_huskar_sacred_flame:IsHidden()
    return true
end

function modifier_huskar_sacred_flame:IsPurgable()
	return false
end

if IsServer() then
    function modifier_huskar_sacred_flame:DeclareFunctions()
        return {
            MODIFIER_EVENT_ON_ATTACK_START,
        }
    end
	
	function modifier_huskar_sacred_flame:OnCreated()
		self.ability = self:GetAbility()
		self.parent = self:GetParent()
		self.chance = self.ability:GetSpecialValueFor("chance")
		self.manacost = self.ability:GetManaCost(self.ability:GetLevel())
	end
	
	function modifier_huskar_sacred_flame:OnRefresh()
		self.chance = self.ability:GetSpecialValueFor("chance")
		self.manacost = self.ability:GetManaCost(self.ability:GetLevel())
	end


	function modifier_huskar_sacred_flame:OnAttackStart(keys)
		local attacker = keys.attacker
		local target = keys.target
		if attacker == self.parent and not target:IsNull() then 
			if self.chance >= RandomInt(0, 99) and self.parent:GetMana() > self.manacost then
				if target:HasModifier("modifier_huskar_burning_spear_debuff") or not self.parent:IsIllusion() then
					self.ability:UseResources(true, false, false)
					Timers:CreateTimer(
						(1 / self.parent:GetAttacksPerSecond()) * 0.1875,
						function()
							target:EmitSoundParams("Hero_Huskar.Life_Break", 0, 0.3, 0)
							local info = 
							{
								Target = target,
								Source = self.parent,
								Ability = self.ability,	
								EffectName = "particles/huskar_sacred_flame_attack.vpcf",
									iMoveSpeed = 1400,
								vSourceLoc= self.parent:GetAbsOrigin(),                -- Optional (HOW)
								bDrawsOnMinimap = false,                          -- Optional
									bDodgeable = true,                                -- Optional
									bIsAttack = false,                                -- Optional
									bVisibleToEnemies = true,                         -- Optional
									bReplaceExisting = false,                         -- Optional
									flExpireTime = GameRules:GetGameTime() + 10,      -- Optional but recommended
								bProvidesVision = true,                           -- Optional
								iVisionRadius = 400,                              -- Optional
								iVisionTeamNumber = self.parent:GetTeamNumber()        -- Optional
							}
							projectile = ProjectileManager:CreateTrackingProjectile(info)
						end
					)
				end
			end
		end
	end
end