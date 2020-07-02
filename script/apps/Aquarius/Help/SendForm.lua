--[[
Title: code behind for page SendForm.html
Author(s): LiXizhi
Date: 2009/1/1
Desc:  script/apps/Aquarius/Help/SendForm.html?type=QA
Use Lib:
-------------------------------------------------------
-------------------------------------------------------
]]
local SendForm = {};
commonlib.setfield("MyCompany.Aquarius.SendForm", SendForm)

---------------------------------
-- page event handlers
---------------------------------

-- init
function SendForm.OnInit()
	local self = document:GetPageCtrl();
	local type = self:GetRequestParam("type")
	self:SetNodeValue("type", type);
end

-- submit the form
function SendForm.OnSubmit(name,values)
	local page = document:GetPageCtrl();
	--_guihelper.MessageBox("此功能暂未开放, 请直接在聊天窗中输入您的意见")
	--commonlib.echo(values)
	if(values.title == "" or values.content=="")then
		page:SetUIValue("result", "内容或标题不能为空")
		return
	end
	
	page:SetUIValue("result", "正在发送, 请等待")

	-- TODO: send to nid according to the nid of the current user such as this_nid%10+1000
	-- please send to 114,116, instead. 
	local GM_NID = "001";
	Map3DSystem.App.profiles.ProfileManager.GetUserInfo(GM_NID, "help", function(msg)
		if(msg and msg.users and msg.users[1]) then
			local user = msg.users[1];
			local userid = user.userid;
			if(userid) then
				paraworld.email.send({
					to=userid, 
					title=string.format("%s:%s", tostring(values.type), values.title),
					content=values.body, }, 
					"help", 
					function (msg)
						page:CloseWindow();
						_guihelper.MessageBox("发送成功!");
					end)
			end
		else
			page:SetUIValue("result", "发送失败了, 无法联系GM")	
		end
	end)
end
