--[[
Title: Pet application for ParaWorld
Author(s): WangTian
Date: 2008/1/10
NOTE: 
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Pet/Pet.lua");
------------------------------------------------------------
]]

if(not Map3DSystem.UI.Pet) then Map3DSystem.UI.Pet = {}; end

function Map3DSystem.UI.Pet.OnClick()
	log("Map3DSystem.UI.Pet.OnClick\n");
end

function Map3DSystem.UI.Pet.OnMouseEnter()
	log("Map3DSystem.UI.Pet.OnMouseEnter\n");
end

function Map3DSystem.UI.Pet.OnMouseLeave()
	log("Map3DSystem.UI.Pet.OnMouseLeave\n");
end