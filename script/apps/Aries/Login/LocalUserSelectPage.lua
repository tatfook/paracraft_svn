--[[
Title: Select a user to login from local disk cache
Author(s): LiXizhi
Date: 2009/8/1
Desc:  script/apps/Aries/Login/LocalUserSelectPage.html
if the user has saved logged in user before, this page allows user to quick select a user and log in. 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Login/LocalUserSelectPage.lua");
MyCompany.Aries.LocalUserSelectPage:LoadFromFile();
MyCompany.Aries.LocalUserSelectPage:SaveUserInfo({user_nid = "7654321", user_name = "LiXizhi", password="1234567",email="LiXizhi@paraengine.com",
		asset_table={CCSInfoStr="1#1#0#1#1#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@0#0#0#0#0#336#337#0#0#0#0#0#0#0#0#0#1008#1009#0#1010#0#0#0#0#0#0#"}}
});
-------------------------------------------------------
]]
local LocalUserSelectPage = commonlib.gettable("MyCompany.Aries.LocalUserSelectPage");

local DefaultConfigFile = "config/LocalUsers.table"
-- local users: loaded from config/LocalUsers.table
LocalUserSelectPage.dsUsers = {};
LocalUserSelectPage.displayUsers = {};
-- mapping from nid to user data
LocalUserSelectPage.user_map = {}
LocalUserSelectPage.News = {};
local page;

-- The following is only for debugging purposes; at release time, this table is loaded from config/LocalUsers.table; and also save this table to config/LocalUsers.table
--[[
LocalUserSelectPage.dsUsers = {
	{user_nid = "1234567", user_name = "Leio-名字最多8个字", password="gggggg", email="leio@paraengine.com",
		asset_table={
            name= "test model",
            AssetFile="character/v3/Elf/Female/ElfFemale.xml",
			CCSInfoStr="1#1#1#1#1#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@0#0#0#0#0#336#337#0#0#0#0#0#0#0#0#0#1005#1006#0#1007#0#0#0#0#0#0#",
			IsCharacter = true,
            x=0,y=0,z=0,
        }},
	{user_nid = "7654321", user_name = "LiXizhi", password="1234567",email="LiXizhi@paraengine.com",
		asset_table={
            name= "test model",
            AssetFile="character/v3/Elf/Female/ElfFemale.xml",
			CCSInfoStr="1#1#0#1#1#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@0#0#0#0#0#336#337#0#0#0#0#0#0#0#0#0#1008#1009#0#1010#0#0#0#0#0#0#",
			IsCharacter = true,
            x=0,y=0,z=0,
        }},
	{user_nid = "1010101", user_name = "Andy", password="1234567",email="andy@paraengine.com",
		asset_table={
            name= "test model",
            AssetFile="character/v3/Elf/Female/ElfFemale.xml",
			CCSInfoStr="1#1#0#1#1#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@0#0#0#0#0#336#337#0#0#0#0#0#0#0#0#0#1001#1002#1003#1004#0#0#0#0#0#0#",
			IsCharacter = true,
            x=0,y=0,z=0,
        }},
	{user_nid = "808080", user_name = "测试创建用户", password="1234567",email="newuser@paraengine.com",
		asset_table={
            name= "test model",
            AssetFile= "model/05plants/v5/01tree/CherryTree/CherryTreeStage1.x",
            x=0,y=0,z=0,
        }},
	{user_nid = "100001", user_name = "Leio1", password="gggggg",email="leio1@paraengine.com",
		asset_table={
            name= "test model",
            AssetFile= "model/05plants/v5/01tree/CherryTree/CherryTreeStage2.x",
            x=0,y=0,z=0,
        }},
	{user_nid = "100002", user_name = "Leio2", password="gggggg",email="leio2@paraengine.com",
		asset_table={
            name= "test model",
            AssetFile= "model/05plants/v5/01tree/PineAppleTree/PineAppleTreeStage2.x",
            x=0,y=0,z=0,
        }},
	{user_nid = "100003", user_name = "Leio3", password="gggggg",email="leio3@paraengine.com",
		asset_table={
            name= "test model",
            AssetFile= "model/05plants/v5/01tree/CherryTree/CherryTreeStage2.x",
            x=0,y=0,z=0,
        }},
}
]]

