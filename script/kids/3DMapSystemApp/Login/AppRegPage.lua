--[[
Title: Application registration page container
Author(s): LiXizhi
Date: 2008/3/21
Desc: show registration page for those whose status.RequiredComplete is false. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/Login/AppRegPage.lua");
Map3DSystem.App.Login.AppRegPage.RequiredApps = {
	{name="CCS", title = "select avatar", {RequiredComplete = false, CompleteProgress=0}},
	{name="profiles", title = "edit profile", {RequiredComplete = false, CompleteProgress=0}},
	{name="Map", title = "select land", {RequiredComplete = true, CompleteProgress=1}}
};
local width, height = 640, 512
Map3DSystem.App.Login.AppRegPage:Create("LoginApp.AppRegPage", nil, "_ct", -width/2, -height/2, width, height);
-------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystemApp/mcml/PageCtrl.lua");

-- create class
local AppRegPage = Map3DSystem.mcml.PageCtrl:new({url="script/kids/3DMapSystemApp/Login/AppRegPage.html"});
Map3DSystem.App.Login.AppRegPage = AppRegPage;

-- a table describing which apps needs to show registration page
AppRegPage.RequiredApps = nil;
-- function to be called when user completed or skipped all app registration steps. 
AppRegPage.OnFinishedFunc = nil;
		
-- this function is overridable. it is called before page UI is about to be created. 
-- @param self.mcmlNode: the root pe:mcml node, one can modify it here before the UI is created, such as filling in default data. 
function AppRegPage:OnLoad()
	local RequiredApps = Map3DSystem.App.Login.AppRegPage.RequiredApps;
	if(RequiredApps == nil)  then
		return;
	end
	local required_count = 0;
	local index, appReg;
	for index, appReg in ipairs(RequiredApps) do
		if(appReg.status and not appReg.status.RequiredComplete) then
			required_count = required_count + 1;
		end	
	end
	
	self:SetNodeText("username", Map3DSystem.User.Name)
	self:SetNodeText("app_number", tostring(required_count))
end

-- call this function to refresh the title step.e.g. 1 avatar, 2 profile, 3 land. 
-- @param currentStep: the currently selected index in RequiredApps
-- @param refreshUI: if true, it will refresh UI in title bar, otherwise it will only change the MCML accordingly. 
function AppRegPage:RefreshTitle(currentStep, refreshUI)
	local RequiredApps = Map3DSystem.App.Login.AppRegPage.RequiredApps;
	if(RequiredApps == nil)  then
		return;
	end
	
	local title_steps = self:GetNode("title_steps");
	if(not title_steps) then
		return;
	end
	title_steps:ClearAllChildren();
	
	local required_count = 0;
	local index, appReg;
	for index, appReg in ipairs(RequiredApps) do
		if(appReg.status and not appReg.status.RequiredComplete) then
			local bg_style;
			local text_style;
			if(currentStep>index) then
				-- passed step, TODO: use a checked mark background
				bg_style = "float:left;background:url(Texture/3DMapSystem/IntroPage/circle.png);"
				text_style = "float:left;font-size:12px;margin-top:8px;margin-left:4px;margin-left:4px;"
			elseif(currentStep==index) then
				-- current step, use a normal full colored mark background
				bg_style = "float:left;background:url(Texture/3DMapSystem/IntroPage/circle.png);"
				text_style = "float:left;font-size:12px;font-weight:bold;margin-top:8px;margin-left:4px;margin-left:4px;"
			else
				-- following steps, use a grey colored mark background
				bg_style = "float:left;background:;"
				text_style = "color:#888888;float:left;font-size:12px;margin-top:8px;margin-left:4px;margin-left:4px;"
			end
			required_count = required_count + 1;
			-- for each step: we will display a image number with a image background, and title text to right.
			local StepNode = Map3DSystem.mcml.new(nil, {name="div"})
			StepNode:SetAttribute("style", "float:left;")
			title_steps:AddChild(StepNode);
			
			-- Icon background
			local IconNode = Map3DSystem.mcml.new(nil, {name="div"})
			IconNode:SetAttribute("style", bg_style)
			StepNode:AddChild(IconNode);
			
			-- inner icon with image number
			local IconNumberNode = Map3DSystem.mcml.new(nil, {name="div"})
			local texLeft, texTop = math.mod(required_count, 4)*32,  math.floor((required_count)/4)*32;
			IconNumberNode:SetAttribute("style", string.format("float:left;width:32px;height:32px;background:url(Texture/3DMapSystem/IntroPage/16number.png# %d %d 32 32);", texLeft, texTop))
			IconNode:AddChild(IconNumberNode);
			
			-- Text with step title
			local TextNode = Map3DSystem.mcml.new(nil, {name="div", [1]=(appReg.title or appReg.name), n=1})
			TextNode:SetAttribute("style", text_style)
			StepNode:AddChild(TextNode);
		end	
	end
	if(refreshUI) then
		self:UpdateRegion("title_steps");
	end
end

-- this function is overridable. it is called after page UI is created. 
-- One can perform any processing steps that are set to occur on each page request. You can access view state information. You can also access controls within the page's control hierarchy.
-- In other words, one can have direct access to UI object created in the page control. Note that some UI are lazy created 
-- such as treeview item and tab view items. They may not be available here yet. 
function AppRegPage:OnCreate()
	local RequiredApps = Map3DSystem.App.Login.AppRegPage.RequiredApps;
	if(RequiredApps == nil)  then
		return;
	end
	local required_count = 0;
	local index, appReg;
	for index, appReg in ipairs(RequiredApps) do
		if(appReg.status and not appReg.status.RequiredComplete) then
			required_count = required_count + 1;
		end	
	end
	
	-- per application registration pages are created inside this pe:container. 
	local parent = self:FindControl("body");
	
	--
	-- show registration page for those whose status.RequiredComplete is false. 
	--
	if(parent and required_count>0) then
		--
		-- we display a summary of registration progress to allow user to skip or fill?
		-- 
		local index = 1;
		local function ShowAppRegPage()
			parent:RemoveAll();
			while(true) do
				appReg = RequiredApps[index];
				index = index + 1;
				if(appReg) then
					if(appReg.status and not appReg.status.RequiredComplete) then
						self:RefreshTitle(index-1, true);
						Map3DSystem.App.Commands.Call("Registration."..appReg.name, {operation="show", callbackFunc = ShowAppRegPage, parent = parent});
						break;
					end
				else
					-- the last app is completed, so all is completed. 
					AppRegPage.OnSkipAll();
					break;
				end
			end	
		end
		AppRegPage.ShowAppRegPage = ShowAppRegPage;
		
		-- start registration one by one. 
		AppRegPage.OnNextApp();
	end	
end

---------------------------------
-- page event handlers
---------------------------------

-- When clicks the basic info save button in the MCML page: ProfileAppRegPage.html  
function AppRegPage.OnNextApp(sCtrlName, values)
	if(AppRegPage.ShowAppRegPage) then
		AppRegPage.ShowAppRegPage();
	end
end

-- When clicks the contact info save button in the MCML page: ProfileAppRegPage.html  
function AppRegPage.OnSkipAll(sCtrlName, values)
	AppRegPage:Close();
	AppRegPage.ShowAppRegPage = nil;
	if(AppRegPage.OnFinishedFunc) then
		AppRegPage.OnFinishedFunc();
	end
end
