item_custom_blink = class({})

function item_custom_blink:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local duration = self:GetSpecialValueFor("duration")
	local range = self:GetSpecialValueFor("blink_range")
	local clamp_range = self:GetSpecialValueFor("blink_range_clamp")
	caster:AddNewModifier(caster, self, "modifier_black_king_bar_immune", {duration = duration})
	ProjectileManager:ProjectileDodge(caster)
	
	ParticleManager:CreateParticle("particles/items_fx/blink_dagger_start.vpcf", PATTACH_ABSORIGIN, caster)
	caster:EmitSound("DOTA_Item.BlinkDagger.Activate")
	
	local origin_point = caster:GetAbsOrigin()
	local difference_vector = point - origin_point
	
	if difference_vector:Length2D() > range then
		point = origin_point + (point - origin_point):Normalized() * clamp_range
	end
	FindClearSpaceForUnit(caster, point, true)
	
	ParticleManager:CreateParticle("particles/items_fx/blink_dagger_end.vpcf", PATTACH_ABSORIGIN, caster)
end
