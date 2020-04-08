require("lib/my")



item_assault_temp = class({})


function item_assault_temp:GetIntrinsicModifierName()
    return "modifier_item_assault_temp"
end



LinkLuaModifier("modifier_item_assault_temp", "items/item_assault_temp.lua", LUA_MODIFIER_MOTION_NONE)

modifier_item_assault_temp = class({})


function modifier_item_assault_temp:IsHidden()
    return true
end
function modifier_item_assault_temp:IsPurgable()
	return false
end

if IsServer() then
	function modifier_item_assault_temp:OnCreated()
		local parent = self:GetParent()
		local PlayerID = parent:GetPlayerID()
		Timers:CreateTimer(
            0.9,
            function()
				self:GetAbility():Destroy()
				
				if parent:GetNumItemsInInventory() < 9 then
					local item = parent:AddItemByName("item_supreme_assault")
				else
					local item = CreateItem("item_supreme_assault", parent, parent)
					CreateItemOnPositionSync(parent:GetAbsOrigin(), item)
				end
				self:Destroy()
			end
		)
	end
end 