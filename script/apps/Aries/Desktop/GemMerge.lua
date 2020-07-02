--[[
Title: 
Author(s): zrf
Date: 2010/12/6
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Desktop/GemMerge.lua");
MyCompany.Aries.Desktop.GemMerge.ShowMainWnd();
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/DealDefend/DealDefend.lua");
local DealDefend = commonlib.gettable("MyCompany.Aries.DealDefend.DealDefend");
local Dock = commonlib.gettable("MyCompany.Aries.Desktop.Dock");
local GemMerge = commonlib.gettable("MyCompany.Aries.Desktop.GemMerge");
GemMerge.curpage = GemMerge.curpage or 1;
GemMerge.select = GemMerge.select or 1;

local ItemManager = Map3DSystem.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;

function GemMerge.ShowMainWnd()
	if(not DealDefend.CanPass())then
		return
	end
	local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);
	GemMerge.LoadGems();
    System.App.Commands.Call("File.MCMLWindowFrame", {
        url = "script/apps/Aries/Desktop/GemMerge.html", 
        app_key = MyCompany.Aries.app.app_key, 
        name = "GemMerge.ShowMainWnd", 
        isShowTitleBar = false,
        DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
        style = style,
        zorder = 2,
        allowDrag = false,
		directPosition = true,
            align = "_ct",
            x = -800/2,
            y = -510/2,
            width = 800,
            height = 510,
    });
end

function GemMerge.LoadGems()
	local i;
	GemMerge.gems = {};
	for i=26001,26699 do
		local gsitem = ItemManager.GetGlobalStoreItemInMemory(i);
		if(gsitem)then
			--commonlib.echo("!!!!!!!!!!!!!!:LoadGems");
			--commonlib.echo(gsitem);
			local lvl = tonumber(gsitem.template.stats[41]);
			--commonlib.echo(lvl);
			if( lvl > 1)then

				if( GemMerge.gems[lvl] == nil )then
					GemMerge.gems[lvl] = {};
				end

				local tmp ={};
				tmp.gsid = i;
				tmp.name = gsitem.template.name;
				tmp.displayname = tmp.name;
				tmp.icon = gsitem.icon;

				if(lvl == 2)then
					tmp.mergeprice = 100;
				elseif(lvl == 3)then
					tmp.mergeprice = 200;

				elseif(lvl == 4)then
					tmp.mergeprice = 300;

				elseif(lvl == 5)then
					tmp.mergeprice = 400;

				end

				--commonlib.echo("!!!!!!!!!!!!!!!:LoadGems0");
				--commonlib.echo(tmp.icon);
				local gsitem2 = ItemManager.GetGlobalStoreItemInMemory(gsitem.gsid-1);
				tmp.materialgsid = gsitem.gsid-1;
				if(gsitem2)then
					tmp.materialname = gsitem2.template.name;				
				else
					tmp.materialname = "";
				end
				local bhas, _, __, copies = hasGSItem(gsitem.gsid-1);
				if(bhas)then
					tmp.displayname = tmp.name .. string.format([[(拥有%d枚%s)]],copies,tmp.materialname);
				end

				table.insert( GemMerge.gems[lvl], tmp );

			end
		else
			break;
		end
	end
end

function GemMerge.Init()
	GemMerge.pagectrl = document:GetPageCtrl();

	local tmp = tostring(GemMerge.curpage);
	--commonlib.echo("!!!!!!!!!!!!!!:Init");
	--commonlib.echo(tmp);
	--commonlib.echo(GemMerge.pagectrl:GetValue("gemmergetab"));
	if(GemMerge.pagectrl:GetValue("gemmergetab") ~= tmp)then
		GemMerge.pagectrl:SetValue("gemmergetab", tmp);
		GemMerge.pagectrl:Refresh(0.01);
	end
end

function GemMerge.OnClickRadio(value)
	GemMerge.curpage = tonumber(value);
	GemMerge.select = 1;
	GemMerge.pagectrl:Refresh(0.01);
end

function GemMerge.DS_Func(index)
	--commonlib.echo("!!!!!!!!!!!!:DS_Func");
	--commonlib.echo(GemMerge.curpage);
	local gems = GemMerge.gems[GemMerge.curpage+1];
	if( index == nil)then
		return #gems;
	else
		--index = tonumber(index);
		return gems[index];
	end
end

function GemMerge.OnClickGem(index)
	index = tonumber(index);
	GemMerge.select = index;
	GemMerge.pagectrl:Refresh(0.01);
end	

function GemMerge.GetMergeDest()
	local tmp = GemMerge.gems[GemMerge.curpage+1][GemMerge.select];
	return tmp.name;
end

function GemMerge.GetMergeMaterial()
	local tmp = GemMerge.gems[GemMerge.curpage+1][GemMerge.select];
	return tmp.materialname;
end

function GemMerge.GetMergePrice()
	local tmp = GemMerge.gems[GemMerge.curpage+1][GemMerge.select];
	return tmp.mergeprice .. "奇豆";
end

function GemMerge.GetIcon()
	local tmp = GemMerge.gems[GemMerge.curpage+1][GemMerge.select];
	return tmp.icon;
end

function GemMerge.GetSmallIcon(index)
	index = tonumber(index);
	local tmp = GemMerge.gems[GemMerge.curpage+1][index];
	return tmp.icon;
end

function GemMerge.OnClickMerge(num)
	num = tonumber(num);
	local gem = GemMerge.gems[GemMerge.curpage+1][GemMerge.select];
	local bHas, guid, _, copies = hasGSItem(gem.materialgsid);
	--commonlib.echo("!!!!!!!!!!!!!:OnClickMerge0");
	--commonlib.echo(gem);
	--commonlib.echo(bHas);
	--commonlib.echo(guid);
	--commonlib.echo(copies);
	local money = MyCompany.Aries.Player.GetMyJoybeanCount();
	if(true)then
	--if(money>=gem.mergeprice)then
			--commonlib.echo("!!!!!!!!!!!!!:OnClickMerge1");

		if(not bHas or copies < num)then
			_guihelper.Custom_MessageBox("你的宝石不够，不能用这个配方合成哦！",function(result)
					if(msg ~= _guihelper.DialogResult.Yes)then
						NPL.load("(gl)script/apps/Aries/HaqiShop/HaqiShop.lua");
						MyCompany.Aries.HaqiShop.ShowMainWnd("tabGems");
					end
				
				end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49",no="Texture/Aries/Common/get_gem_32bits.png; 0 0 153 49"});		
		else

			if(num<5)then
				local prob;
				if(num==2)then
					prob = 15;
				elseif(num==3)then
					prob = 35;
				elseif(num==4)then
					prob = 60;
				end
				_guihelper.Custom_MessageBox("你选择的配方成功率是".. prob .."%，合成失败所有材料都会消失哦，你确认要用这个配方开始合成吗？",function(result)
					if(result == _guihelper.DialogResult.Yes)then
						ItemManager.CraftGem( {[guid]=num, }, gem.gsid, function(msg)
	--commonlib.echo("!!!!!!!!!!!!!:OnClickMerge1");
							--commonlib.echo(gem.mergeprice);
							if(not(msg and msg.issuccess)) then
								_guihelper.Custom_MessageBox("合成失败,不满足合成条件！",function(result)
									end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});		
							elseif(msg and msg.errorcode==0)then
								--MyCompany.Aries.Player.AddMoney(-gem.mergeprice, function(msg)
									GemMerge.CalcGemsCopies(num);
									if(GemMerge.pagectrl)then
										GemMerge.pagectrl:Refresh(0.01);
									end

									GemMerge.ShowNotify(gem.gsid);

									_guihelper.Custom_MessageBox("恭喜恭喜，你成功合成了 " .. gem.name .. "！",function(result)
										end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});		
								
								--end, true);		
							elseif(msg and msg.errorcode~=0)then	
								GemMerge.CalcGemsCopies(num);
								--MyCompany.Aries.Player.AddMoney(-gem.mergeprice, function(msg)
									if(GemMerge.pagectrl)then
										GemMerge.pagectrl:Refresh(0.01);
									end
									_guihelper.Custom_MessageBox("非常遗憾,宝石合成失败了！",function(result)
										end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});		
								--end, true);									
							end
						end, function(msg)  end, function(msg)end);	
					else

					end
				end,_guihelper.MessageBoxButtons.YesNo);			
			else
				ItemManager.CraftGem( {[guid]=num, }, gem.gsid, function(msg)
	--commonlib.echo("!!!!!!!!!!!!!:OnClickMerge2");
							--commonlib.echo(gem.mergeprice);
					if(not(msg and msg.issuccess)) then
						_guihelper.Custom_MessageBox("合成失败,不满足合成条件！",function(result)
							end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});		
					elseif(msg and msg.errorcode==0)then
						--MyCompany.Aries.Player.AddMoney(-gem.mergeprice, function(msg)
						GemMerge.CalcGemsCopies(num);
						if(GemMerge.pagectrl)then
							GemMerge.pagectrl:Refresh(0.01);
						end
						GemMerge.ShowNotify(gem.gsid);

						_guihelper.Custom_MessageBox("恭喜恭喜，你成功合成了 " .. gem.name .. "！",function(result)
							end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});		
						--end, true);	
					elseif(msg and msg.errorcode~=0)then	
						GemMerge.CalcGemsCopies(num);	
						--MyCompany.Aries.Player.AddMoney(-gem.mergeprice, function(msg)
						if(GemMerge.pagectrl)then
							GemMerge.pagectrl:Refresh(0.01);
						end
						_guihelper.Custom_MessageBox("非常遗憾,宝石合成失败了！",function(result)
							end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});		
						--end, true);									
					end
				end, function(msg)end, function(msg)end);	
			end
		end
	else
		_guihelper.Custom_MessageBox("你的奇豆不够，不能用这个配方合成哦！",function(result)
			end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});		

	end
