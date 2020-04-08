

modifier_hard_mode_player = class({})





function modifier_hard_mode_player:IsPurgable()
    return false
end

function modifier_hard_mode_player:IsDebuff()
    return true
end


function modifier_hard_mode_player:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE,
	}
	return funcs
end

if IsServer() then
function modifier_hard_mode_player:GetModifierHealAmplify_Percentage()
	local negative = -50
    return negative
end

end