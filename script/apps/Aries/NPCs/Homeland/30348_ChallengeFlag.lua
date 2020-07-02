--[[
Title: ChallengeFlag
Author(s): Leio
Date: 2010/02/01

use the lib:

------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/SnowArea/30348_ChallengeFlag.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandGateway.lua");
NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");
-- create class
local libName = "ChallengeFlag";
local ChallengeFlag = {
};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.ChallengeFlag", ChallengeFlag);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- ChallengeFlag.main
function ChallengeFlag.main()
	local self = ChallengeFlag; 
end
function ChallengeFlag.PreDialog(npc_id, instance)
	local self = ChallengeFlag; 
	local npc = NPC.GetNpcCharacterFromIDAndInstance(30348);
	local player = ParaScene.GetPlayer();
	if(npc:IsValid() == true and player:IsValid() == true) then
		local dist = npc:DistanceTo(player);
		commonlib.echo("==============dist");
		commonlib.echo(dist);
		if(dist > 5) then
			 return
		end
	end
	
	local HomeLandGateway = Map3DSystem.App.HomeLand.HomeLandGateway;
	if(self.IsInOtherHomeland())then
		if(self.IsChallengedToday())then
			local nickname = self.GetName();
			local s = string.format("<div style='margin-left:15px;margin-top:20px;text-align:center'>今天你已经挑战过%s的家园了，欢迎明天继续来挑战！</div>",
				nickname);
			_guihelper.Custom_MessageBox(s,function(result)
				if(result == _guihelper.DialogResult.OK)then
					commonlib.echo("OK");
				end
			end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
		else
			--提交数据
			local msg = {
				tonid = HomeLandGateway.nid,
			}
			commonlib.echo("==========before ChallengeHomelandFlag");
			commonlib.echo(msg);
			paraworld.users.ChallengeHomelandFlag(msg,"",function(msg)
				commonlib.echo("==========after ChallengeHomelandFlag");
				commonlib.echo(msg);
				if(msg and msg.issuccess)then
					
				end
			end);
			--记录今天已经挑战过 此家园
			self.SaveChallengedToday();
			ItemManager.PurchaseItem(17077, 1, function(msg) end, function(msg)
				if(msg) then
					commonlib.echo("====PurchaseItem 17077 in ChallengeFlag");
					commonlib.echo(msg);
					if(msg.issuccess == true) then
						
					end
				end
			end);
			local nickname = self.GetName();
			local s = string.format("<div style='margin-left:15px;margin-top:20px;text-align:center'>你成功挑战了%s的家园，你们同时都获得了1片红枫叶！欢迎你明天继续来挑战 . </div>",
				nickname);
			_guihelper.Custom_MessageBox(s,function(result)
				if(result == _guihelper.DialogResult.OK)then
					--提醒家园主人
					NPL.load("(gl)script/apps/Aries/Mail/MailClient.lua");
					MyCompany.Aries.Quest.Mail.MailClient.SendMessage({
						msg_type = "challenged",
						sender = Map3DSystem.User.nid,
					},Map3DSystem.App.HomeLand.HomeLandGateway.jid);
					--Map3DSystem.App.PENote.PENote_Client:SendMessage({  
																		--msg_type = "loudspeaker",
																		--to_nid = nil,
																		--from_nid = Map3DSystem.User.nid,
																		--note = "challenged",
																		--},Map3DSystem.App.HomeLand.HomeLandGateway.jid);

				end
			end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});	
		end
	elseif(self.IsInMyHomeland())then
		local s = string.format("<div style='margin-left:15px;margin-top:20px;text-align:center'>你已铺设好中通向挑战之旗的路线，快快多去邀请其他哈奇来吧，他们挑战成功，你也可以获得红枫叶哦！</div>");
		_guihelper.Custom_MessageBox(s,function(result)
			if(result == _guihelper.DialogResult.OK)then
				commonlib.echo("OK");
			end
		end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
		
	end
	return false;
end

function ChallengeFlag.IsInMyHomeland()
	return Map3DSystem.App.HomeLand.HomeLandGateway.IsInMyHomeland()
end
function ChallengeFlag.IsInOtherHomeland()
	return Map3DSystem.App.HomeLand.HomeLandGateway.IsInOtherHomeland()
end
--记录今天挑战过
function ChallengeFlag.SaveChallengedToday()
	local today = ParaGlobal.GetDateFormat("yyyy-MM-dd");
	local nid = Map3DSystem.App.HomeLand.HomeLandGateway.nid;--家园nid
	local key = string.format("NPCs.ChallengeFlag.%d",nid);
	MyCompany.Aries.Player.SaveLocalData(key, today );
end
--今天是否已经挑战过
function ChallengeFlag.IsChallengedToday()
	local today = ParaGlobal.GetDateFormat("yyyy-MM-dd");
	local nid = Map3DSystem.App.HomeLand.HomeLandGateway.nid;--家园nid
	local key = string.format("NPCs.ChallengeFlag.%d",nid);
	local time = MyCompany.Aries.Player.LoadLocalData(key, "")
	if(time == today)then
		return true;
	end
	--MyCompany.Aries.Player.SaveLocalData("NPCs.ChallengeFlag.nid", "2010-02-03")
end
--获取家园主人的名称
function ChallengeFlag.GetName()
	local HomeLandGateway = Map3DSystem.App.HomeLand.HomeLandGateway;
	if(HomeLandGateway.homelandCanvas)then
		local bean = HomeLandGateway.homelandCanvas:GetReadOnlyBean();
		if(bean)then
			local homemaster_info = bean.homemaster_info;
			if(homemaster_info)then
				local nickname = homemaster_info.nickname;
				return nickname;
			end
		end
	end
	return "";
end
--获取家园主人的jid
function ChallengeFlag.GetJID()
	local HomeLandGateway = Map3DSystem.App.HomeLand.HomeLandGateway;
	return HomeLandGateway.jid;
end


