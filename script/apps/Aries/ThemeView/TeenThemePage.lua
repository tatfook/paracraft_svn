--[[
Title: 
Author(s): Leio
Date: 2011/06/28
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/ThemeView/TeenThemePage.lua");
local TeenThemePage = commonlib.gettable("Map3DSystem.App.UISamples.TeenThemePage");
TeenThemePage.loaded = false;
-------------------------------------------------------
]]
local TeenThemePage = commonlib.gettable("Map3DSystem.App.UISamples.TeenThemePage");
TeenThemePage.file_path = "config/Aries/ThemeView/pagelist.xml";
function TeenThemePage.OnInit()
	local self = TeenThemePage;
	self.page = document:GetPageCtrl();
end
function TeenThemePage.DS_Func_Items(index)
	local self = TeenThemePage;
	if(not self.list)then return 0 end
	if(index == nil) then
		return #(self.list);
	else
		return self.list[index];
	end
end
function TeenThemePage.Load(page)
	local self = TeenThemePage;
	if(not self.loaded)then
		self.loaded = true;
		self.list= {};
		local xmlRoot = ParaXML.LuaXML_ParseFile(self.file_path);
		local node;
		for node in commonlib.XPath.eachNode(xmlRoot, "//items/item") do
			table.insert(self.list,node.attr);
		end
		if(page)then
			page:Refresh(0);
		end
	end
end
function TeenThemePage.DoClick(index)
	local self = TeenThemePage;
	if(self.list)then
		local node = self.list[index];
		if(node)then
			local url = node.url;
			local width = tonumber(node.width) or 800;
			local height = tonumber(node.height) or 600;
			if(not url)then return end
			System.App.Commands.Call("File.MCMLWindowFrame", {
				url = url, 
				name = url.."TeenThemePage.DoClick", 
				app_key=MyCompany.Aries.app.app_key, 

				isShowTitleBar = false,
				DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
				style = CommonCtrl.WindowFrame.ContainerStyle,
				zorder = 1,
				isTopLevel = false,
				allowDrag = true,
				directPosition = true,
					align = "_ct",
					x = -width/2,
					y = -height/2,
					width = width,
					height = height,
			});
		end
	end
end
