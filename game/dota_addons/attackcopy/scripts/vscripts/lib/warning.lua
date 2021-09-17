--team_number unused
function aoe_line_particle(owner, duration, start_point, end_point, start_radius, end_radius, team_number)	
	local fx = ParticleManager:CreateParticle("particles/custom/line_aoe_warning.vpcf", PATTACH_WORLDORIGIN, owner)
	ParticleManager:SetParticleControl(fx, 0, start_point)
	ParticleManager:SetParticleControl(fx, 1, start_point)
	ParticleManager:SetParticleControl(fx, 2, end_point)
	ParticleManager:SetParticleControl(fx, 3, Vector(end_radius, start_radius, 1))
	ParticleManager:SetParticleControl(fx, 4, Vector(duration, 1, 1))
	ParticleManager:ReleaseParticleIndex(fx)
	return fx
end

function aoe_particle(owner, duration, point, radius, team_number)	
	local fx = ParticleManager:CreateParticle("particles/custom/aoe_warning.vpcf", PATTACH_WORLDORIGIN, owner)
	ParticleManager:SetParticleControl(fx, 0, point)
	ParticleManager:SetParticleControl(fx, 1, Vector(radius, 1, 1))
	ParticleManager:SetParticleControl(fx, 2, Vector(duration, 1, 1))
	ParticleManager:SetParticleControl(fx, 3, Vector(200, 10, 10))
	ParticleManager:ReleaseParticleIndex(fx)
	return fx
end

function line_to_point(owner, duration, start_point, end_point, team_number)
	local fx = ParticleManager:CreateParticle("particles/custom/link_warning.vpcf", PATTACH_OVERHEAD_FOLLOW, owner)
	ParticleManager:SetParticleControlEnt(fx, 0, owner, PATTACH_POINT_FOLLOW, "attach_hitloc", start_point, true)
	ParticleManager:SetParticleControl(fx, 1, end_point)
	ParticleManager:SetParticleControl(fx, 2, Vector(duration, 1, 1))
	ParticleManager:ReleaseParticleIndex(fx)
	return fx
end