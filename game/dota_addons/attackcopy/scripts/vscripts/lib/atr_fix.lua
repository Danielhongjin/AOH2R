require("lib/my")


LinkLuaModifier("modifier_atr_fix", "modifiers/modifier_atr_fix.lua", LUA_MODIFIER_MOTION_NONE)


-- Fixes the magic res str gives. Check if it is a hero before calling.
function fix_atr_for_hero(hero)
	local fix_mod = "modifier_atr_fix"

    if not hero:HasModifier(fix_mod) then
        hero:AddNewModifier(hero, nil, fix_mod, {})
    end
end
