--[[
Title: Functions for external users imported from different companies and websites
Author(s):  LiXizhi
Company: ParaEnging Co. 
Date: 2011.6.7
Desc: External user function, including account display, nid display, payment interface, regitration interface. 
---++ region id and nid
The nid consists of region_id and display id. The lower 12 digits(without heading zeros) are display id, and the higher 13-14 digits are region id. 
each region id correspond to a single company, such as 0 for taomee, 1 for paraengine, 2 for kuaiwan. 
---++ current region id
we will look in the following order until a region id is located. 
   * command line "region"
   * a file in the current directory called region.txt, in which it contains just a single number of region id
   * 0, the default one
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Login/ExternalUserModule.lua");
local ExternalUserModule = commonlib.gettable("MyCompany.Aries.ExternalUserModule");
ExternalUserModule:Init();
assert(MyCompany.Aries.ExternalUserModule:GetRegionIDFromNid(tostring(1234567)) == 0);
assert(MyCompany.Aries.ExternalUserModule:GetRegionIDFromNid(2*10^12+1234567) == 2);
assert(MyCompany.Aries.ExternalUserModule:GetNidDisplayForm(tostring(2*10^12+1234567)) == "1234567");
assert(MyCompany.Aries.ExternalUserModule:GetNidDisplayForm(1234567) == 1234567);
assert(MyCompany.Aries.ExternalUserModule:MakeNid(1234567,2) == 2*10^12+1234567);
commonlib.echo(MyCompany.Aries.ExternalUserModule:MakeNid("1234567"))

echo(MyCompany.Aries.ExternalUserModule:GetRegionID())
local ex_user_config = MyCompany.Aries.ExternalUserModule:GetConfig();	
commonlib.echo(ex_user_config)
------------------------------------------------------------
]]
local type = type;
local tonumber = tonumber;
local tostring = tostring;

