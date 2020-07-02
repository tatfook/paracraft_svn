--[[
Title: 
Author(s): 
Date: 2012/11/21
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Gift/ExcitingActivityPage.lua");
local ExcitingActivityPage = commonlib.gettable("MyCompany.Aries.Gift.ExcitingActivityPage");
ExcitingActivityPage.ShowPage();
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;
local ExcitingActivityPage = commonlib.gettable("MyCompany.Aries.Gift.ExcitingActivityPage");

function ExcitingActivityPage.OnInit()
	ExcitingActivityPage.page = document:GetPageCtrl();
end

function ExcitingActivityPage.RefreshPage()
	if(ExcitingActivityPage.page)then
		ExcitingActivityPage.page:Refresh(0);
	end
end

function ExcitingActivityPage.GetItemsCnt()
	if(ExcitingActivityPage.gifts)then
		return #ExcitingActivityPage.gifts;
	end
	return 0;
end

function ExcitingActivityPage.Load(callbackFunc)
	paraworld.users.GetOperations({},"GetOperations",function(msg)
		if(msg)then
			ExcitingActivityPage.gifts = msg;
			if(callbackFunc)then
				callbackFunc()
			end
		end
	end)
end

function ExcitingActivityPage.RechargeActLoad(callbackFunc)
	paraworld.WorldServers.GetActRecharges({},"GetActRecharges",function(msg)
		if(msg)then
			ExcitingActivityPage.RechargesGifts = msg;
			if(callbackFunc)then
				callbackFunc()
			end
		end
	end)
end

function ExcitingActivityPage.ShowPage(index,UpdateDocVer)
	index = index or 1;
	ExcitingActivityPage.gifts = nil;
	ExcitingActivityPage.RechargesGifts = nil;

	ExcitingActivityPage.NPCactLoad();

	ExcitingActivityPage.RechargeActLoad(function()
		local k,v;
		for k,v in ipairs(ExcitingActivityPage.RechargesGifts) do
			local arr = commonlib.split(v.desc,"|");
			local type = arr[1];
			local d_title,d_time,d_name,d_desc;
			if(type)then
				d_time,d_title = string.match(type,"%[(.+)%](.+)");
				if(d_time)then
					local arr_time = commonlib.split(d_time,"-");
					local start_time = arr_time[1];
					local end_time = arr_time[2];
					if(start_time and end_time)then
						local start_year,start_month,start_day = string.match(start_time,"(%d%d%d%d)(%d%d)(%d%d)");
						local end_year,end_month,end_day = string.match(end_time,"(%d%d%d%d)(%d%d)(%d%d)");
						d_time = string.format("%s年%s月%s日-%s年%s月%s日",start_year,start_month,start_day,end_year,end_month,end_day);
					end
				end
			end
			d_name =  arr[2];    
			d_desc =  arr[3];  
			v.d_title = d_title;
			v.d_time = d_time;
			v.d_name = d_name;
			v.d_desc = d_desc;
			v.d_isUpdateDoc = 0;
			v.d_recharge = 1;
			if (v.single_rewards~="") then
				v.sum_rewards = v.single_rewards;
			end 
		end
	end
	);

	ExcitingActivityPage.Load(function()
		--if(ExcitingActivityPage.GetItemsCnt() == 0)then
			--_guihelper.MessageBox("目前没有精彩活动！");
			--return
		--end
		local params = {
			url = "script/apps/Aries/Gift/ExcitingActivityPage.teen.html", 
			name = "ExcitingActivityPage.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			enable_esc_key = true,
			style = CommonCtrl.WindowFrame.ContainerStyle,
			allowDrag = true,
			-- zorder = 0,
			directPosition = true,
				align = "_ct",
				x = -650/2,
				y = -400/2,
				width = 650,
				height = 400,
		}
		System.App.Commands.Call("File.MCMLWindowFrame", params);	
		local k,v;
		for k,v in ipairs(ExcitingActivityPage.gifts) do
			local arr = commonlib.split(v.desc,"|");
			local type = arr[1];
			local d_title,d_time,d_name,d_desc;
			if(type)then
				d_time,d_title = string.match(type,"%[(.+)%](.+)");
				if(d_time)then
					local arr_time = commonlib.split(d_time,"-");
					local start_time = arr_time[1];
					local end_time = arr_time[2];
					if(start_time and end_time)then
						local start_year,start_month,start_day = string.match(start_time,"(%d%d%d%d)(%d%d)(%d%d)");
						local end_year,end_month,end_day = string.match(end_time,"(%d%d%d%d)(%d%d)(%d%d)");
						d_time = string.format("%s年%s月%s日-%s年%s月%s日",start_year,start_month,start_day,end_year,end_month,end_day);
					end
				end
			end
			d_name =  arr[2];    
			d_desc =  arr[3];  
			v.d_title = d_title;
			v.d_time = d_time;
			v.d_name = d_name;
			v.d_desc = d_desc;
			v.d_isUpdateDoc = 0;			
		end

		if (ExcitingActivityPage.RechargesGifts) then
			for k,v in ipairs(ExcitingActivityPage.RechargesGifts) do
				table.insert(ExcitingActivityPage.gifts,v);
			end
		end

		NPL.load("(gl)script/apps/Aries/Gift/ExtraGiftPage.lua");
		local ExtraGiftPage = commonlib.gettable("MyCompany.Aries.Gift.ExtraGiftPage");
		local _id, _node;
		for _id, _node in ipairs(ExtraGiftPage.GetGifts()) do		
			if(_node.show_func) then							
				local _table = {
					d_title = _node.label,
					d_func = 1,
					d_findex = _id
					}
				--commonlib.echo("============ ExtraGiftPage.GetGif")
				--commonlib.echo(_table)
				table.insert(ExcitingActivityPage.gifts,_table);
			else	
				local _exid_gifts = nil;

				local exid = _node.exid;
				local check_gsid = _node.check_gsid;
				if (check_gsid) then
					if (not hasGSItem(check_gsid)) then
						local exTemplate = ItemManager.GetExtendedCostTemplateInMemory(exid);
						local tos = exTemplate.tos or {};
						local k,v;
						local _result = "";
						for k,v in ipairs(tos) do
							local gsid = v.key;
							if(check_gsid and check_gsid ~= gsid)then
								if (_result == "") then
									_result = string.format("%d,%d",gsid,v.value);
								else
									_result = string.format("%s;%d,%d",_result,gsid,v.value);
								end
							end
						end

						if (_result ~= "") then
							local _table = {
								d_title = _node.label, 								
								d_name = _node.label, 
								d_isUpdateDoc = 0,
								d_exname = _node.name,
								d_exid = exid,
								sum_rewards = _result,
							};
							table.insert(ExcitingActivityPage.gifts,_table);
						end
					end
				end
			end
		end		

		if (ExcitingActivityPage.NPCact) then
			for k,v in ipairs(ExcitingActivityPage.NPCact) do
				table.insert(ExcitingActivityPage.gifts,v);
			end
		end
		--commonlib.echo("============ExcitingActivityPage.NPCact")
		--commonlib.echo(ExcitingActivityPage.NPCact)

		NPL.load("(gl)script/apps/Aries/Desktop/HelpMainList.teen.lua");
		local HelpMainList = commonlib.gettable("MyCompany.Aries.Desktop.HelpMainList");
		HelpMainList.FindDataSource("TimeMag",UpdateDocVer);
		local detailurl = HelpMainList.detailurl;
		local _table = {d_title = "更新公告", d_url = detailurl, d_isUpdateDoc = 1};
		table.insert(ExcitingActivityPage.gifts,1,_table);

		local _index = index;
		if (UpdateDocVer) then
			_index = 1;
		end

		ExcitingActivityPage.DoSelected(_index);
	end)
end

function ExcitingActivityPage.GetSelectedNode()
	if(ExcitingActivityPage.selected_index and ExcitingActivityPage.gifts)then
		return ExcitingActivityPage.gifts[ExcitingActivityPage.selected_index];
	end
end

function ExcitingActivityPage.DoSelected(index)
	ExcitingActivityPage.selected_index = index or 1;
	if (ExcitingActivityPage.gifts[ExcitingActivityPage.selected_index].d_func) then		
		local _index = ExcitingActivityPage.gifts[ExcitingActivityPage.selected_index].d_findex;
		local ExtraGiftPage = commonlib.gettable("MyCompany.Aries.Gift.ExtraGiftPage");
		local _nodes = ExtraGiftPage.GetGifts();
		local node = _nodes[_index];
		ExcitingActivityPage.selected_index = #(ExcitingActivityPage.gifts);
		node.show_func();
	else
		ExcitingActivityPage.RefreshPage();
	end
end

function ExcitingActivityPage.DS_Func_gifts(index)
	if(not ExcitingActivityPage.gifts)then return 0 end
	if(index == nil) then
		return #(ExcitingActivityPage.gifts);
	else
		return ExcitingActivityPage.gifts[index];
	end
end

function ExcitingActivityPage.DoOpen()
	local node = ExcitingActivityPage.GetSelectedNode();
	if(node)then
		if (node.d_exname) then
			return
		else
			paraworld.users.ExecOperation({id = node.id},"ExecOperation",function(msg)
				if(msg.issuccess)then
					node.temp_opened = true;
					ExcitingActivityPage.RefreshPage()
				end
			end)
		end
	end
end

function ExcitingActivityPage.NPCactLoad()
	if (ExcitingActivityPage.NPCact) then
		return
	end

    local bean = MyCompany.Aries.Pet.GetBean();
	local myCombatlel = bean.combatlel;
	local ThisDate = tonumber(ParaGlobal.GetDateFormat("yyyyMMdd"));

	local config_file="config/Aries/others/exciteact.teen.xml";
	
	local xmlRoot = ParaXML.LuaXML_ParseFile(config_file);
	if(not xmlRoot) then
		commonlib.log("warning: failed loading exciteact config file: %s\n", config_file);
		return;
	end
		
	local xmlnode = "/act/item";
	
	local _item = nil;
	ExcitingActivityPage.NPCact = {}
	for _item in commonlib.XPath.eachNode(xmlRoot, xmlnode) do	
		local _sub = {};
		_sub.d_title = _item.attr.name;
		_sub.d_name = _item.attr.name;
		_sub.d_isUpdateDoc = 0;
		_sub.d_exname = "npcact";
		_sub.d_desc = _item.attr.desc;

		_sub.actdate = _item.attr.actdate;
		_sub.combatlvl = _item.attr.combatlvl;
		_sub.period = _item.attr.period;

		_sub.rewards = commonlib.LoadTableFromString(_item.attr.reward) or {};
		_sub.npcid = tonumber(_item.attr.npcid);
		_sub.keywords= _item.attr.keywords;
		if (_sub.actdate) then
			local _bgndate, _enddate = string.match(_sub.actdate,"(%d+),(%d+)");
			if (_bgndate and _enddate) then
				local start_year,start_month,start_day = string.match(_bgndate,"(%d%d%d%d)(%d%d)(%d%d)");
				local end_year,end_month,end_day = string.match(_enddate,"(%d%d%d%d)(%d%d)(%d%d)");
				_bgndate = tonumber(_bgndate);
				_enddate = tonumber(_enddate);

				if (_sub.combatlvl == "-1" and (ThisDate >=_bgndate and ThisDate <=_enddate)) then
					
					_sub.d_time = string.format("%d年%d月%d日-%d年%d月%d日 %s",start_year,start_month,start_day,end_year,end_month,end_day,_sub.period);
					table.insert(ExcitingActivityPage.NPCact,_sub);
				else
					local _minlvl, _maxlvl = string.match(_sub.combatlvl,"(%d+),(%d+)");
					if (_minlvl and _maxlvl) then
						_minlvl = tonumber(_minlvl);
						_maxlvl = tonumber(_maxlvl);
						if ((myCombatlel >= _minlvl and myCombatlel <= _maxlvl) and (ThisDate >=_bgndate and ThisDate <=_enddate)) then
							_sub.d_time = string.format("%d年%d月%d日-%d年%d月%d日 %s",start_year,start_month,start_day,end_year,end_month,end_day,_sub.period);
							table.insert(ExcitingActivityPage.NPCact,_sub);
						end
					end
				end
			end
		end
	end
end