--[[
Title: The network pannel UI and logics.
Author(s): LiXizhi
Date: 2006/10/8
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/network/NetworkPannel.lua");
network.Show();
------------------------------------------------------------
]]
local L = CommonCtrl.Locale("IDE");
NPL.load("(gl)script/network/ClientServerIncludes.lua");
NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/ide/FileDialog.lua");
NPL.load("(gl)script/ide/gui_helper.lua");

-- network: Kids UI library 
if(not network) then network={}; end


--[[called when the user tries to change the networking mode. This is the handler for the change mode buttons. 
@param mode: 0 standalone, 1 server, 2 client. 
]]
function network.OnModeChange(mode)
	-- read parameters from UI
	local tmp, serverName, user, password;
	tmp = ParaUI.GetUIObject("network_connect_to_name");
	if(tmp:IsValid() == true) then 
		serverName = tmp.text;
		if(serverName == "") then
			_guihelper.MessageBox(L"Server does not exist\r\n");
			return;
		end
	end
	
	tmp = ParaUI.GetUIObject("network_user_name");
	if(tmp:IsValid() == true) then 
		user = tmp.text;
		if(user == "") then
			_guihelper.MessageBox(L"Please enter your user name\r\n");
			return;
		end
	end
	tmp = ParaUI.GetUIObject("network_user_password");
	if(tmp:IsValid() == true) then 
		password = tmp.text;
	end
	
	-- (re)start the NPL runtime
	if(user~=nil and password~=nil) then
		-- write credential to file
		local file = ParaIO.open("config/npl_credential.txt", "w");
		file:WriteString(user.."\r\n");
		file:WriteString(password.."\r\n");
		file:close();
		ParaNetwork.EnableNetwork(true, user, password);
	end
	if(mode == 2) then
		-- this is a client
		if(serverName~=nil) then
			ParaNetwork.Restart();
			client.LoginToServer(serverName);
			network.OnUpdateUI();
		end
	else
		-- this is a server or standalone
		ParaNetwork.Restart();
		ParaWorld.SetServerState(mode);
		network.OnUpdateUI();	
	end
end

--[[Update all UI contents on the pannel ]]
local buttonNames = {"network_standalone","network_server","network_client"};
function network.OnUpdateUI()
	_guihelper.CheckRadioButtons( buttonNames,buttonNames[ParaWorld.GetServerState()+1], "255 0 0");
	
	local tmp = ParaUI.GetUIObject("network_server_my_address");
	if(tmp:IsValid() == true) then 
		tmp.text = "@"..ParaNetwork.GetLocalNerveCenterName().."://"..ParaNetwork.GetLocalIP()..":"..ParaNetwork.GetLocalNerveCenterPort();
	end

end

-- called whenever the connecto to list box item is selected. 
function network.OnConnectToNameSelect()
	local tmp = ParaUI.GetUIObject("network_connect_to_name_listbox");
	if(tmp:IsValid() == true) then 
		local sName = tmp.text;
		tmp = ParaUI.GetUIObject("network_connect_to_name");
		if(tmp:IsValid() == true) then 
			tmp.text = sName;
		end
	end
end

-- make the pannel invisible.
function network.OnPannelClose()
	local _parent = ParaUI.GetUIObject("network_pannel_cont");
	_parent.visible = false;
end

