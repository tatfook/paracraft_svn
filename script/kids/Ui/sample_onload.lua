-- this is a sample file for world onload file, it displays the world info window.
-- common control library
NPL.load("(gl)script/kids/ui/worldinfoCtrl.lua");
local info = {
	creator = "LiXizhi",
	date = "2007/1/2",
	copyright = [[Copyrighted By ParaEngine Tech Studio]],
	desc = [[this is a demo
You can add your world description text here
]],
};

local function activate()
	KidsUI.ShowWorldInfo(info);
end
NPL.this(activate);
