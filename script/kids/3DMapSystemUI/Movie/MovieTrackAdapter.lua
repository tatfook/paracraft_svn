--[[
Title: MovieTrackAdapter
Author(s): Leio Zhang
Date: 2008/10/21
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Movie/MovieTrackAdapter.lua");
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/Animation/Motion/MovieClip.lua");
local MovieTrackAdapter = {

}
commonlib.setfield("Map3DSystem.Movie.MovieTrackAdapter",MovieTrackAdapter);

function MovieTrackAdapter.ValueNodeToClip(mcmlNode,parentMcmlNode)
	if(not mcmlNode)then return; end
	local node
	for node in mcmlNode:next() do
		if(node and node.name == "__KeyFrames__Node")then
			 local keyFrames = node["KeyFrames"];
			if(keyFrames)then
				local clip = CommonCtrl.Animation.Motion.MovieClip:new();
				local layer = CommonCtrl.Animation.Motion.LayerManager:new();
				layer:AddChild(keyFrames);
				-- parentMcmlNode is <pe:movie-camera>......
				layer["ParentMcmlNode"] = parentMcmlNode;
				clip:AddLayer(layer);
				return clip;
			end		
		end
	end
	
end
function MovieTrackAdapter.ItemValueNodeToClip(mcmlNode,moviescript)
	if(not mcmlNode)then return; end
	local node;
	local clip = CommonCtrl.Animation.Motion.MovieClip:new();		
	local item;
	for item in mcmlNode:next() do
		local __,mapping = moviescript:GetAssetNodeFromItemNodeName(item.name);
		local id = item:GetNumber("assetid");
		if(mapping)then
			local node = mapping[id];
			if(node)then
				local valueNodes = node:GetChild("value");
				if(valueNodes)then
					local v_node
					for v_node in valueNodes:next() do				
						if(v_node and v_node.name == "__KeyFrames__Node")then
							local keyFrames = v_node["KeyFrames"];
							if(keyFrames)then
								local layer = CommonCtrl.Animation.Motion.LayerManager:new();
								layer["ParentMcmlNode"] = node;
								layer:AddChild(keyFrames);
								clip:AddLayer(layer);
							end		
						end
					end	
				end
			end
		end 
	end
	return clip;
end