function LocalUserSelectPage:GetUserByNid(user_nid)
	local index = self.user_map[user_nid];
	if(index) then
		return self.displayUsers[index];
	end
end

-- load users from file
-- @param configfile: it can be nil, it will default to DefaultConfigFile:"config/LocalUsers.table"
-- @return the number of users
function LocalUserSelectPage:LoadFromFile(filename)
	NPL.load("(gl)script/apps/Aries/Login/ExternalUserModule.lua");
	local ExternalUserModule = commonlib.gettable("MyCompany.Aries.ExternalUserModule");
	local region_id = tonumber(ExternalUserModule:GetRegionID());
	local myLoginZone = ExternalUserModule:GetMyLoginZoneByRegionID();
	
	filename = self:GetConfigFile(filename);
	if(ParaIO.DoesFileExist(filename)) then
		self.dsUsers = commonlib.LoadTableFromFile(filename) or {};
		
		-- return true if we have found a duplicate
		local function RemoveDuplicate(dsUsers, version)
			-- remove duplicate users 
			local user_nids = {}; 
			local hasDuplicate;
			local index, user;
			
			for index, user in ipairs(dsUsers) do 
				if(not user.user_nid or (user_nids[user.user_nid] and user.version == version)) then
					commonlib.removeArrayItem(dsUsers, index);
					hasDuplicate = true;
					LOG.std("", "error", "Login", "duplicated user nid :%s is found", tostring(user.user_nid))
					break;
				else
					if(user.version == version) then
						user_nids[user.user_nid] = true;
					end
				end
			end
			if(hasDuplicate) then
				RemoveDuplicate(dsUsers, version);
			end
		end

		RemoveDuplicate(self.dsUsers);
		RemoveDuplicate(self.dsUsers, System.options.version);
		
		local user_nids = {}; 
		self.user_map = user_nids;
		self.displayUsers = {last_login_nid = self.dsUsers.last_login_nid};

		local version = System.options.version;
		local plat = System.options.platform_id or System.options.plat;
		local locale = System.options.locale;
		local index, user, dindex, duser;
		for index, user in ipairs(self.dsUsers) do 
			if(not System.options.isKid) then
				-- replace the kids avatar asset file with default teen asset
				if(user.asset_table and user.asset_table.AssetFile == "character/v3/Elf/Female/ElfFemale.xml") then
					user.asset_table.AssetFile = "character/v3/TeenElf/Female/TeenElfFemale.xml";
				end
			end

			if(user.password) then
				user.password = commonlib.Encoding.PasswordDecodeWithMac(user.password);
			end
			if (user.user_nid) then
				local count = #(self.displayUsers);
                local user_region_id = user.region_id or 0;
                local plat = user.plat or 0;
				if((user_region_id == 0 or user_region_id == 7) and (user.locale or locale) == locale and (plat == 0 or plat == 7)) then
					if(user.version == version) then
						if(user_nids[user.user_nid]~=nil) then
							self.displayUsers[user_nids[user.user_nid]] = commonlib.deepcopy(user);
						else
							user_nids[user.user_nid] = count+1;
							self.displayUsers[count+1] = commonlib.deepcopy(user);
							
						end
					elseif(user.version == nil and user_nids[user.user_nid] == nil) then
						user_nids[user.user_nid] = count+1;
						self.displayUsers[count+1] = commonlib.deepcopy(user);
					end
				end
			end
		end
		
		--local nUserCount = #(self.dsUsers);
		local nUserCount = #(self.displayUsers);
		-- number of characters to display on each page. 
		local nItemsPerLine = 3;
		-- spacing between characters in meters 
		local nSpacing = 2.6; 
		local nItemsPerLastLine = ((nUserCount-1) % nItemsPerLine)+1;

		for dindex, duser in ipairs(self.displayUsers) do 
			local nItemsPerLine_ = nItemsPerLine;
			if(dindex > (nUserCount-nItemsPerLastLine)) then
				-- if this is the last line
				nItemsPerLine_ = nItemsPerLastLine;
				dindex = dindex - (nUserCount-nItemsPerLastLine);
			end
			local nHalfLine = (nItemsPerLine_-1)/2;
			duser.OffsetX = tostring((((dindex-1)%nItemsPerLine_)-nHalfLine)*nSpacing + 0.2 );
			-- commonlib.echo(user.OffsetX)
		end
	end

	--return #(self.dsUsers);
	return #(self.displayUsers);