end

function GemMerge.ShowSelect(index)
	index= tonumber(index);
	if(GemMerge.select == index)then
		return true;
	else
		return false;
	end
end

function GemMerge.GetMaterialCount()
	local gem = GemMerge.gems[GemMerge.curpage+1][GemMerge.select];
	local bhas, _, __, copies = hasGSItem(gem.materialgsid);
	if(bhas)then
		return copies;
	else
		return 0;
	end
end

function GemMerge.GetEffect()
	local gem = GemMerge.gems[GemMerge.curpage+1][GemMerge.select];
	local gsitem = ItemManager.GetGlobalStoreItemInMemory(gem.gsid);
	if(gsitem)then
		local i;
		for i =101,126 do
			local val = gsitem.template.stats[i] or 0;
			if(val > 0)then
				return MyCompany.Aries.Combat.GetStatWord_OfTypeValue(i,val);
			end
		end
		for i = 182,183 do
			local val = gsitem.template.stats[i] or 0;
			if(val > 0)then
				return MyCompany.Aries.Combat.GetStatWord_OfTypeValue(i,val);
			end
		end
	end
	return "无";
end

function GemMerge.ShowNotify(gsid)
	local notification_msg = {};
	notification_msg.adds = {};
	notification_msg.updates = {};
	notification_msg.stats = {};
	table.insert(notification_msg.adds, {gsid = gsid, cnt = 1});
	Dock.OnExtendedCostNotification(notification_msg);
end

function GemMerge.CalcGemsCopies(costCount)
	local gem = GemMerge.gems[GemMerge.curpage+1][GemMerge.select];

	local _, _, __, copies = hasGSItem(gem.materialgsid);
	copies = (copies or 0) - costCount;
	if(copies > 0)then
		gem.displayname = gem.name .. string.format([[(拥有%d枚%s)]],copies,gem.materialname);
	else
		gem.displayname = gem.name;
	end
end
