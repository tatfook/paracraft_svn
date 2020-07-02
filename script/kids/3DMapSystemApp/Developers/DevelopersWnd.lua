--[[
Title:  
Author(s): Leio Zhang
Date: 2008/4/8
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/Developers/DevelopersWnd.lua");
Map3DSystem.App.Developers.ShowWnd(app);
-------------------------------------------------------
]]
-- common control library
NPL.load("(gl)script/ide/common_control.lua");

commonlib.setfield("Map3DSystem.App.Developers.DevelopersWnd", {});
Map3DSystem.App.Developers.DevelopersWnd.SelectedTable=nil;
function Map3DSystem.App.Developers.ShowWnd(_app)
	NPL.load("(gl)script/kids/3DMapSystemUI/Windows.lua");
	local _wnd = _app:FindWindow("Map3DSystem.App.Developers.DevelopersWnd") or _app:RegisterWindow("Map3DSystem.App.Developers.DevelopersWnd", nil, Map3DSystem.App.Developers.DevelopersWnd.MSGProc);
	
	local _wndFrame = _wnd:GetWindowFrame();
	if(not _wndFrame) then
		_wndFrame = _wnd:CreateWindowFrame{
			icon = "Texture/3DMapSystem/common/plugin_add.png",
			text = "新建向导",
			initialPosX = 0,
			initialPosY = 50,
			initialWidth = 640,
			initialHeight = 470,
			allowDrag = true,
			ShowUICallback = Map3DSystem.App.Developers.DevelopersWnd.Show,
		};
	end
	_wnd:ShowWindowFrame(true);
end
function Map3DSystem.App.Developers.DevelopersWnd.Show(bShow, _parent, parentWindow)
	local _this;
	Map3DSystem.App.Developers.DevelopersWnd.parentWindow = parentWindow;
	
	_this=ParaUI.GetUIObject("DevelopersWnd_cont");
	if(_this:IsValid() == false) then
		if(bShow == false) then return	end
		bShow = true;
		if(_parent==nil) then
			_this=ParaUI.CreateUIObject("container","DevelopersWnd_cont","_lt",0,50, 150, 300);
			_this:AttachToRoot();
		else
			_this = ParaUI.CreateUIObject("container", "DevelopersWnd_cont", "_fi",0,0,0,0);
			_this.background = "";
			_parent:AddChild(_this);
		end	
		_parent = _this;
		
		_this = ParaUI.CreateUIObject("text", "label1", "_lt", 9, 10, 83, 12)
	_this.text = "Project Types";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("text", "label2", "_lt", 231, 10, 59, 12)
	_this.text = "Templates";
	_parent:AddChild(_this);

	NPL.load("(gl)script/ide/TreeView.lua");
		local ctl = CommonCtrl.GetControl("DevelopersWnd.treeViewTypes");
		if(not ctl) then
			ctl = CommonCtrl.TreeView:new{
				name = "DevelopersWnd.treeViewTypes",
				alignment = "_ml",
				left = 9,
				top = 25,
				width = 215,
				height = 135,
				parent = _parent,
				container_bg = "Texture/3DMapSystem/common/ThemeLightBlue/container_bg.png: 4 4 4 4",
				DefaultIndentation = 5,
				DefaultNodeHeight = 25,	
			};	
		else
			ctl.parent = _parent;
		end	
		ctl.DrawNodeHandler=ctl.DrawSingleSelectionNodeHandler;
		ctl:Show();
	
	NPL.load("(gl)script/ide/DoubleView.lua");
	local ctl = CommonCtrl.GetControl("DevelopersWnd.doubleview");
	if(not ctl) then
		ctl = CommonCtrl.DoubleView:new{
		-- the top level control name
		name = "DevelopersWnd.doubleview",
		alignment = "_fi",
		left = 230,
		top = 5,
		width = 7,
		height = 135,
		parent = _parent,
		-- the background of container
		container_bg = "Texture/3DMapSystem/common/ThemeLightBlue/container_bg.png: 4 4 4 4",
		RootNode = nil,
		--default state
		State = "grid",--list or grid
		
		
		--about TreeView property
		DefaultIndentation = 5,
		DefaultNodeHeight = 40,
		DrawNodeHandler = nil,
		--about GridView property
		cellWidth = 100,
		cellHeight = 100,
		columns = 4,
		DrawCellHandler = nil,
		--about state menu property
		stateMenuHeight = 20,
		stateMenuWidth = 60,
		
		DataContext = nil,
		--event
		SeletedDataCallBack = Map3DSystem.App.Developers.DevelopersWnd.SeletedDataCallBack,
		}
	else
			ctl.parent = _parent;
	end	

	ctl:Show();

	_this = ParaUI.CreateUIObject("imeeditbox", "DevelopersWnd.des_text", "_mb", 9, 106, 7, 23)
	_this.text = "Please select the item type that you want to create as well as their instance name and location";
	_this.enabled = false;
	_parent:AddChild(_this);
	
	_this = ParaUI.CreateUIObject("text", "label3", "_lb", 9, -91, 35, 12)
	_this.text = "Name:";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("text", "label4", "_lb", 9, -62, 59, 12)
	_this.text = "Location:";
	_parent:AddChild(_this);


	_this = ParaUI.CreateUIObject("imeeditbox", "DevelopersWnd.name_txt", "_mb", 86, 72, 90, 23)
	_this.text = "";
	
	_parent:AddChild(_this);
	
	NPL.load("(gl)script/ide/dropdownlistbox.lua");
	local ctl = CommonCtrl.dropdownlistbox:new{
		name = "DevelopersWnd.location_txt",
		alignment = "_mb",
		left=86, top=42,
		width = 90,
		height = 23,
		parent = _parent,
		items = {"", "temp/test", "script/ide/ProjectTemplates/Templates", },
	};
	ctl:Show();
	
	_this = ParaUI.CreateUIObject("button", "browse_btn", "_rb", -82, -65, 75, 23)
	_this.text = "Browse...";
	_this.onclick = ";Map3DSystem.App.Developers.DevelopersWnd.Browse_Click();";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("button", "b", "_mb", 9, 35, 8, 1)
	_this.enabled = false;
	_this.background = "Texture/whitedot.png";
	_guihelper.SetUIColor(_this, "150 150 150 255");
	_parent:AddChild(_this);
	
	_this = ParaUI.CreateUIObject("button", "ok_btn", "_rb", -165, -29, 75, 23)
	_this.text = "OK";
	_this.onclick = ";Map3DSystem.App.Developers.DevelopersWnd.Ok_Click();";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("button", "cancel_btn", "_rb", -82, -29, 75, 23)
	_this.text = "Cancel";
	_this.onclick = ";Map3DSystem.App.Developers.DevelopersWnd.Cancel_Click();";
	_parent:AddChild(_this);

	
	Map3DSystem.App.Developers.DevelopersWnd.Update_treeViewTypes();
	
	else
		if(bShow == nil) then
			bShow = not _this.visible;
		end
		
		_parent = _this;
	end	
	if(bShow) then
	else	
	end