-- sample_config file
local sample_config = {
	-- taomee
	-- globally unique region_id, assigned by ParaEngine to its partners
	region_id = 0,
	-- globally rank_id to get ranklist, assigned by ParaEngine to its partners
	rank_id = 0,
	-- min passwd length
	min_passwdlen=6,
	-- company name, just a label field, not used in game.
	company = "taomee",
	-- account display name to be used when showing nid in the game ui. must be less than 4 letters
	account_name = "米米号",		
	passwd_name = "密码",
	-- the virtual currency defined by the extenal company. This is only used for display. it usually matches with real currency
	currency_name = "米币",
	-- if not provided, pay_url will be used, otherwise the payment_func is used. 
	payment_func = nil,
	-- payment url page. 
	pay_url = "http://pay.61.com/haqi/?",
	-- recharge url page. 
	recharge_url = "http://pay.61.com/buy/paytype?type=cardpay&game=haqi&",
	-- user registrition page. 
	registration_url = "http://account.61.com/register?gid=21",
	-- short url that is displayed at the title of the window
	title_url = "魔法哈奇 http://haqi.61.com",
	-- official web site
	official_site_url = "http://web.2125.com/haqi/",
	-- official blog
	official_blog_url = "http://tieba.baidu.com/%E9%AD%94%E6%B3%95%E5%93%88%E5%A5%87",
	-- official bbs site
	--official_bbs_url = "http://bbs.61.com/index.php?gid=7",
	official_bbs_url = "http://miba.2125.com/thread/l?fid=5",
	-- official service site
	official_service_url = "http://service.61.com/user",
	-- the policy url for the region provider. 
	user_policy_url = "http://www.61.com/about/service.html",
	-- url when user wants to change its account info like password
	account_change_url = "http://account.61.com/change",
	-- url when user forget its password
	account_forget_url = "http://account.61.com/forget",
	-- url protect account
	account_protect_url="http://account.61.com/protect",
	-- url add realname info to account
	account_realname_url="http://account.61.com/user/getVerify",
	-- certificate to be displayed at the bottom of the banner page
	mmo_certificate_text = "增值电信业务许可经营证：沪B2-20090070    文网文[2009]093号 沪新出科数[2010]49号    服务热线：http://service.61.com/user",
	-- developer copyright text
	developer_copyright_text = "Copyright©2007-2013 ParaEngine Co. 提供开发与运营支持",
	-- company's copyright text to be displayed at the bottom of the banner page
	company_copyright_text = "Copyright©2008-2013 TaoMee Inc. All Rights Reserved.", 
	-- text style
	copyright_text_style = "font-size:12px;color:#ffffff;text-shadow:true;shadow-quality:8;shadow-color:#80808080;",
	-- logo image url
	product_logo_url = "margin-top:75px;margin-left:5px;width:226px;height:128px;background:url(Texture/Aries/Login/haqilogo_32bits.png# 0 0 226 128)",
	-- the header logo, if not specified, the default one will be used. should be png of 160*64
	game_header_logo = "Texture/Aries/Login/TaomeeLogo_32bits.png#0 0 160 64",
	-- background image to display when login.
	game_login_bg = "Texture/Aries/Login/UserSelect_BG2_32bits.png#0 0 960 560",
	-- the login banner bg page. 
	logo_bottom_banner_page = "script/apps/Aries/Login/LogoBottomBannerPage.html", 
	developer_logo = "width:128px;height:32px;background:url(Texture/Aries/Login/Login/paraengine_logo_32bits.png)",
	-- logo at the bottom. usually smaller than 256*64
	operator_company_logo = nil,
	-- the url to goto when clicking on operator_company_logo 
	operator_company_url = nil,
	-- square icon
	logoicon=nil,
	-- whether username must be email or not
	is_username_email = true,
	-- whether to share world servers with other region. 
	is_share_worldserver = false,
	-- whether to allow adding friends or family between this region and other regions. 
	is_share_friends= true,
	-- whether to players can meet other players from other regions
	is_share_pvp_arena = true,
	-- whether to players can team up with other players from other regions (this automatically allows Instace world)
	is_share_team = true,
	-- whether to share lobbyclient member's show with other region. 
	is_share_lobbyclient = true,
	--whether to disabel pvp ranking. 
	disable_pvp_ranking = false,
	-- whether to show the flag in 3d scene
	disable_family_flag = false,
	-- whether to show the pvp heroes in 3d scene
	disable_pvp_statues = false,
	-- if true, region logics is disabled
	disable_regions = nil,
	-- mapping from world zone id(as returned from WorldServer.Get API) to access symbol. "u" means user can login. "g" means the user is a guest, it can view but can not login. nil means no access.
	-- As a rule, administer should use (region_id * 10 + local_id) as the zone id. 
	world_zones = {[0]="u", [1]="u", [1000]="u"},
};

local default_values = {
	mc_login_bg = "Texture/Aries/Login/mcworld_BG.jpg#0 0 960 560",
}
local configs = {sample_config};

-- mapping from region id to its configuration settings. 
local config_map = {};

-- create class
local ExternalUserModule = commonlib.gettable("MyCompany.Aries.ExternalUserModule");

-- the company region id: 0 for taomee, 1 for paraengine, 2 for kuaiwan , 3 QQ, 4 Facebook, etc. 
local region_id = 0;

-- 12 zero-digits
local nid_high_bits = 10^12;

