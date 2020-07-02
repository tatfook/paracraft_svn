--[[
Title: Asset Info Viewer
Author(s): LiXizhi
Date: 2008/11/04
Desc: View a given asset such as its author, its price, etc. It also gives the option to buy the asset. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Assets/AssetInfoViewer.lua");
------------------------------------------------------------
]]

local L = CommonCtrl.Locale("ParaWorld");

local AssetInfoViewer = {};
commonlib.setfield("MyCompany.HelloChat.AssetInfoViewer", AssetInfoViewer)

---------------------------------
-- page event handlers
---------------------------------
-- init
function AssetInfoViewer.OnInit()
	--local self = document:GetPageCtrl();
	--local name = self:GetRequestParam("name")
	--self:SetNodeValue("fileName", name);
end