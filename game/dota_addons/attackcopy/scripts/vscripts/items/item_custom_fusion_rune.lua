require("lib/my")


item_custom_fusion_rune = class({})



function item_custom_fusion_rune:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local duration = self:GetSpecialValueFor("duration")
	self:StartCooldown(self:GetSpecialValueFor("cooldown"))

    target:AddNewModifier(target, self, "modifier_rune_doubledamage", {duration = duration})
	target:AddNewModifier(target, self, "modifier_rune_haste", {duration = duration})
	target:AddNewModifier(target, self, "modifier_rune_invis", {duration = duration})
	target:AddNewModifier(target, self, "modifier_rune_regen", {duration = duration})
	target:AddNewModifier(target, self, "modifier_rune_arcane", {duration = duration})
	local illusions = CreateIllusions(caster, target,{duration = duration, outgoing_damage = -25, incoming_damage = 25}, 2, 50, true, true )
	for _,illusion in pairs(illusions) do
		illusion:AddNewModifier(caster, self, "modifier_rune_haste", {duration = duration})
		illusion:AddNewModifier(caster, self, "modifier_rune_regen", {duration = duration})
		illusion:AddNewModifier(caster, self, "modifier_rune_arcane", {duration = duration})
	end
end

-- CreateIllusions( handle handle handle int int bool bool )  -- Create illusions of the passed hero that belong to passed unit using passed modifier data. 
				-- ( hOwner, hHeroToCopy, hModiiferKeys, nNumIllusions, nPadding, bScramblePosition, bFindClearSpace )  Supported keys:
-- <Renol>  outgoing_damage incoming_damage bounty_base bounty_growth outgoing_damage_structure outgoing_damage_roshan