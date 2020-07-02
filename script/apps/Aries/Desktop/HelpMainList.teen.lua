--[[
Title: HelpMainList.teen.lua
Author(s): spring yan
Date: 2011/11/21
Desc:  
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Desktop/HelpMainList.teen.lua");
local HelpMainList = commonlib.gettable("MyCompany.Aries.Desktop.HelpMainList");
HelpMainList.ShowPage(helptype,HelpLabel);
-------------------------------------------------------
]]
local Dock = commonlib.gettable("MyCompany.Aries.Desktop.Dock");

local HelpMainList = commonlib.gettable("MyCompany.Aries.Desktop.HelpMainList");
local LOG = LOG;
HelpMainList.selected_node = nil;
HelpMainList.selected_type = nil;
HelpMainList.datasource = nil;
HelpMainList.helptype = nil;

HelpMainList.datasource_map = {
	["TimeMag"]={},
	["HelpBook"]={},
	};

HelpMainList.detailurl="";
HelpMainList.menu_states = {};
HelpMainList.IsInited = {};

--关闭页面的时候记录了上一次选中的类型和id
function HelpMainList.ClosePage()
	local self = HelpMainList;
	if(self.page)then
		self.page:CloseWindow();
		if (HelpMainList.helptype == "TimeMag") then
			if (not System.User.pop_UpdateLog) then
				System.User.pop_UpdateLog = true;
				NPL.load("(gl)script/apps/Aries/Login/ClientUpdaterPage.lua");
				local ClientUpdaterPage = commonlib.gettable("MyCompany.Aries.Login.ClientUpdaterPage");
				local _verbuild = ClientUpdaterPage.GetClientVersion();
				local _ver = string.match(_verbuild,"(.*)Build");

				local _key = string.format("MyCardsManager.pop_UpdateLog_%s",System.User.nid);
				local Player = commonlib.gettable("MyCompany.Aries.Player");
				Player.SaveLocalData(_key, _ver);	
			end
		end
		self.page = nil;
	end
	self.datasource = nil;
end

function HelpMainList.DoInit(helptype)
	if(HelpMainList.IsInited[helptype]) then
		return 
	else
		HelpMainList.IsInited[helptype] = true;
	end

	if (helptype=="TimeMag") then
		HelpMainList.InitMag();
	elseif  (helptype=="HelpBook") then
		HelpMainList.InitGuide();
	end
end

function HelpMainList.InitMag()
	local self = HelpMainList;
	local config_file="config/Aries/HaqiGuide/TimeMagzine.teen.xml"; 

	local xmlRoot = ParaXML.LuaXML_ParseFile(config_file);
	if(not xmlRoot) then
		commonlib.log("warning: failed loading help config file: %s\n", config_file);
		return;
	end

	local xmlnode="/TimeMags/Mag";	

	local tMag={}; -- 初始化 
	local tMonth="";	

	local each_mag,mMonth,mLabel,mNew,mUrl;
	local tId=1;
	for each_mag in commonlib.XPath.eachNode(xmlRoot, xmlnode) do
		mMonth = each_mag.attr.month;
		mLabel = each_mag.attr.label;
		mNew = tonumber(each_mag.attr.isnew);
		mUrl = each_mag.attr.url;
	
		if (tMonth==mMonth) then
			tItem={name="item",helpid=tId, attr={label=mLabel, url=mUrl, isnew=mNew,},};
			table.insert(tMag,tItem);
			tId = tId+1;
		else
			if (next(tMag)) then
				table.insert(self.datasource_map["TimeMag"],tMag);
			end
			tMonth=mMonth;
			tId = 1;
			tMag={name="folder",attr={label=tMonth,},
				{name="item",helpid=tId, attr={label=mLabel, url=mUrl, isnew=mNew,},}
				  };				
			tId = tId+1;
		end
	end

	if (next(tMag)) then
		table.insert(self.datasource_map["TimeMag"],tMag);
	end

--	commonlib.echo(self.datasource_map["TimeMag"]);
end

function HelpMainList.InitGuide()
	local self = HelpMainList;
	local config_file="config/Aries/HaqiGuide/Guide.teen.xml"; 

	local xmlRoot = ParaXML.LuaXML_ParseFile(config_file);
	if(not xmlRoot) then
		commonlib.log("warning: failed loading help config file: %s\n", config_file);
		return;
	end

	local xmlnode="/Guides/Guide";	

	local tGuides={}; -- 初始化 
	local tGuide="";	

	local each_guide,mGuide,mLabel,mNew,mUrl;
	local tId=1;
	for each_guide in commonlib.XPath.eachNode(xmlRoot, xmlnode) do
		mGuide = each_guide.attr.class;
		mLabel = each_guide.attr.label;
		mNew = tonumber(each_guide.attr.isnew);
		mUrl = each_guide.attr.url;

		if (tGuide==mGuide) then	
			tItem={name="item",helpid=tId, attr={label=mLabel, url=mUrl, isnew=mNew,},};
			table.insert(tGuides,tItem);
			tId = tId+1;
		else
			if (next(tGuides)) then
				table.insert(self.datasource_map["HelpBook"],tGuides);
			end
			tGuide = mGuide;
			tId = 1;
			tGuides = {name="folder",attr={label=tGuide,},
				{name="item",helpid=tId, attr={label=mLabel, url=mUrl, isnew=mNew,},}
				  };	
			tId = tId+1;				  			
		end
	end

	if (next(tGuides)) then
		table.insert(self.datasource_map["HelpBook"],tGuides);
	end

	commonlib.echo(self.datasource_map["HelpBook"]);
