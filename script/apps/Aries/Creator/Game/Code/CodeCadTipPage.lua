--[[
Title: help to code by giving examples
Author(s): leio
Date: 2020/7/16
Desc: 
use the lib:
-------------------------------------------------------
local CodeCadTipPage = NPL.load("(gl)script/apps/Aries/Creator/Game/Code/CodeCadTipPage.lua");
CodeCadTipPage:Show();
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/XPath.lua");
local XPath = commonlib.XPath;
local CodeCadTipPage = NPL.export();

CodeCadTipPage.name = "CodeCadTipPage_instance";
CodeCadTipPage.mcml_url = "script/apps/Aries/Creator/Game/Code/CodeCadTipPage.html";
CodeCadTipPage.Current_Item_DS = {};
function CodeCadTipPage:OnInit()
    self.page = document:GetPageCtrl();
end
function CodeCadTipPage:Show()
	local params = {
			url = self.mcml_url,
			name = self.name, 
			isShowTitleBar = false,
			DestroyOnClose = true,
			style = CommonCtrl.WindowFrame.ContainerStyle,
			allowDrag = true,
			enable_esc_key = true,
			directPosition = true,
				align = "_lt",
				x = 5,
				y = 5,
				width = 400,
				height = 500,
		};
	System.App.Commands.Call("File.MCMLWindowFrame", params);

    CodeCadTipPage:LoadData(function(data)
        self.Current_Item_DS = data;
        self:OnRefresh();
    end)
end
function CodeCadTipPage:OnRefresh()
    if(self.page)then
        self.page:Refresh(0);
    end
end
function CodeCadTipPage:LoadData(callback)
    nplcad3.asset.get({
        router_params = {
            filepath = "assetList.json",
        }
    },function(err, msg, data)
        if(err ~= 200)then
            return
        end
	    if(callback)then
            callback(data);
        end
    end)
end
function CodeCadTipPage:GetImage(index)
    local node = CodeCadTipPage.Current_Item_DS[index];
    local preview_url = node.preview_url or "";
    local icon = string.format("https://cdn.keepwork.com/NplCadCodeLib/nplcad3/%s",preview_url);
    local name = node.name or "";
    local s = string.format([[<div style="width:80px;height:45px;background:url(%s)" tooltip="%s" onclick="OnSelected" name="%d"/>]],icon,name,index)
    return s;
end
function CodeCadTipPage:OnSelected(index)
    index = tonumber(index);
    local node = CodeCadTipPage.Current_Item_DS[index];
    local filepath = node.url;
    commonlib.echo("============load");
    commonlib.echo(filepath);
    nplcad3.asset.get({
        router_params = {
            filepath = node.url,
        }
    },function(err, msg, data)
        commonlib.echo("============data");
        commonlib.echo(data);
        if(err ~= 200)then
            return
        end
    end)
end