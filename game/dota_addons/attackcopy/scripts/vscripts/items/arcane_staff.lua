require("lib/my")
require("lib/popup")
LinkLuaModifier("modifier_item_arcane_staff_bubble", "items/arcane_staff.lua", LUA_MODIFIER_MOTION_NONE)


arcane_staff = class({})


function arcane_staff:GetIntrinsicModifierName()
    return "modifier_item_arcane_staff"
end

function arcane_staff:OnSpellStart()
	if IsServer() then
		self.bubble_duration = self:GetSpecialValueFor( "bubble_duration" )

		local hTarget = self:GetCursorTarget()
		if not PlayerResource:IsDisableHelpSetForPlayerID(self:GetCaster():GetPlayerOwnerID(), hTarget:GetPlayerOwnerID()) then
			hTarget:AddNewModifier( self:GetCaster(), self, "modifier_item_arcane_staff_bubble", { duration = self.bubble_duration } )

			EmitSoundOn( "DOTA_Item.GhostScepter.Activate", self:GetCaster() )
		end
	end
end


modifier_item_arcane_staff_bubble = class({})

function modifier_item_arcane_staff_bubble:IsHidden()
	return true
end

function modifier_item_arcane_staff_bubble:GetEffectName()
	return "particles/econ/items/winter_wyvern/winter_wyvern_ti7/wyvern_cold_embrace_ti7buff.vpcf"
end

function modifier_item_arcane_staff_bubble:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_item_arcane_staff_bubble:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
    }
end

function modifier_item_arcane_staff_bubble:GetModifierHealthRegenPercentage()
    return self:GetAbility():GetSpecialValueFor("bubble_heal_pct")
end

function modifier_item_arcane_staff_bubble:CheckState()
	local state = {}
	if IsServer()  then
		state[ MODIFIER_STATE_ROOTED ] = true
		state[ MODIFIER_STATE_DISARMED] = true
		state[ MODIFIER_STATE_MAGIC_IMMUNE ] = true
		state[ MODIFIER_STATE_INVULNERABLE ] = true
		state[ MODIFIER_STATE_OUT_OF_GAME ] = true
		state[ MODIFIER_STATE_UNSELECTABLE ] = true
	end

	return state
end

item_arcane_staff = class(arcane_staff)
item_arcane_staff_2 = class(arcane_staff)

LinkLuaModifier("modifier_item_arcane_staff", "items/arcane_staff.lua", LUA_MODIFIER_MOTION_NONE)
modifier_item_arcane_staff = class({})

function modifier_item_arcane_staff:IsHidden()
    return true
end

function modifier_item_arcane_staff:IsPurgable()
	return false
end

function modifier_item_arcane_staff:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_arcane_staff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    }
end

if IsServer() then
	function modifier_item_arcane_staff:OnCreated()
		local parent = self:GetParent()
		if parent:IsRealHero() and not parent:IsTempestDouble() then
			self.base = self:GetAbility():GetSpecialValueFor("crit_damage_base")
			self.mult = self:GetAbility():GetSpecialValueFor("crit_damage_mult") - 100
			local PlayerID = parent:GetPlayerID()
			_G.AOHGameMode.SetArcane(PlayerID, self.base, self.mult)
		end
	end 
	
	function modifier_item_arcane_staff:OnDestroy()
		local parent = self:GetParent()
		if parent:IsRealHero() and not parent:IsTempestDouble() then
			local PlayerID = parent:GetPlayerID()
			_G.AOHGameMode.SetArcane(PlayerID, -self.base, -self.mult)
		end
	end 
end
function modifier_item_arcane_staff:GetModifierPreAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor("bonus_damage")
end


function modifier_item_arcane_staff:GetModifierBonusStats_Intellect()
    return self:GetAbility():GetSpecialValueFor("bonus_int")
end