end

-- @param filename: nil or filename. 
-- @return writable directory for file saving. 
function LocalUserSelectPage:GetConfigFile(filename)
	return ParaIO.GetWritablePath()..(filename or DefaultConfigFile);
end

-- save a user info to local disk, so the next time, the user does not need to reenter user name and password. 
-- @param userInfo:  a table such as {user_nid = "7654321", user_name = "LiXizhi", password="1234567",email="LiXizhi@paraengine.com",
--		asset_table={
--				name= "test model",  -- optional
--				AssetFile="character/v3/Elf/Female/ElfFemale.xml", -- optional
--				CCSInfoStr="1#1#0#1#1#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@0#0#0#0#0#336#337#0#0#0#0#0#0#0#0#0#1008#1009#0#1010#0#0#0#0#0#0#",
--				IsCharacter = true, -- optional
--				x=0,y=0,z=0, -- optional
--        }}
--  if nil, it we will simply rewrite current setting to file
function LocalUserSelectPage:SaveUserInfo(userInfo, bDeleteUser)
	if(userInfo and userInfo.user_nid) then 
		if(not bDeleteUser) then
			userInfo.version = System.options.version;
			userInfo.locale = System.options.locale;
			userInfo.asset_table = userInfo.asset_table or {};
			local asset_table = userInfo.asset_table;

			local bean = MyCompany.Aries.Pet.GetBean();
			if(bean) then
				userInfo.combatlvl = bean.combatlel;
				if(MyCompany.Aries.Combat.HasPickedSchool())then
					local school = MyCompany.Aries.Combat.GetSchool();

					if(school=="fire")then
						userInfo.school = "烈火系";
					elseif(school=="ice")then
						userInfo.school = "寒冰系";
					elseif(school=="storm")then
						userInfo.school = "风暴系";	
					elseif(school=="life")then
						userInfo.school = "生命系";
					elseif(school=="death")then
						userInfo.school = "死亡系";
					end
				end
			else
				userInfo.combatlvl = 0;
				userInfo.school = userInfo.school;
			end

			asset_table.AssetFile = asset_table.AssetFile or if_else(System.options.version=="kids", "character/v3/Elf/Female/ElfFemale.xml", "character/v3/TeenElf/Female/TeenElfFemale.xml");
			-- asset_table.CCSInfoStr = asset_table.CCSInfoStr or if_else(System.options.version=="kids","1#1#0#1#1#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@0#0#0#0#0#336#337#0#0#0#0#0#0#0#0#0#1008#1009#0#1010#0#0#0#0#0#0#", "0#1#0#3#1#@100#F#0#0#0#0#0#F#0#0#0#0#-1#F#0#0#0#0#-1#F#0#0#0#0#-1#F#0#0#0#0#-1#F#0#0#0#0#100#F#0#0#0#0#@0#0#0#0#0#982#0#0#0#0#0#0#0#41001#0#41002#0#0#0#31266#0#0#0#0#0#0#");
			if( asset_table.IsCharacter == nil) then
				asset_table.IsCharacter = true;
			end
			asset_table.x = asset_table.x or 0;
			asset_table.y = asset_table.y or 0;
			asset_table.z = asset_table.z or 0;
	 
			local old_index;
			local nil_version_user_index;
			local index, user
			for index, user in ipairs(LocalUserSelectPage.dsUsers) do 
				if(user.user_nid==userInfo.user_nid) then
					if(user.version==userInfo.version) then
						old_index = index;
						LocalUserSelectPage.dsUsers[index] = userInfo;
					elseif(user.version == nil) then
						LocalUserSelectPage.dsUsers[index] = {user_nid = userInfo.user_nid, password = userInfo.password};
						nil_version_user_index = index;
					end
				end				
			end
			
			-- only save nil version for users without platform id
			if(not nil_version_user_index and not userInfo.plat) then
				commonlib.insertArrayItem(LocalUserSelectPage.dsUsers, nil, {user_nid = userInfo.user_nid, password = userInfo.password});
				nil_version_user_index = #(LocalUserSelectPage.dsUsers);
			end
			-- insert array item
			if(not old_index) then
				commonlib.insertArrayItem(LocalUserSelectPage.dsUsers, nil_version_user_index or 1, userInfo);
			elseif(nil_version_user_index and nil_version_user_index < old_index) then
				-- tricky: this ensures that nil index is always behind the versioned ones. 
				commonlib.swapArrayItem(LocalUserSelectPage.dsUsers, nil_version_user_index, old_index);
			end
		else
			-- delete user
			commonlib.removeArrayItems(LocalUserSelectPage.dsUsers, function(index, item)
				return (item and item.user_nid == userInfo.user_nid);
			end)
		end
	end

	-- encode password
	local index, user
	for index, user in ipairs(LocalUserSelectPage.dsUsers) do 
		if(user.password) then
			user.password = commonlib.Encoding.PasswordEncodeWithMac(user.password);
		end
	end

	local filename = self:GetConfigFile();
	ParaIO.CreateDirectory(filename);
	-- save to file. 
	commonlib.SaveTableToFile(LocalUserSelectPage.dsUsers, filename, true);
	
	-- encode password
	for index, user in ipairs(LocalUserSelectPage.dsUsers) do 
		if(user.password) then
			user.password = commonlib.Encoding.PasswordDecodeWithMac(user.password);
		end
	end

	LOG.std("", "system", "Login", "local user info is saved to "..filename);
