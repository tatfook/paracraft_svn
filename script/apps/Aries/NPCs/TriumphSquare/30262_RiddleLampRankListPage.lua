--[[
Title: 
Author(s): Leio
Date: 2010/02/24
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/API/minigame/paraworld.minigame.lua");
local msg = {
				gamename = "RiddleLampChallenge",
				score = 1000000 - 10,
			}
commonlib.echo("begin send minigame score:");
commonlib.echo(msg);
paraworld.minigame.SubmitRank(msg,"minigame",function(msg)	
	commonlib.echo("after send minigame score:");
	commonlib.echo(msg);
end);

NPL.load("(gl)script/apps/Aries/NPCs/TriumphSquare/30262_RiddleLampRankListPage.lua");
MyCompany.Aries.Quest.NPCs.RiddleLampRankListPage.PreDialog()		
-------------------------------------------------------
]]
local RiddleLampRankListPage = commonlib.gettable("MyCompany.Aries.Quest.NPCs.RiddleLampRankListPage");
RiddleLampRankListPage.gamename = "RiddleLampChallenge";
RiddleLampRankListPage.my_score = nil; --自己的成绩


function RiddleLampRankListPage.main()
end
function RiddleLampRankListPage.PreDialog()
	local self = RiddleLampRankListPage;
	self.my_score = nil;
	local msg = {
		gamename = self.gamename,
	}
	commonlib.echo("begin get RiddleLampRankListPage ranks:")
	commonlib.echo(msg);
	NPL.load("(gl)script/kids/3DMapSystemApp/API/minigame/paraworld.minigame.lua");
	paraworld.minigame.GetRank(msg,"RiddleLampRankListPage",function(msg)	
		commonlib.echo("after get RiddleLampRankListPage ranks:")
		commonlib.echo(msg);
		if(msg and msg.ranks)then
			
			self.ranks = msg.ranks;
			
			local k,v;
			for k,v in ipairs(self.ranks) do
				if(v.nid == Map3DSystem.User.nid)then
					self.my_score = v.score;
				end
			end
			local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);
			-- show the panel
			System.App.Commands.Call("File.MCMLWindowFrame", {
				url = "script/apps/Aries/NPCs/TriumphSquare/30262_RiddleLampRankListPage.html", 
				app_key = MyCompany.Aries.app.app_key, 
				name = "RiddleLampRankListPage", 
				isShowTitleBar = false,
				DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
				style = style,
				zorder = 2,
				allowDrag = false,
				isTopLevel = true,
				directPosition = true,
					align = "_ct",
					x = -955/2,
					y = -512/2,
					width = 955,
					height = 512,
			});
	
		end
	end);
	return false;
end
function RiddleLampRankListPage.DS_Func_Items(index)
	local self = RiddleLampRankListPage;
	if(not self.ranks)then return 0 end
	if(index == nil) then
		return #(self.ranks);
	else
		return self.ranks[index];
	end
end
function RiddleLampRankListPage.OnInit()
	
end
function RiddleLampRankListPage.ShowInfo(nid)
	if(not nid or nid == "")then return end
	System.App.Commands.Call("Profile.Aries.ShowFullProfile", {nid = nid});
end