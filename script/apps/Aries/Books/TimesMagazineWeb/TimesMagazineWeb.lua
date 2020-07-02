--[[
Title: 
Author(s): zhangruofei
Date: 2010/06/01
Desc: 时报通用函数
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Books/TimesMagazineWeb/TimesMagazineWeb.lua");
-------------------------------------------------------
]]

--公共图片资源
local TimesMagazineWeb = commonlib.createtable("MyCompany.Aries.Books.TimesMagazineWeb", {
global= {							
			{ filename = "Texture/Aries/Books/TimesMagazineWeb/arrow_32bits.png" },
			{ filename = "Texture/Aries/Books/TimesMagazineWeb/flippage_32bits.png" },
			{ filename = "Texture/Aries/Books/TimesMagazineWeb/pagenumber_32bits.png" },
			{ filename = "Texture/Aries/Books/TimesMagazineWeb/MailRod_32bits.png" },
			{ filename = "Texture/Aries/Books/TimesMagazineWeb/Magazine_bg_12_4_Pierced_32bits.png" },
			{ filename = "Texture/Aries/Books/TimesMagazineWeb/Magazine_bg_11_19_32bits.png" },
			{ filename = "Texture/Aries/Books/TimesMagazineWeb/close_11_20_32bits.png" },
			{ filename = "Texture/Aries/Books/TimesMagazineWeb/previous_32bits.png" },
			{ filename = "Texture/Aries/Books/TimesMagazineWeb/next_32bits.png" },
			{ filename = "Texture/Aries/Books/TimesMagazineWeb/gohome_32bits.png" },
			{ filename = "Texture/Aries/Books/TimesMagazineWeb/participate_32bits.png" },
			{ filename = "Texture/Aries/Books/TimesMagazineWeb/mail_small.png" },
			{ filename = "Texture/Aries/Books/TimesMagazineWeb/mail_large.png" },
			{ filename = "Texture/Aries/Books/TimesMagazineWeb/WriteSomeComment.png" },
			{ filename = "Texture/Aries/Books/TimesMagazineWeb/Try.png" },
		},
})
local TimesMagazinePage={};

local ExternalUserModule = commonlib.gettable("MyCompany.Aries.ExternalUserModule");

TimesMagazineWeb.mailpage="";

function TimesMagazineWeb.GetGridViewName()
	return TimesMagazineWeb.GridName;
end

function TimesMagazineWeb.PreInit(version,count,mailpage)
	local filelist = {}
	local i;
	local tmp,tmp1;
	TimesMagazineWeb.GridName = "TimesMagazineWeb_v" .. version;
	for i=1,table.getn( TimesMagazineWeb.global ) do
		table.insert(filelist,TimesMagazineWeb.global[i]);
	end

	TimesMagazineWeb.BackGroundCount = count;

	local region_id = ExternalUserModule:GetRegionID();
	
	TimesMagazineWeb.mailpage=mailpage;
	local mpage={};
	if (mailpage) then
		for mp in string.gfind(mailpage, "([^%s,]+)") do
			mp=tonumber(mp);
			mpage[mp]=true;
		end
	end

	for i=1,count do
		tmp = { filename = string.format("Texture/Aries/Books/TimesMagazineWeb/v%d/%d.jpg",version, i ) }
		table.insert(filelist,tmp);
		if (region_id~=0 and mpage[i])then			
			TimesMagazineWeb.BackGroundCount =TimesMagazineWeb.BackGroundCount-1;
		else
			tmp1 = { filename = string.format("Texture/Aries/Books/TimesMagazineWeb/v%d/%d.jpg",version, i ) }
			table.insert(TimesMagazinePage,tmp1);
		end
	end

	TimesMagazineWeb.DataSource = string.format("Texture/Aries/Books/TimesMagazineWeb/v%d/",version);
	return filelist;
end