end

-- The data source function. 
function LocalUserSelectPage.DS_Func(index, pageCtrl)
	if(index == nil) then
		-- return #(LocalUserSelectPage.dsUsers);
		return #(LocalUserSelectPage.displayUsers);
	else
		-- return LocalUserSelectPage.dsUsers[index];
		return LocalUserSelectPage.displayUsers[index];
	end
end

---------------------------------
-- page event handlers
---------------------------------
-- singleton page
local page;
local MainLogin = commonlib.gettable("MyCompany.Aries.MainLogin");

-- init
function LocalUserSelectPage.OnInit()
	page = document:GetPageCtrl();
	page.OnClose = LocalUserSelectPage.OnClose;
	
	-- LocalUserSelectPage.ClearScene();
end

function LocalUserSelectPage.OnClickDelete(index)
	LocalUserSelectPage.deleteindex = tonumber(index);
--	local s = string.format([[<div style="margin-left:24px;margin-top:32px;">你是否要从本地删除 %s(%s) 的登录信息？</div>]],
--								LocalUserSelectPage.dsUsers[tonumber(index)].user_name, LocalUserSelectPage.dsUsers[tonumber(index)].user_nid );

	local s = string.format([[你确定要删除帐号%s(%s)下的登录信息吗？<br/>（注：删除后本地电脑上不再列出您的角色,但您仍然可以用该帐号登录)]],
								LocalUserSelectPage.displayUsers[tonumber(index)].user_nid or "",LocalUserSelectPage.displayUsers[tonumber(index)].user_name or "");

	_guihelper.MessageBox( s, function(res)
		if(res and res == _guihelper.DialogResult.Yes) then
			MyCompany.Aries.LocalUserSelectPage.RemoveUserInfo();
		end	
	end, _guihelper.MessageBoxButtons.YesNo);
end

function LocalUserSelectPage.RemoveUserInfo()
	local self = LocalUserSelectPage;
	index = tonumber(LocalUserSelectPage.deleteindex);
	
	-- remove user_nid
	LocalUserSelectPage:SaveUserInfo(self.displayUsers[index], true);

	commonlib.removeArrayItem(self.displayUsers, index );

	-- local nUserCount = #(LocalUserSelectPage.dsUsers);
	local nUserCount = #(LocalUserSelectPage.displayUsers);
	local nItemsPerLine = 3;
	local nSpacing = 2.6; 
	local nItemsPerLastLine = ((nUserCount-1) % nItemsPerLine)+1;
	local index, user
	-- for index, user in ipairs(LocalUserSelectPage.dsUsers) do 
	for index, user in ipairs(LocalUserSelectPage.displayUsers) do 
		local nItemsPerLine_ = nItemsPerLine;
		if(index > (nUserCount-nItemsPerLastLine)) then
			-- if this is the last line
			nItemsPerLine_ = nItemsPerLastLine;
			index = index - (nUserCount-nItemsPerLastLine);
		end
		local nHalfLine = (nItemsPerLine_-1)/2;
		user.OffsetX = tostring((((index-1)%nItemsPerLine_)-nHalfLine)*nSpacing + 0.2 );
	end

	
	page:Refresh(0.01);