local enable_regions = true;
--[[ only for testing
function ExternalUserModule:Dump()
	NPL.load("(gl)script/ide/LuaXML.lua");
	local file = ParaIO.open("temp/ExternalUserModule.xml", "w");
	if(file:IsValid()) then

		local function dump_(config)
			if(not config) then 
				return 
			end
			local o = {name="region", region_id=config.region_id, locale=".*"};
			local name, value;
			for name, value in pairs(config) do
				o[#o+1] = {name=name, attr={value=value}};
			end
			local text = commonlib.Lua2XmlString(o, true);
			file:WriteString(text);
		end
	
		dump_(configs_kids[1]);
		dump_(configs_kids[2]);
		dump_(configs_kids[3]);

		dump_(configs_teen[1]);
		dump_(configs_teen[2]);
		dump_(configs_teen[3]);
	
		dump_(configs_gapp[1]);

		file:close();
	end
end
]]

-- initialize the module
-- @param bForceReinit: if true we will force reinit. 
function ExternalUserModule:Init(bForceReinit,new_region_id)
	if(not bForceReinit and self.is_inited) then
		return
	end
	-- 2017.7.29 added by Xizhi: force keepwork.com instead of taomee.com
	if(new_region_id == 0) then
		-- new_region_id = 7;
	end

	self.is_inited = true;
	region_id = new_region_id or region_id;
	
	System.options.isPubchk = ParaIO.DoesFileExist("character/Animation/script/pubchk.lua", false);
	
	if(region_id == 3) then
		-- region 3 is official version. 
		System.options.is_official = true;
	else
		System.options.is_official = nil;
	end

	local function install_field(config, name, value)
		if(value == nil) then
		elseif(value == "true") then
			config[name] = true;
		elseif(value == "false") then
			config[name] = false;
		elseif(value:match("^%d+$")) then
			config[name] = tonumber(value);
		elseif(value:match("^{.*}$")) then
			config[name] = NPL.LoadTableFromString(value);
		else
			config[name] = value;
		end
	end

	local filename = if_else(System.options.version == "kids", "config/Aries/Others/ExternalUserModule.kids.xml", "config/Aries/Others/ExternalUserModule.teen.xml");
	local xmlRoot = ParaXML.LuaXML_ParseFile(filename);
	if(xmlRoot) then
		configs = {};

		local node;
		for node in commonlib.XPath.eachNode(xmlRoot, "/regions/region") do
			local config = {};
			config.region_id = tonumber(node.attr.region_id);
			config.locale = node.attr.locale;

			local _, data;
			for _, data in ipairs(node) do
				if(data.attr) then
					install_field(config, data.name, data.attr.value);
				end
			end

			-- install default values
			local name, value
			for name, value in pairs(default_values) do
				if(config[name] == nil) then
					config[name] = value;
				end
			end

			configs[#configs+1] = config;
		end
	else
		LOG.std(nil, "error","ExternalUserModule", "file %s not found", filename);
	end

	--if (System.options.isPubchk) then
		--configs = configs_gapp;
	--else
		--configs = if_else(System.options.version == "kids", configs_kids, configs_teen);
	--end

	-- read from region.txt
	config_map = {};
	
	for _, config in pairs(configs) do
		local last_config = config_map[config.region_id]
		if(last_config) then
			if(config.locale == System.options.locale) then
				-- only overwrite when locale match.
				config_map[config.region_id] = config;
			end
		else
			config_map[config.region_id] = config;
		end
	end

	if(not config_map[region_id]) then
		local new_config = commonlib.clone(configs[1]);
		LOG.std(nil, "info", "region", "creating new config for region %s", tostring(region_id));
		new_config.region_id = region_id;
		config_map[region_id] = new_config;
	end

	local current_config = config_map[region_id];
	if(current_config.disable_regions) then
		enable_regions = false;
	end

	if(bForceReinit) then
		-- update the windows title bar
		local ClientUpdaterPage = commonlib.gettable("MyCompany.Aries.Login.ClientUpdaterPage")
		local version_str="";
		if(ClientUpdaterPage.GetClientVersion) then
			version_str=ClientUpdaterPage.GetClientVersion();
		end
		ParaEngine.SetWindowText(string.format("%s -- ver %s", MyCompany.Aries.ExternalUserModule:GetConfig().title_url, version_str));
	end

	-- show background banner
	if(System.options.mc) then
		-- secretly replace
		-- read from ExternalUserModule.mc.xml
		local filename = if_else(System.options.version == "kids", "config/Aries/Others/ExternalUserModule.mc.xml", "config/Aries/Others/ExternalUserModule.mc.xml");
		local xmlRoot = ParaXML.LuaXML_ParseFile(filename);
		if(xmlRoot) then
			local node;
			for node in commonlib.XPath.eachNode(xmlRoot, "/regions/region") do
				local config = ExternalUserModule:GetConfig();
				local _, data;
				for _, data in ipairs(node) do
					if(data.attr) then
						install_field(config, data.name, data.attr.value);
					end
				end
				-- only use the first one. 
				break;
			end
		end
	end

	LOG.std(nil,"info", "ExternalUserModule", "game title: %s | version: %s", self:GetConfig().title_url or "", System.options.version or "unspecified");
end

-- get the region id of the currently signed in user. 
function ExternalUserModule:GetRegionID()
	return region_id;
end

-- get the region id of the currently signed in user. 
function ExternalUserModule:GetRankID()
	return  ExternalUserModule:GetRankIDByRegionID(region_id);
end

-- get the region id of the currently signed in user. 
function ExternalUserModule:GetRankIDByRegionID(region_id_)
	local config_id =  config_map[region_id_ or region_id] or {};
	if (next(config_id)~=nil) then
		return config_id.rank_id;
	else
		return 0;
	end
end

-- whether the current user can view the zoneid
function ExternalUserModule:CanViewWorldZone(zoneid)
	zoneid = tonumber(zoneid);
	if(zoneid) then
		local config = self:GetConfig();
		local worldzone, worldtype,zone;
		-- nid2 user can login worlds
		for worldzone, worldtype in pairs(config.world_zones) do
			if (worldzone==zoneid and worldtype == "u") then
				return true;
			end
		end
	end
	return false;
end

-- can view region. 
function ExternalUserModule:CanViewRegion(region)
	if(region == self:GetRegionID()) then
		return true;
	else
		return ExternalUserModule:CanViewUser(region*nid_high_bits+1);
	end
end

-- judge whether nid2 can be viewed by nid1 or not. 
-- @param nid1: the nid to adjuge
-- @param nid2: if nil, it is the current user
function ExternalUserModule:CanViewUser(nid1, nid2)
	nid2 = nid2 or System.User.nid;
	-- TODO:
	local config_nid1 = ExternalUserModule:GetConfigByNid(nid1) or {};
	local config_nid2 = ExternalUserModule:GetConfigByNid(nid2) or {};

	if (next(config_nid1)==nil or not config_nid2.world_zones) then
		return false;
	end
	
	local nid2zones = {};
	
	local worldzone, worldtype,zone;
	-- nid2 user can login worlds
	for worldzone, worldtype in pairs(config_nid2.world_zones) do
		if (worldtype=="u") then
			table.insert(nid2zones,worldzone);
		end
	end

	for worldzone, worldtype in pairs(config_nid1.world_zones) do
		if (worldtype=="u") then
			for _,zone	in pairs(nid2zones)	do
				--  如果 nid1 的可登录世界有在 nid2 的可登录世界，即返回 true
				if (worldzone==zone) then
					return true;
				end
			end
		end
	end

	return false;
end

-- get can login zones by nid
function ExternalUserModule:GetMyLoginZoneByNid(nid)
	local config_nid = ExternalUserModule:GetConfigByNid(nid) or {};
	local loginzones = {};
	if (next(config_nid)==nil) then
		return loginzones;
	end	
	local worldzone, worldtype;
	for worldzone, worldtype in pairs(config_nid.world_zones) do
		if (worldtype=="u") then
			table.insert(loginzones,worldzone);
		end
	end

	return loginzones;
end

-- get can login zones by region_id
function ExternalUserModule:GetMyLoginZoneByRegionID(region_id_)
	local config_nid = ExternalUserModule:GetConfig(region_id_) or {};
	local loginzones = {};
	if (next(config_nid)==nil) then
		return loginzones;
	end
	local worldzone, worldtype;
	for worldzone, worldtype in pairs(config_nid.world_zones) do
		if (worldtype=="u") then
			table.insert(loginzones,worldzone);
		end
	end

	return loginzones;
end

-- judge whether worldzone in zones1 is found in zones2 or not. 
-- @param zones1: the zones to adjuge
-- @param zones2: if nil, it is the current user zone
function ExternalUserModule:IsInZones(zones1,zones2)
	zones2 = zones2 or ExternalUserModule:GetMyLoginZoneByNid(System.User.nid);
	local worldzone,zone;		
	for _,worldzone in pairs(zones1) do
		for _,zone	in pairs(zones2)	do
			--  如果 zones1 的世界有在 zones2 的世界，即返回 true
			if (worldzone==zone) then
				return true;
			end
		end
	end
	return false;
end

-- get the configuration table of the current or specified region
-- @param region_id: if nil, it will be the current region_id
function ExternalUserModule:GetConfig(region_id_)
	return config_map[region_id_ or region_id];
end

-- get the configuration table of a given nid. 
-- @param nid: nid string or number 
function ExternalUserModule:GetConfigByNid(nid)
	return config_map[self:GetRegionIDFromNid(nid) or region_id];
end


-- the region id can be extracted from the higher bits of nid. 
-- @param nid: string or number, where number is preferred and used internally. 
function ExternalUserModule:GetRegionIDFromNid(nid)
	nid = tonumber(nid);
	if(nid) then
		if(nid < nid_high_bits) then
			return 0;
		else
			return (nid-nid%nid_high_bits)/nid_high_bits;
		end
	else
		return region_id;
	end
end

-- make nid from display nid and current region id
-- @param display_nid: this can be string or number of the display id(without region in higher bits) or nid(with region in higher bits).
-- @param region_id: must be number. if nil the current region id is used. 
-- @return if nid is string, the returned value is also a string, if number, the returned number is a number. 
function ExternalUserModule:MakeNid(display_nid, region_id_)
	local nid_type = type(display_nid);
	if(nid_type == "number") then
		return (region_id_ or region_id) * nid_high_bits + (display_nid % nid_high_bits);
	elseif(nid_type == "string") then
		display_nid = tonumber(display_nid);
		if(display_nid) then
			return tostring((region_id_ or region_id) * nid_high_bits + (display_nid % nid_high_bits));
		end
	end
end

-- get the display format of a nid. it will trim the higher bits
-- @param nid: string or number. 
-- @return if nid is string, the returned value is also a string, if number, the returned number is a number. 
function ExternalUserModule:GetNidDisplayForm(nid)
	local nid_type = type(nid);
	if(nid_type == "number") then
		return nid%nid_high_bits;
	elseif(nid_type == "string") then
		nid = tonumber(nid);
		if(nid) then
			return tostring(nid%nid_high_bits);
		end
	end
end

function ExternalUserModule:SetRealname()
	local region_id = ExternalUserModule:GetRegionID();
	local cfg = ExternalUserModule:GetConfig();
	local url_realname= cfg.account_realname_url;

	if (region_id==0) then  -- taomee
		local url0=url_realname;
		ParaGlobal.ShellExecute("open", url0, "", "", 1);

	elseif (region_id==2) then -- kuaiwan
		local url0;
		if (System.options.version=="kids") then
			url0 = url_realname .."?game_id=8000008&online_token";
		else
			url0 = url_realname .."?game_id=93496&online_token";
		end
		paraworld.auth.AuthUser({
			username = System.User.username,
			password = System.User.Password,
			}, "login", function (msg)
			if(msg.issuccess) then	
				-- successfully recovered from connection. 
				LOG.std("", "system","Login", "Successfully authenticated for set realname");
				local _url = string.format("%s=%s",url0,msg.sessionid);
				ParaGlobal.ShellExecute("open", _url, "", "", 1);
			end
		end, nil, 20000, function(msg)	end);
	else
		local url0=url_realname;
		ParaGlobal.ShellExecute("open", url0, "", "", 1);
	end	
end

ExternalUserModule.GetNidLowerBits = ExternalUserModule.GetNidDisplayForm;