end


function HelpMainList.OnInit()
	local self = HelpMainList;	
	self.page = document:GetPageCtrl();
end

function HelpMainList.CreatePage(zorder)
	local self = HelpMainList;
	local params = {
				url = "script/apps/Aries/Desktop/HelpMainList.teen.html", 
				name = "HelpMainList.ShowPage", 
				app_key=MyCompany.Aries.app.app_key, 
				isShowTitleBar = false,
				DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
				enable_esc_key = true,
				style = CommonCtrl.WindowFrame.ContainerStyle,
				zorder = zorder or 1;
				allowDrag = true,
				directPosition = true,
					align = "_ct",
					x = -760/2,
					y = -470/2,
					width = 760,
					height = 470,
		}
	System.App.Commands.Call("File.MCMLWindowFrame", params);	
	if(params._page and Dock.OnClose) then
		params._page.OnClose = function(bDestroy)
			Dock.OnClose("HelpMainList.ShowPage")
		end
	end	
end

--@param type:显示的类型 优先级为:type or self.selected_type or "HelpBook";
function HelpMainList.ShowPage(helptype,HelpLabel,zorder)
	local self = HelpMainList;
	HelpMainList.helptype = helptype;
	local selected_type = helptype or self.selected_type or "HelpBook";
	self.FindDataSource(selected_type,HelpLabel)
	self.CreatePage(zorder);
end

function HelpMainList.HoldHelpID(folderid,helpid)
	local self = HelpMainList;
	if(self.selected_type)then
		self.detailurl=self.menu_states[folderid][helpid];
	end
end

--@param type: "TimeMag" "HelpBook" "CombatGuide" "OfficialBBS" "AskGM"
--@param HelpLabel:默认选中的 label
function HelpMainList.FindDataSource(helptype,HelpLabel)
	local self = HelpMainList;
	-- self.datasource_map[helptype] = HelpMainList.CreateHelpFolder(helptype);
	self.DoInit(helptype);

	self.datasource = self.datasource_map[helptype];
	self.selected_type = helptype;

	local selected_label = HelpLabel;
	local datasource = self.datasource;
	
	if(datasource)then
		local find_id = false;
		local first_folder = nil;
		local first_item = nil;
		local folder;
		local folder_id;
		local last_item,last_folderlabel;
		for folder in commonlib.XPath.eachNode(datasource, "//folder") do
			if(not first_folder)then
				first_folder = folder;
			end
			folder_id = folder.attr.label;
			self.menu_states[folder_id]={};
			local item;
			for item in commonlib.XPath.eachNode(folder, "//item") do
				if(not first_item)then
					first_item = item;
				end
				local item_id = item.helpid;				
				self.menu_states[folder_id][item_id]=item.attr.url;				

				if (selected_label) then
					if ( selected_label == item.attr.label) then
						find_id = true;
						folder.attr.expanded = true;
						item.attr.checked = true;		
						last_item = item;	
						last_folderlabel=folder_id;							
					else
						if (last_folderlabel~=folder_id) then
							folder.attr.expanded = false;
						end
						item.attr.checked = false;								
					end
				else
					if(item.attr.checked)then					
						find_id = true;
						folder.attr.expanded = true;
						item.attr.checked = true;		
						last_item = item;	
						last_folderlabel=folder_id;		
					end
				end
			end
		end

		if(not find_id)then
			if(first_folder and first_item)then
				first_folder.attr.expanded = true;
				first_item.attr.checked = true;
				self.HoldHelpID(first_folder.attr.label,first_item.helpid);
			end
		else
			self.HoldHelpID(last_folderlabel,last_item.helpid);
		end
	end
end

function HelpMainList.CreateHelpFolder(helptype)
	local self = HelpMainList;
	if(not helptype)then
		return;
	end
	
	local menus = {};
	return menus;
end

function HelpMainList.CreateFolder(all_list,world,helptype)
	local self = HelpMainList;
	if(not all_list or not world)then
		return;
	end
	local folder = { name = "folder", attr = {label = "", } };
	local label;
	folder.attr.label = label;
	local k,v;
	for k,v in ipairs(all_list) do
	end
	--如果有内容再返回
	local len = #folder;
	if(len > 0)then
		return folder;
	end
end

function HelpMainList.GetFrame(url)
	local s;
	local filename=string.format("config/Aries/HaqiGuide/%s",url);
	local fr=ParaIO.open(filename,"r");
	local _html = fr:GetText();
	fr:close();

	s=string.format([[
 <pe:treeview style="background:;" VerticalScrollBarStep="30" ItemToggleRightSpacing="0" DefaultIconSize="0" DefaultIndentation="0" > 
	<div style="color:#98fffc;">
	%s
	</div>
</pe:treeview>
]],_html);

	--s=string.format([[
 --<pe:treeview style="background:;" VerticalScrollBarStep="30" VerticalScrollBarPageSize="200" >
--<div>
--<iframe name="HelpMainListFrame" width="480px" AutoSize="true" src="config/Aries/HaqiGuide/%s"/>
--</div>
--</pe:treeview>
--]],url);
--
	return s;
end

function HelpMainList.OpenTimgMag()	
	local official_updateinfo_url = MyCompany.Aries.ExternalUserModule:GetConfig().official_updateinfo_url;
	if (official_updateinfo_url) then
		ParaGlobal.ShellExecute("open", official_updateinfo_url, "", "", 1);
	end
end