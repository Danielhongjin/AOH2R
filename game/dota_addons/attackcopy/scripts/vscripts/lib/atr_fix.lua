require("lib/my")

-- Fixes the magic res str gives. Check if it is a hero before calling.
function fix_atr_for_hero(hero)

    if not hero:HasAbility("hero_attribute_fix") then
        local ability = hero:AddAbility("hero_attribute_fix")
		ability:SetLevel(1)
    end
end