function TimesMagazineWeb.Init(homepagelist,pageheadinfo)
	TimesMagazineWeb.pageCtrl = document:GetPageCtrl();
	TimesMagazineWeb.ItemManager = System.Item.ItemManager;
	TimesMagazineWeb.hasGSItem = TimesMagazineWeb.ItemManager.IfOwnGSItem;
	TimesMagazineWeb.equipGSItem = TimesMagazineWeb.ItemManager.IfEquipGSItem;
	TimesMagazineWeb.HomePageList = homepagelist;
	TimesMagazineWeb.DataInfo = pageheadinfo;
	local cfg=ExternalUserModule:GetConfig();
	local region_id = ExternalUserModule:GetRegionID();
	if (region_id==0) then
		TimesMagazineWeb.OfficialUrlInfo = { {name="官网", url=cfg.official_site_url, type="site",},{name="论坛", url=cfg.official_bbs_url, type="bbs",},{name="贴吧", url=cfg.official_blog_url, type="blog",},{name="投诉", url=cfg.official_service_url, type="service",}};
	else
		TimesMagazineWeb.OfficialUrlInfo = { {name="哈奇官网", url=cfg.official_site_url, type="site",},{name="官方论坛", url=cfg.official_bbs_url, type="bbs",},{name="官方博客", url=cfg.official_blog_url, type="blog",},};
		-- TimesMagazineWeb.OfficialUrlInfo = { {name="官方博客", url=cfg.official_blog_url, type="site",},{name="官方论坛", url=cfg.official_bbs_url, type="bbs",},};
	end
end

function TimesMagazineWeb.DS_Func(index)
    if(index == nil) then
        return TimesMagazineWeb.BackGroundCount;
	elseif(index > TimesMagazineWeb.BackGroundCount) then
		
	else
	    if (ExternalUserModule:GetRegionID()==0) then
			return { background = string.format("%s%d.jpg; 184 72 680 420", TimesMagazineWeb.DataSource, index), };
		else
			return { background = string.format("%s; 184 72 680 420", TimesMagazinePage[index].filename), };
		end
    end
end
 
function TimesMagazineWeb.Confirm()

	local msg = { aries_type = "OnCloseTimeMagazine", wndName = "main"};
	CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", msg);
	
    TimesMagazineWeb.pageCtrl:CloseWindow();
end

--进入家园
function TimesMagazineWeb.OnClickHomeland(value)
    if(value) then
        TimesMagazineWeb.pageCtrl:CloseWindow();
        System.App.Commands.Call("Profile.Aries.GotoHomeLand", {nid = tonumber(TimesMagazineWeb.HomePageList[tonumber(value)])});
    end
end
--给罗德镇长写信 攻略投稿
function TimesMagazineWeb.OnWriteToRod_Combat()
    NPL.load("(gl)script/kids/3DMapSystemUI/PENote/Pages/LiteMailPage.lua");
    Map3DSystem.App.PENote.LiteMailPage.ShowPage(500);
end
--给罗德镇长写信
function TimesMagazineWeb.OnWriteToRod()
    NPL.load("(gl)script/kids/3DMapSystemUI/PENote/Pages/LiteMailPage.lua");
    Map3DSystem.App.PENote.LiteMailPage.ShowPage(1);
end

--写信告诉帕帕
function TimesMagazineWeb.OnWriteSomeSecret()
    NPL.load("(gl)script/kids/3DMapSystemUI/PENote/Pages/LiteMailPage.lua");
    Map3DSystem.App.PENote.LiteMailPage.ShowPage(2);
end

function TimesMagazineWeb.OnWriteSomeComment()
    NPL.load("(gl)script/kids/3DMapSystemUI/PENote/Pages/LiteMailPage.lua");
    Map3DSystem.App.PENote.LiteMailPage.ShowPage(100);
end

function TimesMagazineWeb.OnWrite_10_1()
	NPL.load("(gl)script/apps/Aries/Scene/main.lua");
	local Scene = commonlib.gettable("MyCompany.Aries.Scene");
	local today = Scene.GetServerDate() or ParaGlobal.GetDateFormat("yyyy-MM-dd");
	local year,month,day = string.match(today,"(.+)-(.+)-(.+)");
	year = tonumber(year);
	month = tonumber(month);
	day = tonumber(day);
	local can_pass = false;
	if(year == 2011 and month == 9 and (day == 29 or day == 30))then
		can_pass = true;
	elseif(year == 2011 and month == 10 and day >=1 and day <=7)then
		can_pass = true;
	end
	if(not can_pass)then
		_guihelper.MessageBox("调查时间已经结束！");
		return;
	end
	
	UIAnimManager.PlayCustomAnimation(10000, function(elapsedTime)
		if(elapsedTime >= 10000) then
            -- 50340_2011OctoberBusinessTag
            local hasGSItem = System.Item.ItemManager.IfOwnGSItem;
            local bHas = hasGSItem(50340);
            if(not bHas) then
                local exid = 864; -- 864 Get_Reward_2011OctoberBusiness
	            System.Item.ItemManager.ExtendedCost(exid, nil, nil, function(msg)end, function(msg) 
		            --log("+++++++ Extended cost "..exid.." return: +++++++\n")
		            --commonlib.echo(msg);
	            end);
            end
		end
	end);
	TimesMagazineWeb.OpenHttp("http://www.2125.com/survey.html");
