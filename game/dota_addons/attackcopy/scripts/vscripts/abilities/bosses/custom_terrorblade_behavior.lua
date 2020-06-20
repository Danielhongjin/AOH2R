require("lib/timers")

custom_terrorblade_behavior = class({})


function custom_terrorblade_behavior:OnSpellStart()
	local caster = self:GetCaster()
	local metamorphosis = caster:FindAbilityByName("custom_metamorphosis")
	local terror = caster:FindAbilityByName("terrorblade_terror_wave")
	EmitSoundOn("Hero_Antimage.ManaVoidCast", caster)
	metamorphosis:OnSpellStart()
	terror:OnSpellStart()
end