end
-- fill data with treeViewTypes
function Map3DSystem.App.Developers.DevelopersWnd.Update_treeViewTypes()
	local xmlRoot = ParaXML.LuaXML_ParseFile("script/ide/ProjectTemplates/Template.xml");
	NPL.load("(gl)script/ide/XPath.lua");
	local xpath = "/item/item";
	local result = commonlib.XPath.selectNodes(xmlRoot, xpath);
	local treeView = CommonCtrl.GetControl("DevelopersWnd.treeViewTypes");
	local node=treeView.RootNode;
	node:ClearAllChildren();
	for k,v in ipairs(result) do
		local name=tostring(v[1][1]);
		local templates=v[2];
		--log(commonlib.serialize(templates));
		local treeNode=node:AddChild( CommonCtrl.TreeNode:new({Tag=templates,Text=name, Icon ="Texture/3DMapSystem/common/plugin.png"}) );
		treeNode.onclick=string.format("Map3DSystem.App.Developers.DevelopersWnd.TypesOnClick(%q,%q);",treeNode.TreeView.name, treeNode:GetNodePath())
	end
	treeView:Update();
end


function Map3DSystem.App.Developers.DevelopersWnd.TypesOnClick(sCtrlName, nodePath)
	local ctl, node = CommonCtrl.TreeView.GetCtl(sCtrlName, nodePath);
	if(node) then
		local tag = node.Tag;
		
		if(tag)then
			local temp ={};
			for k,v in ipairs(tag) do
			local t = {};
				t.name = v[1][1];
				t.des = v[2][1];
				t.icon = v[3][1];
				t.startup = v[4][1];
				t.loadnpl = v[5][1];
			table.insert(temp,t);
			end
			local doubleview = CommonCtrl.GetControl("DevelopersWnd.doubleview");
				  doubleview.DataContext = temp;
				  doubleview:UpdateState();
		end	
		node:SelectMe(true);
		-- clear selected table
		Map3DSystem.App.Developers.DevelopersWnd.SelectedTable=nil;
		Map3DSystem.App.Developers.DevelopersWnd.SetDescription("");
	end
end

function Map3DSystem.App.Developers.DevelopersWnd.SeletedDataCallBack(data)
	Map3DSystem.App.Developers.DevelopersWnd.SelectedTable=data;
	Map3DSystem.App.Developers.DevelopersWnd.SetDescription(data.des)
	--_guihelper.MessageBox(commonlib.serialize(data));
end

-- set description of textfield
function Map3DSystem.App.Developers.DevelopersWnd.SetDescription(des)
	local des_text = ParaUI.GetUIObject("DevelopersWnd.des_text");
	if(des_text:IsValid())then
		des_text.text = des ;
	end
end
function Map3DSystem.App.Developers.DevelopersWnd.Destroy()
	ParaUI.Destroy("DevelopersWnd.TemplatesContainer");
	CommonCtrl.DeleteControl("DevelopersWnd.treeViewTypes");
	CommonCtrl.DeleteControl("DevelopersWnd.doubleview");