end
function TimesMagazineWeb.OnVisitMole()
	local url="http://www.51mole.com/";
	TimesMagazineWeb.OpenHttp(url);
end 

--
function TimesMagazineWeb.OpenHttp(url)
	ParaGlobal.ShellExecute("open", url, "", "", 1);
end

function TimesMagazineWeb.IWannaParticipateMothersDay()
	local url="http://bbs.61.com/frame.php?frameon=yes&referer=http%3A//bbs.61.com/forumdisplay.php%3Ffid%3D16";
    TimesMagazineWeb.OpenHttp(url);
end

--我要参加
function TimesMagazineWeb.IWannaParticipate()
	local url="http://bbs.61.com/frame.php?frameon=yes&referer=http%3A//bbs.61.com/forumdisplay.php%3Ffid%3D16%26page%3D1%26filter%3Dtype%26typeid%3D11";
	TimesMagazineWeb.OpenHttp(url);
end

--跳转
function TimesMagazineWeb.GoTo(index)
    if(index) then
        index = tonumber(index);
        TimesMagazineWeb.pageCtrl:CallMethod(TimesMagazineWeb.GridName, "GotoPage", index);
    end
end

function TimesMagazineWeb.GetPageHead(index)
	local i,v;
	local tmp = tonumber(index);

	for i,v in pairs(TimesMagazineWeb.DataInfo) do
		if( v.startpage ~= v.endpage ) then
			if( ( ( tmp >= v.startpage ) and ( tmp <= v.endpage ) ) ~= false ) then
				return v.name .. "  A" .. index;
			end
		else
			if( tmp == v.startpage ) then
				return v.name .. "  A" .. index;
			end
		end
	end

	return "";
end

--显示目录
function TimesMagazineWeb.ShowCatalog(x,y,step)
	local s = "";
	local tmp;
	local i,v;

	for i,v in pairs(TimesMagazineWeb.DataInfo) do
		if(not v.bSkipCatalog) then
			if( v.startpage == v.endpage ) then
				tmp = string.format([[<div style="position:relative;margin-left:%dpx;margin-top:%dpx;width:256px;height:128px;background:url()">
								<a tooltip="%s  （A%d）" style="width:150px;height:24px;background:url(Texture/Aries/Books/TimesMagazineWeb/arrow_32bits.png#4 4 24 24: 22 1 1 1)" name="A2" onclick="MyCompany.Aries.Books.TimesMagazineWeb.GoTo" param1='%d'><div style="width:120px;height:24px;"/></a>
								</div>]], x, y + ( i - 1 ) * step, v.name, v.startpage, v.startpage );
			else
				tmp = string.format([[<div style="position:relative;margin-left:%dpx;margin-top:%dpx;width:256px;height:128px;background:url()">
								<a tooltip="%s  （A%d-A%d）" style="width:150px;height:24px;background:url(Texture/Aries/Books/TimesMagazineWeb/arrow_32bits.png#4 4 24 24: 22 1 1 1)" name="A2" onclick="MyCompany.Aries.Books.TimesMagazineWeb.GoTo" param1='%d'><div style="width:120px;height:24px;"/></a>
								</div>]], x, y + ( i - 1 ) * step, v.name, v.startpage, v.endpage, v.startpage );
			end

			s = s .. tmp;
		end
	end

	return s;
end

function TimesMagazineWeb.OnClickCatalog2(index)
	index = tonumber(index);
	local data = TimesMagazineWeb.DataInfo[index];
	TimesMagazineWeb.GoTo(data.startpage);
end

