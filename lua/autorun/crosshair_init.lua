AddCSLuaFile()
AddCSLuaFile("crosshair/cl_crosshair.lua")

if CLIENT then
    include("crosshair/cl_crosshair.lua")
elseif SERVER then
    include("crosshair/sv_crosshair.lua")
end