end

function Map3DSystem.App.Developers.DevelopersWnd.Ok_Click()
	local errormsg = "";
		local name = ParaUI.GetUIObject("DevelopersWnd.name_txt").text;
		local location = ""
		local ctl = CommonCtrl.GetControl("DevelopersWnd.location_txt");
		if(ctl)then
			location = ctl:GetValue();
		end
		
		--ValidateName
		local errormsg ,fileName =Map3DSystem.App.Developers.DevelopersWnd.ValidateName(name)
		if(location == "")then errormsg = errormsg .."请选择安装路径\n"; end
		if(Map3DSystem.App.Developers.DevelopersWnd.SelectedTable==nil)then errormsg = errormsg .."请选择一个项目\n"; end
		if(errormsg=="")then
			if(Map3DSystem.App.Developers.DevelopersWnd.Run(name,location))then
				Map3DSystem.App.Developers.DevelopersWnd.Cancel_Click();
			end
		else
			_guihelper.MessageBox(commonlib.serialize(errormsg));
		end
end

function Map3DSystem.App.Developers.DevelopersWnd.Run(name,location)
	if(Map3DSystem.App.Developers.DevelopersWnd.SelectedTable)then
		local path=Map3DSystem.App.Developers.DevelopersWnd.SelectedTable.loadnpl;
		local functionName = Map3DSystem.App.Developers.DevelopersWnd.SelectedTable.startup;
		if(string.match(functionName, "%.html$")) then
			-- this is added by LiXizhi 2008.9.18. Load the html file if startup is an MCML page. 
			if(path) then
				path = string.format("(gl)%s",path);
			end
			if(ParaIO.DoesFileExist(functionName, true)) then
				NPL.load("(gl)script/ide/System/localserver/UrlHelper.lua");
				local url = System.localserver.UrlHelper.BuildURLQuery(functionName, {name=name, location=location});
				Map3DSystem.App.Commands.Call("File.MCMLBrowser", {url=url, name="TemplateStartupPage", title="Location:"..tostring(location), DisplayNavBar = true});
				return true;
			end	
		elseif(path and functionName)then
			path = string.format("(gl)%s",path);
			NPL.load(path);	
			NPL.DoString("Map3DSystem.App.Developers.DevelopersWnd.func="..functionName);
			if(type(Map3DSystem.App.Developers.DevelopersWnd.func) == "function") then
				Map3DSystem.App.Developers.DevelopersWnd.func(name,location)
			end	
			return true;
		end
	end
end

function Map3DSystem.App.Developers.DevelopersWnd.Cancel_Click()
	if(Map3DSystem.App.Developers.DevelopersWnd.parentWindow) then
		Map3DSystem.App.Developers.DevelopersWnd.parentWindow:DestroyWindowFrame();
	end	
end
function Map3DSystem.App.Developers.DevelopersWnd.Browse_Click()
		NPL.load("(gl)script/ide/OpenFolderDialog.lua");
		local dialog = CommonCtrl.OpenFolderDialog:new();
		dialog:Show();
		dialog.OnSelected=Map3DSystem.App.Developers.DevelopersWnd.SelectedFolder;
end
function Map3DSystem.App.Developers.DevelopersWnd.SelectedFolder(sCtrlName,path)
	local ctl = CommonCtrl.GetControl("DevelopersWnd.location_txt");
	if(ctl)then
		ctl:SetValue(path);
	end
end

function Map3DSystem.App.Developers.DevelopersWnd.ValidateName(str)
	local errormsg="";
	local reservedName = "";
		str = string.gsub(str,"%s*$","");
		str = string.gsub(str,"^%s*","");
		str = string.gsub(str,"%.*$","");
		str = string.gsub(str,"^%.*","");
		
	if(string.find(str,"[%c~!@#$%%^&*()=+%[\\%]{}''\";:/?,><`|!￥…（）-、；：。，》《]")) then
		errormsg = errormsg.."不能含有特殊字符\n"
	end
	
	if(string.len(str)<3) then
			errormsg = errormsg.."名称太短\n"
	end
	return errormsg,str;
end

function Map3DSystem.App.Developers.DevelopersWnd.MSGProc(window, msg)
	----------------------------------------------------
	-- normal windows messages here
	----------------------------------------------------
	if(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		window:DestroyWindowFrame();
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		-- update control 
		local ctl = CommonCtrl.GetControl("DevelopersWnd.doubleview");
		if(ctl~=nil) then
			ctl:Update();
		end	
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_HIDE) then
		
		Map3DSystem.UI.Windows.ShowWindow(false, Map3DSystem.App.Developers.DevelopersWnd.parentWindow.app.name, msg.wndName);
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SHOW) then
		Map3DSystem.UI.Windows.ShowWindow(true, Map3DSystem.App.Developers.DevelopersWnd.parentWindow.app.name, msg.wndName);
	end
end