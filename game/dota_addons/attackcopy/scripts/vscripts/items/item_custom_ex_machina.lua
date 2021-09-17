require("lib/my")
require("lib/refresh")


item_custom_ex_machina = class({})



function item_custom_ex_machina:OnSpellStart()
    local caster = self:GetCaster()

	print(self:GetItemSlot())
    if not caster:IsTempestDouble() then

        caster:EmitSound("DOTA_Item.Refresher.Activate")

        local fx = ParticleManager:CreateParticle("particles/items2_fx/refresher.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
        ParticleManager:SetParticleControlEnt(fx, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
        ParticleManager:ReleaseParticleIndex(fx)

        refresh_items(caster, {item_maiar_pendant = true, item_conduit = true, item_custom_fusion_rune = true, item_custom_ex_machina = true, item_plain_ring = true, item_helm_of_the_undying = true, item_echo_wand = true})
    end
end


function item_custom_ex_machina:GetIntrinsicModifierName()
    return "modifier_item_custom_ex_machina"
end



LinkLuaModifier("modifier_item_custom_ex_machina", "items/item_custom_ex_machina.lua", LUA_MODIFIER_MOTION_NONE)

modifier_item_custom_ex_machina = class({})


function modifier_item_custom_ex_machina:IsHidden()
    return true
end

function modifier_item_custom_ex_machina:IsPurgable()
	return false
end

function modifier_item_custom_ex_machina:RemoveOnDeath()
	return false
end

if IsServer() then
	function modifier_item_custom_ex_machina:OnCreated()
		self.ability = self:GetAbility()
		self.parent = self:GetParent()
				self.parent:RemoveModifierByName("modifier_item_custom_ex_machina_buff")
				self.parent:AddNewModifier(self.parent, self.ability, "modifier_item_custom_ex_machina_buff", {})
	end
	
	function modifier_item_custom_ex_machina:OnDestroy()
		self.parent:RemoveModifierByName("modifier_item_custom_ex_machina_buff")
	end
end


LinkLuaModifier("modifier_item_custom_ex_machina_buff", "items/item_custom_ex_machina.lua", LUA_MODIFIER_MOTION_NONE)

modifier_item_custom_ex_machina_buff = class({})


function modifier_item_custom_ex_machina_buff:IsHidden()
    return true
end

function modifier_item_custom_ex_machina_buff:IsPurgable()
	return false
end

function modifier_item_custom_ex_machina_buff:RemoveOnDeath()
	return false
end

function modifier_item_custom_ex_machina_buff:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end


function modifier_item_custom_ex_machina_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    }
end

function modifier_item_custom_ex_machina_buff:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_armor")
end