beastmaster_custom_hawk = class({})


function beastmaster_custom_hawk:GetIntrinsicModifierName()
    return "modifier_beastmaster_custom_hawk"
end
LinkLuaModifier("modifier_beastmaster_custom_hawk_aura", "items/item_plain_ring.lua", LUA_MODIFIER_MOTION_NONE)
modifier_beastmaster_custom_hawk_aura = class({})



function modifier_beastmaster_custom_hawk_aura:IsHidden()
    return true
end

function modifier_beastmaster_custom_hawk_aura:IsPurgable()
	return false
end
function modifier_beastmaster_custom_hawk_aura:IsAura()
    return true
end


function modifier_beastmaster_custom_hawk_aura:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("aura_radius")
end


function modifier_beastmaster_custom_hawk_aura:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end


function modifier_beastmaster_custom_hawk_aura:GetAuraSearchType()
    return DOTA_UNIT_TARGET_BASIC
end


function modifier_beastmaster_custom_hawk_aura:GetModifierAura()
    return "modifier_beastmaster_custom_hawk"
end


function modifier_beastmaster_custom_hawk_aura:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end




LinkLuaModifier("modifier_beastmaster_custom_hawk", "abilities/heroes/beastmaster_custom_hawk.lua", LUA_MODIFIER_MOTION_NONE)
modifier_beastmaster_custom_hawk = class({})


function modifier_beastmaster_custom_hawk:IsHidden()
    return false
end

if IsServer() then
    function modifier_beastmaster_custom_hawk:OnCreated(keys)
        self.parent = self:GetParent()
		self.ability = self:GetAbility()
        self.owner = self.parent:GetOwner()
		self.interval = self.ability:GetSpecialValueFor("interval") 
		self.radius = self.ability:GetSpecialValueFor("radius")
		self.damage = self.ability:GetSpecialValueFor("damage")
		self:StartIntervalThink(self.interval)
		print("what")
    end
	function modifier_beastmaster_custom_hawk:OnIntervalThink()
		local parent_location = self.parent:GetAbsOrigin()
		print("heyo")
		local units = FindUnitsInRadius(self.parent:GetTeamNumber(), parent_location, nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, self.target_types, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
		for _,unit in ipairs(units) do
			ApplyDamage({
				attacker = self.owner,
				victim = unit,
				damage = self.damage,
				damage_type = DAMAGE_TYPE_PHYSICAL,
				ability = self.ability
			})
			break
		end
    end
end

