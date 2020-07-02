--[[
Title: Aries Registration Page
Author(s): LiXizhi
Date: 2009/9/24
Desc:  script/apps/Aries/Login/TaoMeeRegConfirmPage.html
Display recommended world server list. 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Login/TaoMeeRegConfirmPage.lua");
-------------------------------------------------------
]]
local TaoMeeRegConfirmPage = {};
commonlib.setfield("MyCompany.Aries.TaoMeeRegConfirmPage", TaoMeeRegConfirmPage)

---------------------------------
-- page event handlers
---------------------------------
-- singleton page
local page;
local MainLogin = commonlib.gettable("MyCompany.Aries.MainLogin");

-- init
function TaoMeeRegConfirmPage.OnInit()
	page = document:GetPageCtrl();
	page:SetValue("nid", MainLogin.state.reg_user.nid);
	page:SetValue("email", MainLogin.state.reg_user.username);
	page:SetValue("password", MainLogin.state.reg_user.password);
end

function TaoMeeRegConfirmPage.OnNext()
	page:CloseWindow();
	
	-- proceed to next page: tricky it will skip the local user select and login page. 
	MainLogin:next_step({IsRegUserConfirmRequested=false, IsRegistrationRequested = false, IsRegUserRequested = false, IsLocalUserSelected=true, IsLoginStarted = true, IsAuthenticated = false});
end


function TaoMeeRegConfirmPage.SaveInfoToDisk()
	NPL.load("(gl)script/ide/OpenFileDialog.lua");
	local ctl = CommonCtrl.OpenFileDialog:new{
			name = "OpenFileDialog1",
			alignment = "_ct",
			left=-256, top=-150,
			width = 512,
			height = 380,
			parent = nil,
			title="保存密码到本地",
			--main_bg = "Texture/Aries/Common/ThemeTeen/pane_bg_32bits.png:7 7 7 7",
			main_bg = "Texture/Aries/Common/Teen/control/list_dock_bg_32bits.png; 0 0 32 75: 12 12 12 19",
			-- initial file name to be displayed, usually "" 
			FileName = "HaqiPass.txt",
			fileextensions = {"text files(*.txt)", },
			folderlinks = {
			{path = "/", text = "/"},
			},			

			onsave = function(ctrlName, filename) 
				commonlib.echo(MainLogin.state.reg_user);
				local infostr=string.format("米米号:%s, 密码: %s, Email: %s",MainLogin.state.reg_user.nid,MainLogin.state.reg_user.password,MainLogin.state.reg_user.username);
				local reg_info={Info=infostr,};

				if(not ParaIO.DoesFileExist(filename)) then
					if(ParaIO.CreateNewFile(filename))then
						commonlib.SaveTableToFile(reg_info, filename);
						ParaIO.CloseFile();
					end
				else
					commonlib.SaveTableToFile(reg_info, filename);
				end		
				commonlib.echo(filename);
				commonlib.echo(reg_info);
				local product_name = MyCompany.Aries.ExternalUserModule:GetConfig().product_name or "魔法哈奇";
				local s = string.format("%s通行证已保存到你的本地硬盘的%s目录下！",product_name,product_name);
				_guihelper.MessageBox(s);
			end
		}
	ctl:SavToFile(true);
end