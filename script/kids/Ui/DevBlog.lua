--[[
Title: ParaEngine Developer Blog Window
Desc: It just calls a remote web service to get the developer blog and show it to the user. 
The blog can be set to be updated daily, which it will record last blog update time locally.
Author(s): LiXizhi
Date: 2007/5/18
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/Ui/DevBlog.lua");
DevBlog.Show(true);
-------------------------------------------------------
]]

-- common control library
NPL.load("(gl)script/ide/common_control.lua");

if(not DevBlog) then DevBlog={}; end

-- TODO: the file path to store the blog data. 
-- the first line is the date of last retrieval; the following lines are blog content
DevBlog.localcache = "temp/kidsmovie_devBlog.txt";

-- TODO: web service to retrieve data
-- [input] msg = {date_from, date_to, language} 
-- [ouput] msg = {date_from, date_to, blogBodyText} 
DevBlog.webservice = "http://www.kids3dmovie.com/GetDevBlog.asmx";

--@param bShow: boolean to show or hide. if nil, it will toggle current setting. 
function DevBlog.Show(bShow)
	local _this,_parent;
	
	_this=ParaUI.GetUIObject("DevBlog_cont");
	if(_this:IsValid() == false) then
		if(bShow == false) then return	end
		bShow = true;
		
		local width, height = 400, 300;
		_this=ParaUI.CreateUIObject("container","DevBlog_cont","_ct",-width/2, -height/2,width, height);
		_this:SetTopLevel(true);
		_this:AttachToRoot();
		_parent = _this;
		
		-- open from cache
		local file = ParaIO.open(DevBlog.localcache, "r");
		if(file:IsValid()) then
			local date = file:readline();
			-- TODO compare date with current date, and call the webservice if necessary.
			file:close();
		else
			log("DEV blog failed to read file"..DevBlog.localcache.."\n");
		end
		
		local left, top, width, height = 0,0, 124, 32
		_this=ParaUI.CreateUIObject("button","DevBlog_OK","_lt",left,top,width,height);
		_this.text="OK";
		_this.onclick=";DevBlog.OnDestory();";
		_parent:AddChild(_this);
	else
		if(bShow == nil) then
			bShow = (_this.visible == false);
		end
		_this.visible = bShow;
		
		if(bShow == true) then
			_this:SetTopLevel(true);
		end
	end	
	if(bShow) then
		KidsUI.PushState({name = "DevBlog", OnEscKey = DevBlog.OnDestory});
	else
		KidsUI.PopState("DevBlog");
	end
end

-- destory the control
function DevBlog.OnDestory()
	KidsUI.PopState("DevBlog");
	ParaUI.Destroy("DevBlog_cont");
end