-- create or make visbile the network pannel window
function network.Show(bShow)
	local _this,_parent;
	
	_this = ParaUI.GetUIObject("network_pannel_cont");
	if(_this:IsValid() ~= true) then 
		if(bShow == false) then return	end
		local width,height = 470, 395;
		_this=ParaUI.CreateUIObject("container","network_pannel_cont", "_ct",-width/2,-height/2,width,height);
		_this:AttachToRoot();
		_this.background="Texture/net_bg.png;0 0 470 395";
		_this:SetTopLevel(true); -- __this.candrag and TopLevel and not be true simultanously 
		_parent = _this;
		
		-- Stand alone mode
		local left, top = 60, 40;	
		width,height = 150, 25;
		_this=ParaUI.CreateUIObject("button","network_standalone", "_lt",left, top,width, height);
		_parent:AddChild(_this);
		_this.text=L"Standalone";
		_this.onclick=";network.OnModeChange(0);";
		
		-- server mode
		top = top+height+10;
		_this=ParaUI.CreateUIObject("button","network_server", "_lt",left, top,width, height);
		_parent:AddChild(_this);
		_this.text=L"Share my world";
		_this.onclick=";network.OnModeChange(1);";
		
		_this=ParaUI.CreateUIObject("text","static", "_lt",left+width+5, top,70, height);
		_parent:AddChild(_this);
		_this.text=L"My address:";
		
		_this=ParaUI.CreateUIObject("editbox","network_server_my_address", "_lt",left+width+75, top,150, height);
		_parent:AddChild(_this);
		_this.background="Texture/kidui/main/bg_266X48.png";
		_this.text=""; -- "@worldname://IP:port";
		
		-- client mode
		top=top+height+10;
		_this=ParaUI.CreateUIObject("button","network_client", "_lt",left, top,width, height);
		_parent:AddChild(_this);
		_this.text=L"Login another world";
		_this.onclick=";network.OnModeChange(2);";
		
		-- client: connect to name and listbox.
		top=top+height+10;
		width, height = 300, 25; 
		_this=ParaUI.CreateUIObject("editbox","network_connect_to_name", "_lt",left, top,width, height);
		_parent:AddChild(_this);
		_this.text="ParaX";
		_this.background="Texture/kidui/main/bg_266X48.png";
		
		top=top+height+3;
		height = 80; 
		_this=ParaUI.CreateUIObject("listbox","network_connect_to_name_listbox", "_lt",left, top,width, height);
		_parent:AddChild(_this);
		_this.scrollable=true;
		_this.background="Texture/kidui/main/bg_266X48.png";
		_this.itemheight=15;
		_this.wordbreak=false;
		_this.onselect=";network.OnConnectToNameSelect();";
		_this.ondoubleclick=";network.OnModeChange(2);";
		_this.font="System;11;norm";
		_this.scrollbarwidth=20;
		
		-- list all sub directories in the User directory.
		CommonCtrl.InitFileDialog(ParaIO.GetCurDirectory(0).."config/address/","*.*", 0, 150, _this);
		
		-- client: user name and password.
		-- read credential from file
		local file = ParaIO.open("config/npl_credential.txt", "r");
		local username, password = ParaNetwork.GetLocalNerveCenterName(), "1234567";-- TODO: use empty string for password.
		if(file:IsValid()) then
			username = tostring(file:readline());
			password = tostring(file:readline());
			file:close();
		end
		top=top+height+3;
		width, height = 80, 25; 

		_this=ParaUI.CreateUIObject("text","static", "_lt",left, top,width, height);
		_parent:AddChild(_this);
		_this.text=L"User name:";
		
		_this=ParaUI.CreateUIObject("editbox","network_user_name", "_lt",left+width+5, top,150, height);
		_parent:AddChild(_this);
		_this.background="Texture/kidui/main/bg_266X48.png";
		_this.text=username;
		
		top=top+height+3;
		
		_this=ParaUI.CreateUIObject("text","static", "_lt",left, top,width, height);
		_parent:AddChild(_this);
		_this.text=L"Password:";
		
		_this=ParaUI.CreateUIObject("editbox","network_user_password", "_lt",left+width+5, top,150, height);
		_parent:AddChild(_this);
		_this.background="Texture/kidui/main/bg_266X48.png";
		_this.PasswordChar = "*";
		_this.text=password;
		
		top=top+height+3;
		width, height = 80, 30; 
		_this=ParaUI.CreateUIObject("button","static", "_lt",left, top,width, height);
		_parent:AddChild(_this);
		_this.text=L"Login";
		_this.onclick=";network.OnModeChange(2);";
		
		_this=ParaUI.CreateUIObject("button","static", "_lt",left+width+10, top,width, height);
		_parent:AddChild(_this);
		_this.text=L"Register";
		_this.onclick=string.format([[;_guihelper.MessageBox("%s");]], L"Please register with ParaIDE (Press F5)->Network register");
		
		-- close button
		_this=ParaUI.CreateUIObject("button","network_pannel_close_btn", "_rb",-90,-55,60,30);
		_parent:AddChild(_this);
		_this.text=L"Close";
		_this.onclick=";network.OnPannelClose();";
	else
		if(bShow == nil) then
			if(_this.visible == true) then
				_this.visible = false;
			else
				_this.visible = true;
				_this:SetTopLevel(true); -- __this.candrag and TopLevel and not be true simultanously 
			end
		else
			_this.visible = bShow;
		end
	end
	
	network.OnUpdateUI();
end
