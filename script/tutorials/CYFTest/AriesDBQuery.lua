--[[
Title: 
Author(s): Leio
Date: 2010/06/03
Desc:  
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/tutorials/CYFTest/AriesDBQuery.lua");
-------------------------------------------------------
]]
local AriesDBQuery =commonlib.gettable("PETools.Aries.AriesDBQuery");

function AriesDBQuery.OnInit()
	local self = AriesDBQuery;
	self.page = document:GetPageCtrl();
end
function AriesDBQuery.DoQuery(filepath)
	local self = AriesDBQuery;
	_guihelper.MessageBox(filepath,function()
		if(self.page)then
			local s = string.format("received:%s",filepath);
			self.page:SetValue("_txt",s);
			self.page:Refresh(0.01);
		end
	end);
end