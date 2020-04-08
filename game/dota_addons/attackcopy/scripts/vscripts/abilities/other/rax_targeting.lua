require("lib/my")


rax_targeting = class({})
function rax_targeting:OnSpellStart()
	self.target_pos = self:GetCursorPosition()
	print(self.target_pos[0])
	print("heyo")
end