function TimesMagazineWeb.ShowCatalog2(x,y)
	local s = "";
	local tmp;
	local i,v;

	for i,v in pairs(TimesMagazineWeb.DataInfo) do
		if(not v.bSkipCatalog) then
			if( v.startpage == v.endpage ) then
				tmp = string.format([[<div style="position:relative;margin-left:%dpx;margin-top:%dpx;"><input type="button" name="%d" value="%s" 
									tooltip="%s  （A%d）" onclick="MyCompany.Aries.Books.TimesMagazineWeb.OnClickCatalog2()" 
									zorder="2" style="width:97px;height:23px;
									background:url(Texture/Aries/Books/TimesMagazineWeb/anniubg_32bits.png# 0 0 97 23);"/></div>]], 
									x + ( i - 1 ) * 100, y, i, v.name, v.name, v.startpage );
			else
				tmp = string.format([[<div style="position:relative;margin-left:%dpx;margin-top:%dpx;"><input type="button" name="%d" value="%s" 
									tooltip="%s  （A%d-A%d）" onclick="MyCompany.Aries.Books.TimesMagazineWeb.OnClickCatalog2()" 
									zorder="2" style="width:97px;height:23px;
									background:url(Texture/Aries/Books/TimesMagazineWeb/anniubg_32bits.png# 0 0 97 23);"/></div>]], 
									x + ( i - 1 ) * 100, y, i, v.name, v.name, v.startpage, v.endpage );
			end

			s = s .. tmp;
		end
	end

	return s;
end

function TimesMagazineWeb.OpenOfficialBBS()
	local url;
	for i,v in pairs(TimesMagazineWeb.OfficialUrlInfo) do		
		if (string.lower(v.type)=="bbs") then
			url = v.url;
			break;
		end
	end
	TimesMagazineWeb.OpenHttp(url);
end

function TimesMagazineWeb.OpenOfficialSite()
	local url;
	for i,v in pairs(TimesMagazineWeb.OfficialUrlInfo) do		
		if (string.lower(v.type)=="site") then
			url = v.url;
			break;
		end
	end
	TimesMagazineWeb.OpenHttp(url);
end

function TimesMagazineWeb.OpenOfficialBlog()
	local url;
	for i,v in pairs(TimesMagazineWeb.OfficialUrlInfo) do		
		if (string.lower(v.type)=="blog") then
			url = v.url;
			break;
		end
	end
	TimesMagazineWeb.OpenHttp(url);
end

function TimesMagazineWeb.OpenOfficialService()
	local url;
	for i,v in pairs(TimesMagazineWeb.OfficialUrlInfo) do		
		if (string.lower(v.type)=="service") then
			url = v.url;
			break;
		end
	end
	if(url) then
		paraworld.auth.AuthUser({
					username = System.User.username,
					password = System.User.Password,
					}, "login", function (msg)
					if(msg.issuccess) then	
						-- successfully recovered from connection. 
						LOG.std("", "system","Login", "Successfully authenticated for service");
						local service_url = string.format("%s?uid=%d&gameid=21&session=%s",url,msg.nid,msg.sessionid);
						ParaGlobal.ShellExecute("open", service_url, "", "", 1);
						--local url2=string.format("%s?gid=3",url);
						--ParaGlobal.ShellExecute("open", url2, "", "", 1);
					end
				end, nil, 20000, function(msg)	end);	
	else
		ParaGlobal.ShellExecute("open", "iexplore.exe", MyCompany.Aries.ExternalUserModule:GetConfig().official_service_url, "", 1);
	end
end

function TimesMagazineWeb.ShowOfficialUrl(x,y, filename, width, height )
	local s = "";
	local tmp;
	local i,v;
	local btn_width = 60;
	local btn_height = 23;
	for i,v in pairs(TimesMagazineWeb.OfficialUrlInfo) do		
		if (string.lower(v.type)=="site") then
			tmp = string.format([[<div style="position:relative;margin-left:%dpx;margin-top:%dpx;">
								<input type="button" name="%d" value="%s" 
									tooltip="%s" onclick="MyCompany.Aries.Books.TimesMagazineWeb.OpenOfficialSite" 
									zorder="2" style="width:%dpx;height:%dpx;
									background:url(%s# 0 0 %d %d );"/></div>]], 
									x + ( i - 1 ) * (btn_width+3), y, 
									i, v.name, 
									v.name, 
									btn_width, btn_height,
									filename, width, height );
		elseif (string.lower(v.type)=="bbs")  then
			tmp = string.format([[<div style="position:relative;margin-left:%dpx;margin-top:%dpx;">
								<input type="button" name="%d" value="%s" 
									tooltip="%s" onclick="MyCompany.Aries.Books.TimesMagazineWeb.OpenOfficialBBS" 
									zorder="2" style="width:%dpx;height:%dpx;
									background:url(%s# 0 0 %d %d );"/></div>]], 
									x + ( i - 1 ) * (btn_width+3), y, 
									i, v.name, 
									v.name, 
									btn_width, btn_height,
									filename, width, height );
		elseif (string.lower(v.type)=="blog")  then
			tmp = string.format([[<div style="position:relative;margin-left:%dpx;margin-top:%dpx;">
								<input type="button" name="%d" value="%s" 
									tooltip="%s" onclick="MyCompany.Aries.Books.TimesMagazineWeb.OpenOfficialBlog" 
									zorder="2" style="width:%dpx;height:%dpx;
									background:url(%s# 0 0 %d %d );"/></div>]], 
									x + ( i - 1 ) * (btn_width+3), y, 
									i, v.name, 
									v.name, 
									btn_width, btn_height,
									filename, width, height );
		elseif (string.lower(v.type)=="service")  then
			tmp = string.format([[<div style="position:relative;margin-left:%dpx;margin-top:%dpx;">
								<input type="button" name="%d" value="%s" 
									tooltip="%s" onclick="MyCompany.Aries.Books.TimesMagazineWeb.OpenOfficialService" 
									zorder="2" style="width:%dpx;height:%dpx;
									background:url(%s# 0 0 %d %d );"/></div>]], 
									x + ( i - 1 ) * (btn_width+3), y, 
									i, v.name, 
									v.name, 
									btn_width, btn_height,
									filename, width, height );
		end
		s = s .. tmp;
	end
	--commonlib.echo("official_url="..s);
	return s;
end

function TimesMagazineWeb.ShowCatalogEx(x,y, filename, width, height )
	local s = "";
	local tmp;
	local i,v;

	for i,v in pairs(TimesMagazineWeb.DataInfo) do
		if(not v.bSkipCatalog) then
			if( v.startpage == v.endpage ) then
				tmp = string.format([[<div style="position:relative;margin-left:%dpx;margin-top:%dpx;">
									<input type="button" name="%d" value="%s" 
									tooltip="%s  （A%d）" onclick="MyCompany.Aries.Books.TimesMagazineWeb.OnClickCatalog2()" 
									zorder="2" style="width:%dpx;height:%dpx;
									background:url(%s# 0 0 %d %d );"/></div>]], 
									x + ( i - 1 ) * (width+3), y, 
									i, v.name, 
									v.name, v.startpage,
									width, height,
									filename, width, height );
			else
				tmp = string.format([[<div style="position:relative;margin-left:%dpx;margin-top:%dpx;">
									<input type="button" name="%d" value="%s" 
									tooltip="%s  （A%d-A%d）" onclick="MyCompany.Aries.Books.TimesMagazineWeb.OnClickCatalog2()" 
									zorder="2" style="width:%dpx;height:%dpx;
									background:url(%s# 0 0 %d %d);"/></div>]], 
									x + ( i - 1 ) * (width+3), y, 
									i, v.name, 
									v.name, v.startpage, v.endpage,
									width, height,
									filename, width, height );
			end

			s = s .. tmp;
		end
	end

	return s;
end

--显示家园列表
function TimesMagazineWeb.ShowHomePageList(x,y)

	local s = string.format([[<div style="float:right;margin-left:%dpx;margin-top:%dpx;">]], x, y );
	local tmp;
	local i,v;

	for i,v in pairs(TimesMagazineWeb.HomePageList) do
		tmp = string.format([[<input type="button" zorder="1" 
								style="margin-left:0px;margin-top:%dpx;width:80px;height:20px;
								background:url(Texture/Aries/Books/TimesMagazineWeb/gohome_32bits.png#0 0 80 20)" 
								onclick="MyCompany.Aries.Books.TimesMagazineWeb.OnClickHomeland()" 
								name='%d'/><br/>]], ( i - 1 ) * -2, i  );
		s = s .. tmp;
	end

	s = s .. [[</div>]] 
	return s;
end

function TimesMagazineWeb.LoadVoteTemplate()
	local self = TimesMagazineWeb;
	local file_path = "config/Aries/Vote/vote.xml";
	if(self.vote_template)then
		return self.vote_template;
	end
	self.vote_template = {};
	local xmlRoot = ParaXML.LuaXML_ParseFile(file_path);
	local node;
	for node in commonlib.XPath.eachNode(xmlRoot, "//votes/vote") do
		local version = node.attr.version;
		local title = node.attr.title;
		local comment = node.attr.comment;
		local choice = tonumber(node.attr.choice) or 1;

		local multi_checked = node.attr.multi_checked or "";
		if(multi_checked == "true" or multi_checked == "True" )then
			multi_checked = true;
		else
			multi_checked = false;
		end
		if(version and version ~= "")then
			local vote = {};
			self.vote_template[version] = vote;			
			vote["version"] = version;
			vote["title"] = title;
			vote["choice"] = choice;
			vote["comment"] = comment;
			local option_node;
			for option_node in commonlib.XPath.eachNode(node, "/option") do
				local label = option_node.attr.label;
				table.insert(vote,{label = label});
			end
		end
	end
	return self.vote_template;
end

function TimesMagazineWeb.LoadVote()
	local self = TimesMagazineWeb;
	local file_path = "config/Aries/Vote/vote.config.xml";
	if(self.votes_all)then
		return self.votes_all;
	end
	self.votes_all = {};
	local xmlRoot = ParaXML.LuaXML_ParseFile(file_path);
	local node;
	for node in commonlib.XPath.eachNode(xmlRoot, "//votes/vote") do
		local vote_ver = node.attr.vote_ver;
		local title = node.attr.title;
		local deadline = node.attr.deadline;
		local comment = node.attr.comment;
		local ver = node.attr.ver; -- 0:all, 1:kids, 2:teen
		local datafile = node.attr.datasource;		

		local voteconf = {};
		local vote = {};
		if (ver==System.options.version) then
			self.votes_all[vote_ver] = voteconf;			
			voteconf["votever"] = vote_ver;
			voteconf["title"] = title;
			voteconf["deadline"] = deadline;
			voteconf["comment"] = comment;
			if (datafile) then
				vote = self.VoteDataLoad(datafile);
			end
			voteconf["data"]= vote;	
		end
		--commonlib.echo("==============voteconf")
		--commonlib.echo(datafile)
		--commonlib.echo(voteconf)
		--commonlib.echo(vote)
	end
	return self.votes_all;
end
-- load all vote data from csv file
function TimesMagazineWeb.VoteDataLoad(file_path)
	local self = TimesMagazineWeb;
	local votes_list = {};

	local function get_arr(s,splitter)
		if(not s)then return end
		if (string.match(s,"^#.*")) then return end

		local list = {};
		local line;
		local sformat=string.format("([^%s]+)",splitter);
		for line in string.gfind(s, sformat) do
			table.insert(list,line);
		end
		return list;
	end

	local line;
	local file = ParaIO.open(file_path, "r");
	if(file:IsValid()) then
		line=file:readline();		
		while line~=nil do 
			local arr = get_arr(line,"%s");			
			if(arr)then
				local __ask = arr[1];
				local __type = tonumber(arr[2]);
				local __s = string.gsub(arr[3],"\"","");
				local __choices = get_arr(__s,",");
				local __ver= tonumber(arr[4]);
				if (__ver==0 or (__ver==1 and System.options.version=="kids") or (__ver==2 and System.options.version=="teen")) then
					if(__ask and __type and __choices and __ver)then
						local node = {
							askitem = __ask,
							asktype = __type,
							askchoice = __choices,
							askver = __ver,
						}
						table.insert(votes_list,node);
					end
				end
			end
			line=file:readline();
		end
		file:close();
	end	
	return votes_list;
end


function TimesMagazineWeb.btnName(id,stype,v,vote_list)
    local _v;
    if (stype=="radio" or stype=="check") then
        _v = id;
    else
        _v  = string.format("%s_%d",stype,id);
    end
	--commonlib.echo("===============btnName")
	--commonlib.echo(vote_list)
	--commonlib.echo(id)
	--commonlib.echo(_v)
	--commonlib.echo(stype)
	--commonlib.echo(v)
	local node={};
    local _RadioId = tonumber(string.match(_v,"radio_(%d+)"));
    local _CheckId = tonumber(string.match(_v,"check_(%d+)"));
    local _SelectId = tonumber(string.match(_v,"select_(%d+)"));
    local _TextId = tonumber(string.match(_v,"text_(%d+)"));
    local _label;

	--commonlib.echo(_RadioId)
	--commonlib.echo(_CheckId)
	--commonlib.echo(_SelectId)
	--commonlib.echo(_TextId)

    if (_RadioId) then
        _label=vote_list[_RadioId].askitem;
    elseif (_CheckId) then
        _label=vote_list[_CheckId].askitem;
    elseif (_SelectId) then
        _label=vote_list[_SelectId].askitem;
    elseif (_TextId) then
        _label=vote_list[_TextId].askitem;
    end    
    node={name=_v,checked=false,label=_label,vote= v or ""};
	
	--commonlib.echo(node)
	return node;
end

function TimesMagazineWeb.GetVotePage(_vpage)	
	TimesMagazineWeb.votepage=_vpage;
end

function TimesMagazineWeb.CloseVotePage()	
	
	if (TimesMagazineWeb.votepage)then
		TimesMagazineWeb.votepage:CloseWindow();
	end
end