end

-- called when page is closed. 
function LocalUserSelectPage.OnClose(bDestroy)
	
end

-- clear 3d ui scenes
function LocalUserSelectPage.ClearScene()
	local scene = ParaScene.GetMiniSceneGraph("DefaultCanvas3DUI");
	if(scene) then
		scene:DestroyObject("login_canvas0");
		scene:DestroyObject("login_canvas1");
		scene:DestroyObject("login_canvas2");
	end
end

-- search a given user by its user nid. 
function LocalUserSelectPage.SearchUser(user_nid)
	local index, user
	for index, user in ipairs(LocalUserSelectPage.displayUsers) do 
		if(user.user_nid==user_nid) then
			return user;
		end
	end
end

-- user selected a given user.
function LocalUserSelectPage.OnSelectUser(user_nid)
	NPL.load("(gl)script/apps/Aries/Creator/Game/GameMarket/EnterGamePage.lua");
	local EnterGamePage = commonlib.gettable("MyCompany.Aries.Creator.Game.Desktop.EnterGamePage");
	if(EnterGamePage.IsSecretKeyPressed()) then
		-- if left control + right click, we will open creator load world with offline support. 
		EnterGamePage.ShowPage(true)
		return;
	end

	local user = LocalUserSelectPage.SearchUser(user_nid)
	if(user) then
		LocalUserSelectPage.CloseWindow();
		MainLogin:next_step({IsLocalUserSelected = true, local_user = user});
	else
		_guihelper.MessageBox("用户不存在, 请尝试其他用户")
	end
end

-- close this window
function LocalUserSelectPage.CloseWindow()
	if(page) then
		page:CloseWindow();
	end
end

function LocalUserSelectPage.OnClickUseOtherAccount()
	LocalUserSelectPage.CloseWindow();
	MainLogin:next_step({IsLocalUserSelected = true});
end

function LocalUserSelectPage.OnClickRegAccount()
	if(false and System.options.IsMobilePlatform) then
		ParaGlobal.ShellExecute("open", "http://account.61.com/register?gid=21", "", "", 1);
	else
		LocalUserSelectPage.CloseWindow();
		MainLogin:next_step({IsRegistrationRequested = true});
	end
end

-- The news_data source function. 
function LocalUserSelectPage.News_DS_Func(index)
	local self = LocalUserSelectPage;
	if(index == nil) then
		return #(LocalUserSelectPage.News);
	else
		return LocalUserSelectPage.News[index];
	end
end

-- The loadNews function. 
function LocalUserSelectPage:LoadNews()
	local xmlRoot = System.SystemInfo.GetField("login_news_page_data");
	if(xmlRoot) then
		local news = commonlib.XPath.selectNode(xmlRoot, "//haqi:news");
		if(news) then
			local i;
			local m = #(news);
			for i=1, m  do
				if(news[i].attr) then
					local news_item = {news=news[i].attr.text,};
					table.insert(LocalUserSelectPage.News,news_item);
					-- LocalUserSelectPage.News[i]={news=news[i].attr.text,};
				end
			end
		end
	end
	commonlib.echo(LocalUserSelectPage.News);
end

-- Save last login nid to local disk
-- @param:id ref to nid
-- @param:filename as local user login config,if filename is nil,the default config file is applied.
function LocalUserSelectPage:SaveLastLoginNID(id,filename)
	if(id == nil) then
		return;
	end

	local filename = self:GetConfigFile(filename);
	if(ParaIO.DoesFileExist(filename,false) == false) then
		ParaIO.CreateDirectory(filename);
	end

	if(self.dsUsers == nil) then
		self.dsUsers = commonlib.LoadTableFromFile(filename) or {};
	else
		if(self.dsUsers.last_login_nid == id) then
			--no request save
			return;
		else
			-- assign last login id
			self.dsUsers.last_login_nid = id;

			--then save it
			LocalUserSelectPage:SaveUserInfo()
		end
	end
end