--[[
Author(s): Leio
Date: 2007/12/27
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/SnakeGame/DBSnakeGame.lua");
------------------------------------------------------------
		
]]

if(not Map3DSystem.UI.DBSnakeGame) then Map3DSystem.UI.DBSnakeGame={}; end
Map3DSystem.UI.DBSnakeGame.Path="script/kids/3DMapSystemUI/SnakeGame";
Map3DSystem.UI.DBSnakeGame.ScoreFile=Map3DSystem.UI.DBSnakeGame.Path.."/score.txt";
function Map3DSystem.UI.DBSnakeGame.GetScoreList()

	ParaIO.CreateDirectory(Map3DSystem.UI.DBSnakeGame.Path);
	local file = ParaIO.open(Map3DSystem.UI.DBSnakeGame.ScoreFile, "r");
	if(not file) then
		ParaIO.CreateNewFile(logfile);	
	end
	local list={};
	for i=1,6 do
		local s=file:readline();
			  if(s~=nil)then
				table.insert(list,s);
			  end
	end
	return list;
end

function Map3DSystem.UI.DBSnakeGame.SaveScore(score)
	if(score==0 or score==nil)then
		return;
	end
	local list=Map3DSystem.UI.DBSnakeGame.GetScoreList();
		  table.insert(list,score);
		  table.sort(list, function(a, b) return tonumber(a) > tonumber(b) end);
		  
	local file = ParaIO.open(Map3DSystem.UI.DBSnakeGame.ScoreFile, "w");
		if(file:IsValid()) then
			for i=1,6 do
				if(list[i]~=nil)then
					file:WriteString(list[i].."\r\n");
				end
			end
			file:close();
		end
end