--[[
Title: Email for Orion App
Author(s): Chengpeng Zhang
Date: 200/03/02
Desc: The Emai contains 
	1. left area: Inbox, Sent Mail, Drafts, Spam, Compose, Contact
	2. right area: Email Show
Area: 
	-----------------------------------------------------
	| Inbox				Email Show				        |
	| 										            |
	| Sent Mail											|
	| 													|
	| Drafts											|
	| 													|
	| Spam												|
	| 													|
	| Compose											|
	|													|
	| Contact											|
	|													|
	|													|
	|						   						    |
	-----------------------------------------------------
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Orion/Desktop/Mail.lua");
MyCompany.Orion.Mail.ShowMailWindow()
------------------------------------------------------------
]]

-- create class
--local libName = "Mail";
local Mail = {};
commonlib.setfield("MyCompany.Orion.Mail", Mail);

--Mail Window's Name
Mail.wnd_name = "Mail_Window"

-- +TIP+: bravo, OrionDesktop.lua looks much clean now

-- +TIP+: you directly use the function calls, well, it's your application
--		can you wrap the function into an easy AppCommand in app_main?

--Show the Mail Window
function Mail.ShowMailWindow()
	Mail.CreateMailWindow();
	local _app = MyCompany.Orion.app._app;
	local _wnd = _app:FindWindow(Mail.wnd_name);
	if(_wnd ~= nil) then
		local frame = _wnd:GetWindowFrame();
		if(frame ~= nil) then
			frame:Show2();
		end
	end	
end

--Mail Window handler
function Mail.MSGProc(window, msg)
	if(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then

-- +TIP+: good, are you clear with this function, if so, change the all raw WindowFrame calls into window:ShowWindowFrame

		window:ShowWindowFrame(false);
	end
end

--Create the Mail Window
function Mail.CreateMailWindow()
	local _app = MyCompany.Orion.app._app;
	local _wnd = _app:FindWindow("Mail_Window") or _app:RegisterWindow("Mail_Window", nil, Mail.MSGProc);
	--local _wnd = _app:FindWindow(Mail.wnd_name) or _app:RegisterWindow("Mail_Window", nil, Mail.MSGProc);
	
	local MailWindowsParam = {
		wnd = _wnd, -- a CommonCtrl.os.window object
		
		text = "Pala5 Email",
		
		isShowTitleBar = true, -- default show title bar
		isShowToolboxBar = false, -- default hide title bar
		isShowStatusBar = false, -- default show status bar
		
		initialWidth = 900, -- initial width of the window client area
		initialHeight = 600, -- initial height of the window client area
		
		initialPosX = 50,
		initialPosY = 10,
		
		maxWidth = 600,
		maxHeight = 600,
		minWidth = 300,
		minHeight = 300,
		
		style = CommonCtrl.WindowFrame.DefaultStyle,
				
		alignment = "Free", -- Free|Left|Right|Bottom
		
		-- +TIP+: you directly use Mail.MailWindowShowUICallback for this callback
		ShowUICallback = MyCompany.Orion.Mail.MailWindowShowUICallback,
		
	};

	--Create a window object in the pattern of MailWindowParam
	return CommonCtrl.WindowFrame:new2(MailWindowsParam);
end

-- +TIP+: what if the ShowUICallback function passed a bShow param with false, you still show the Mail

--ShowUICallback of the Mail Window
function Mail.MailWindowShowUICallback(bShow, _parent)
	local groot = ParaUI.GetUIObject("MailButtonArea");
	
	-- +TIP+: an indent in code indicates a certain logical scopes, such as functions or loops
	
		if(groot:IsValid() == false) then
			groot = ParaUI.CreateUIObject("container", "MailButtonArea", "_lt",0 , 0, 100, 600)
			groot.background = "Texture/alphadot.png:15 15 15 15" 
			_parent:AddChild(groot)
		end
		
		local _groot = ParaUI.CreateUIObject("container", "MailShowArea", "_lt",110 , 0, 900-110, 600)
		_groot.background = "Texture/pressedbox.png:15 15 15 15" 
		_parent:AddChild(_groot)
		
		NPL.load("(gl)script/ide/TreeView.lua");
		
	
		--Create a TreeView to store Inbox Data
		local ctl_Inbox = CommonCtrl.GetControl("TreeView_Orion_Mail_Inbox");
		if(ctl_Inbox == nil) then
			ctl_Inbox = CommonCtrl.TreeView:new{
			name = "TreeView_Orion_Mail_Inbox",
			alignment = "_lt",
			left=0, top=0,
			width = 900-110,
			height = 600,
			parent = _groot,
	-- +TIP+: you've been using three treeviews with the same DrawNodeHandler function, any improvements?
			DrawNodeHandler = function (parent,treeNode)
				if(parent==nil or treeNode==nil) then return end
				local date = ParaGlobal.GetDateFormat("yyyy-MM-dd");
				
				local _btn = ParaUI.CreateUIObject("button", "btn", "_fi", 0,0,0,0);
				_btn.background = "Texture/3DMapSystem/common/AquaOpenBlue_full.png:4 4 4 4";
				_btn.color = "255 255 255 100";
				_btn.onclick = string.format(";MyCompany.Orion.Mail.ShowOneEmail(%q, %q, %q);", "TreeView_Orion_Mail_Inbox", treeNode.title, date)
				parent:AddChild(_btn);
				
	-- +TIP+: this _icon, _title and _date will block the click on the btn itself, 
	--		i wrote the code just to demonstrate how to use the treeview ownerdraw
	
				local _icon = ParaUI.CreateUIObject("container", "icon", "_lt", 8, 8, 32, 32);
				_icon.background = "Texture/3DMapSystem/common/page_white.png";
				parent:AddChild(_icon);
				
				local _title = ParaUI.CreateUIObject("text", "title", "_lt", 8+32, 8+8, 100, 32);
				_title.text = treeNode.title;
				parent:AddChild(_title);
				
				local _date = ParaUI.CreateUIObject("text", "date", "_rt", -100, 16, 100, 24);
				_date.text = date;
				parent:AddChild(_date);
				local width, _ = _date:GetTextLineSize();
				
				return 48;
				end,
			};
			
	-- +TIP+: do you have any idea how the Mail web APIs provide such data directly into your code?
	--		wrap interfaces for Mail
	--		suppose you want this file as part of Mail application, what do you need? and what do you provide?
	--		how other programmers will use your code
	
			local node = ctl_Inbox.RootNode;
			node:AddChild(CommonCtrl.TreeNode:new({title = "Inbox1", Name = "sample"}));
			node:AddChild(CommonCtrl.TreeNode:new({title = "Inbox2", Name = "sample"}));
			node:AddChild(CommonCtrl.TreeNode:new({title = "Inbox3", Name = "sample"}));
			node:AddChild(CommonCtrl.TreeNode:new({title = "Inbox4", Name = "sample"}));
			node:AddChild(CommonCtrl.TreeNode:new({title = "Inbox5", Name = "sample"}));
		end
	    
	    
	-- +TIP+: this will be a "global" _c
	
		--Create a container to show just one Email clicked
		_c = ParaUI.CreateUIObject("container", "TreeView_Orion_Mail_ShowOne", "_fi", 0,0,0,0);
		_c.background = "Texture/3DMapSystem/common/AquaOpenBlue_full.png:4 4 4 4";
		_c.color = "255 255 255 100";
		_groot:AddChild(_c);
		
		local _icon = ParaUI.CreateUIObject("container", "icon", "_lt", 8, 8, 32, 32);
		_icon.background = "Texture/3DMapSystem/common/page_white.png";
		_c:AddChild(_icon);
		
		local _title = ParaUI.CreateUIObject("text", "title", "_lt", 8+32, 8+8, 100, 32);
		_c:AddChild(_title);
		
		local _date = ParaUI.CreateUIObject("text", "date", "_rt", -100, 16, 100, 24);
		_c:AddChild(_date);
		
		_c.visible = false

		local node = ParaUI.CreateUIObject("button","InboxArea","_lt",0, 0, 100, 50)
		node.background = "Texture/b_up.png:15 15 15 15";
		node.text= "Inbox";
		node.enabled= true;
		node.onclick = string.format(";MyCompany.Orion.Mail.ShowMailTreeView(%q);", "TreeView_Orion_Mail_Inbox");
		node.font= "system;14;bold";
		_guihelper.SetFontColor(node, "255 255 255");
		groot:AddChild(node)
		
		--Create a TreeView to store Sent Mail Data
		local ctl_SentMail = CommonCtrl.GetControl("TreeView_Orion_Mail_SentMail");
		if(ctl_SentMail == nil) then
			ctl_SentMail = CommonCtrl.TreeView:new{
			name = "TreeView_Orion_Mail_SentMail",
			alignment = "_lt",
			left=0, top=0,
			width = 900-110,
			height = 600,
			parent = _groot,
			DrawNodeHandler = function (parent,treeNode)
				
				local _btn = ParaUI.CreateUIObject("button", "btn", "_fi", 0,0,0,0);
				_btn.background = "Texture/3DMapSystem/common/AquaOpenBlue_full.png:4 4 4 4";
				_btn.color = "255 255 255 100";
				local date = ParaGlobal.GetDateFormat("yyyy-MM-dd");
				_btn.onclick = string.format(";MyCompany.Orion.Mail.ShowOneEmail(%q, %q, %q);", "TreeView_Orion_Mail_SentMail", treeNode.title, date)
				parent:AddChild(_btn);
				
				local _icon = ParaUI.CreateUIObject("container", "icon", "_lt", 8, 8, 32, 32);
				_icon.background = "Texture/3DMapSystem/common/page_white.png";
				parent:AddChild(_icon);
				
				local _title = ParaUI.CreateUIObject("text", "title", "_lt", 8+32, 8+8, 100, 32);
				_title.text = treeNode.title;
				parent:AddChild(_title);
				
				local _date = ParaUI.CreateUIObject("text", "date", "_rt", -100, 16, 100, 24);
				_date.text = date;
				parent:AddChild(_date);
				
				return 48;
			end,
			};
			local node1 = ctl_SentMail.RootNode;
			node1:AddChild(CommonCtrl.TreeNode:new({title = "Sent Mail1", Name = "sample"}));
			node1:AddChild(CommonCtrl.TreeNode:new({title = "Sent Mail2", Name = "sample"}));
			node1:AddChild(CommonCtrl.TreeNode:new({title = "Sent Mail3", Name = "sample"}));
			node1:AddChild(CommonCtrl.TreeNode:new({title = "Sent Mail4", Name = "sample"}));
			node1:AddChild(CommonCtrl.TreeNode:new({title = "Sent Mail5", Name = "sample"}));
		end
		--ctl:Show();
		local node = ParaUI.CreateUIObject("button","SentMailArea","_lt",0, 0+100, 100, 50)
		node.background = "Texture/b_up.png:15 15 15 15";
		node.text= "Sent Mail";
		node.enabled= true;
		node.onclick = string.format(";MyCompany.Orion.Mail.ShowMailTreeView(%q);", "TreeView_Orion_Mail_SentMail")
		node.font= "system;14;bold";
		_guihelper.SetFontColor(node, "255 255 255");
		groot:AddChild(node)
		
		--Create a TreeView to store Drafts Data
		local ctl_Drafts = CommonCtrl.GetControl("TreeView_Orion_Mail_Drafts");
		if(ctl_Drafts == nil) then
			ctl_Drafts = CommonCtrl.TreeView:new{
			name = "TreeView_Orion_Mail_Drafts",
			alignment = "_lt",
			left=0, top=0,
			width = 900-110,
			height = 600,
			parent = _groot,
			DrawNodeHandler = function (parent,treeNode)
				
				local _btn = ParaUI.CreateUIObject("button", "btn", "_fi", 0,0,0,0);
				_btn.background = "Texture/3DMapSystem/common/AquaOpenBlue_full.png:4 4 4 4";
				_btn.color = "255 255 255 100";
				local date = ParaGlobal.GetDateFormat("yyyy-MM-dd");
				_btn.onclick = string.format(";MyCompany.Orion.Mail.ShowOneEmail(%q, %q, %q);", "TreeView_Orion_Mail_Drafts", treeNode.title, date)
				parent:AddChild(_btn);
				
				local _icon = ParaUI.CreateUIObject("container", "icon", "_lt", 8, 8, 32, 32);
				_icon.background = "Texture/3DMapSystem/common/page_white.png";
				parent:AddChild(_icon);
				
				local _title = ParaUI.CreateUIObject("text", "title", "_lt", 8+32, 8+8, 100, 32);
				_title.text = treeNode.title;
				parent:AddChild(_title);
				
				local _date = ParaUI.CreateUIObject("text", "date", "_rt", -100, 16, 100, 24);
				_date.text = date;
				parent:AddChild(_date);
				
				return 48;
			end,
			};
			local node1 = ctl_Drafts.RootNode;
			node1:AddChild(CommonCtrl.TreeNode:new({title = "Drafts1", Name = "sample"}));
			node1:AddChild(CommonCtrl.TreeNode:new({title = "Drafts2", Name = "sample"}));
			node1:AddChild(CommonCtrl.TreeNode:new({title = "Drafts3", Name = "sample"}));
			node1:AddChild(CommonCtrl.TreeNode:new({title = "Drafts4", Name = "sample"}));
			node1:AddChild(CommonCtrl.TreeNode:new({title = "Drafts5", Name = "sample"}));
		end
		--ctl:Show();
		local node = ParaUI.CreateUIObject("button","DraftsArea","_lt",0, 0+100+100, 100, 50)
		node.background = "Texture/b_up.png:15 15 15 15";
		node.text= "Drafts";
		node.enabled= true;
		node.onclick = string.format(";MyCompany.Orion.Mail.ShowMailTreeView(%q);", "TreeView_Orion_Mail_Drafts")
		node.font= "system;14;bold";
		_guihelper.SetFontColor(node, "255 255 255");
		groot:AddChild(node)
		
		--Create a TreeView to store Spam Data
		local ctl_Spam = CommonCtrl.GetControl("TreeView_Orion_Mail_Spam");
		if(ctl_Spam == nil) then
			ctl_Spam = CommonCtrl.TreeView:new{
			name = "TreeView_Orion_Mail_Spam",
			alignment = "_lt",
			left=0, top=0,
			width = 900-110,
			height = 600,
			parent = _groot,
			DrawNodeHandler = function (parent,treeNode)
				
				local _btn = ParaUI.CreateUIObject("button", "btn", "_fi", 0,0,0,0);
				_btn.background = "Texture/3DMapSystem/common/AquaOpenBlue_full.png:4 4 4 4";
				_btn.color = "255 255 255 100";
				local date = ParaGlobal.GetDateFormat("yyyy-MM-dd");
				_btn.onclick = string.format(";MyCompany.Orion.Mail.ShowOneEmail(%q, %q, %q);", "TreeView_Orion_Mail_Spam", treeNode.title, date)
				parent:AddChild(_btn);
				
				local _icon = ParaUI.CreateUIObject("container", "icon", "_lt", 8, 8, 32, 32);
				_icon.background = "Texture/3DMapSystem/common/page_white.png";
				parent:AddChild(_icon);
				
				local _title = ParaUI.CreateUIObject("text", "title", "_lt", 8+32, 8+8, 100, 32);
				_title.text = treeNode.title;
				parent:AddChild(_title);
				
				local date = ParaGlobal.GetDateFormat("yyyy-MM-dd");
				local _date = ParaUI.CreateUIObject("text", "date", "_rt", -100, 16, 100, 24);
				_date.text = date;
				parent:AddChild(_date);
				
				return 48;
			end,
			};
			local node1 = ctl_Spam.RootNode;
			node1:AddChild(CommonCtrl.TreeNode:new({title = "Spam1", Name = "sample"}));
			node1:AddChild(CommonCtrl.TreeNode:new({title = "Spam2", Name = "sample"}));
			node1:AddChild(CommonCtrl.TreeNode:new({title = "Spam3", Name = "sample"}));
			node1:AddChild(CommonCtrl.TreeNode:new({title = "Spam4", Name = "sample"}));
			node1:AddChild(CommonCtrl.TreeNode:new({title = "Spam5", Name = "sample"}));
		end
		--ctl:Show();
		local node = ParaUI.CreateUIObject("button","SpamArea","_lt",0, 0+100+100+100, 100, 50)
		node.background = "Texture/b_up.png:15 15 15 15";
		node.text= "Spam";
		node.enabled= true;
		node.onclick = string.format(";MyCompany.Orion.Mail.ShowMailTreeView(%q);", "TreeView_Orion_Mail_Spam")
		node.font= "system;14;bold";
		_guihelper.SetFontColor(node, "255 255 255");
		groot:AddChild(node)
		
		
		------------------------Compose Mail Area---------------------------------------------
		local _compose_cont = ParaUI.CreateUIObject("container","compose_cont","_fi", 0, 0, 0, 0);
		_compose_cont.background = "";
		_groot:AddChild(_compose_cont)
		_compose_cont.visible = false
		
		NPL.load("(gl)script/ide/MultiLineEditbox.lua");
		local ctl = CommonCtrl.MultiLineEditbox:new{
			name = "MultiLineEditbox_Mail_Compose",
			alignment = "_lt",
			left=10, 
			top=120,
			width = 900-140,
			height = 460, 
			WordWrap = false,
			container_bg = "Texture/3DMapSystem/common/ThemeLightBlue/btn_bg_highlight.png: 4 4 4 4",
			parent = _compose_cont,
		};
		ctl:Show(true);
		ctl:SetText("Please Compose Here:\r");
		--log(ctl:GetText());
		
		local node = ParaUI.CreateUIObject("text","MailShowArea_TextTo","_lt",10, 10, 100, 30)
		node.background = "";
		node.text= "To:";
		node.font= "system;14;bold";
		_guihelper.SetFontColor(node, "255 0 0");
		_compose_cont:AddChild(node)
		
		
		local node = ParaUI.CreateUIObject("editbox","MailShowArea_EditboxTo","_lt",10+30+50, 10, 600, 30)
		node.background = "Texture/speak_box.png:15 15 15 15";
		_compose_cont:AddChild(node)

		local node = ParaUI.CreateUIObject("text","MailShowArea_TextSubject","_lt",10, 10+30, 100, 30)
		node.background = "";
		node.text= "Subject:";
		node.font= "system;14;bold";
		_guihelper.SetFontColor(node, "255 0 0");
		_compose_cont:AddChild(node)
		
		local node = ParaUI.CreateUIObject("editbox","MailShowArea_EditboxSubject","_lt",10+30+50, 10+30, 600, 30)
		node.background = "Texture/speak_box.png:15 15 15 15";
		_compose_cont:AddChild(node)
		
		local node = ParaUI.CreateUIObject("button","MailShowArea_Send","_lt",10, 10+30+30, 100, 30)
		node.background = "Texture/box.png:15 15 15 15";
		node.text= "Send";
		node.font= "system;14;bold";
		_guihelper.SetFontColor(node, "255 0 0");
		_compose_cont:AddChild(node)
		
		local node = ParaUI.CreateUIObject("button","MailShowArea_Save","_lt",10+100+10, 10+30+30, 100, 30)
		node.background = "Texture/box.png:15 15 15 15";
		node.enable = true
		node.onclick = ";MyCompany.Orion.Mail.SaveComposedMail();"
		node.text= "Save";
		node.font= "system;14;bold";
		_guihelper.SetFontColor(node, "255 0 0");
		_compose_cont:AddChild(node)
		
		local node = ParaUI.CreateUIObject("button","MailShowArea_Discard","_lt",10+100+100+10+10, 10+30+30, 100, 30)
		node.background = "Texture/box.png:15 15 15 15";
		node.text= "Discard";
		node.onclick = string.format(";MyCompany.Orion.Mail.DiscardComposedMail();")
		node.font= "system;14;bold";
		_guihelper.SetFontColor(node, "255 0 0");
		_compose_cont:AddChild(node)
		-----------------------------------------------------------------------------
					
		local node = ParaUI.CreateUIObject("button","ComposeButtonArea","_lt",0, 0+100+100+100+100, 100, 50)
		node.background = "Texture/b_up.png:15 15 15 15";
		node.text= "Compose";
		node.enabled= true;
		node.onclick = string.format(";MyCompany.Orion.Mail.ShowMailTreeView(%q);", "compose_cont")
		node.font= "system;14;bold";
		_guihelper.SetFontColor(node, "255 255 255");
		groot:AddChild(node)
		
		
		
	--[[	local ctl = CommonCtrl.dropdownlistbox:new{
						name = "contactsdropdownlistbox",
						alignment = "_lt",
						left=0, top=0,
						width = 100,
						height = 26,
						parent = _groot,
						items = {"zhang", "wang", "li", "zhao", values=nil,},
						dropdownbutton_bg = "Texture/3DMapSystem/common/ThemeLightBlue/dropdownlistbox_dropdownbutton_bg.png: 4 4 4 4",
						AllowUserEdit = false,
						text = "standard",
						container_bg = "Texture/3DMapSystem/common/ThemeLightBlue/dropdownlistbox_container_bg.png: 4 4 4 4", 
						listbox_bg = "Texture/uncheckbox.png:4 4 4 4", -- list box background texture
					};
		--ctl:Show();
		]]
		local node = ParaUI.CreateUIObject("button","ContactsButtonArea","_lt",0, 0+100+100+100+100+100, 100, 50)
		node.background = "Texture/b_up.png:15 15 15 15";
		node.text= "Contacts";
		node.enabled= true;
		node.onclick = string.format(";MyCompany.Orion.Mail.ShowMailTreeView(%q);", "Contacts_Container")
		node.font= "system;14;bold";
		_guihelper.SetFontColor(node, "255 255 255");
		groot:AddChild(node)
		
		
		local contacts_container = ParaUI.CreateUIObject("container", "Contacts_Container","_fi",0,0,0,0)
		contacts_container.background = ""
		_groot:AddChild(contacts_container)
		contacts_container.visible = false
		
		NPL.load("(gl)script/ide/CheckBox.lua");
		Mail.contacts_table = {{name="A", email="a@gmail.com", picture="Texture/face/01.png"},
			{name="B", email="b@gmail.com", picture="Texture/face/02.png"},
			{name="C", email="c@gmail.com", picture="Texture/face/03.png"},
			{name="D", email="d@gmail.com", picture="Texture/face/04.png"}}
		
		for i = 1, #Mail.contacts_table do
			local ctl = CommonCtrl.checkbox:new{
				name = "contacts_checkbox"..tostring(i),
				alignment = "_lt",
				left = 10,
				top = 40 + 64*(i-1),
				width = 100,
				height = 30,
				parent = contacts_container,
				isChecked = false,
				text = Mail.contacts_table[i].name,
				checked_bg = "Texture/checkbox.png",
				unchecked_bg = "Texture/uncheckbox.png",
				unchecked_over_bg = "Texture/uncheckbox.png",
				
				oncheck = function (sCtrlName, checked)
--commonlib.echo(self.text)
					if(checked == false) then return end
					local ctl = CommonCtrl.GetControl(sCtrlName)
					if(ctl == nil) then return end
					
					local id = 0
					for k = 1, #Mail.contacts_table do
						if(Mail.contacts_table[k].name == ctl.text) then 
							id = k
							--break
						 end
						 --Mail.contacts_table[k].SetCheck(false)
					end
					if(id==0) then return end
					--_guihelper.MessageBox(Mail.contacts_table[id].email)
					local _container = ParaUI.GetUIObject("ShowContacts_Container")
					if(_container:IsValid() == true) then
						_container.visible = true
					else
						return
					end
					
					local _contact = ParaUI.GetUIObject("ShowContacts_Text")
					_contact.text = "Name:\n"..Mail.contacts_table[id].name.."\nEmail:\n"..Mail.contacts_table[id].email
					_contact.font= "system;14;bold";
					_guihelper.SetFontColor( _contact, "255 0 0")
					
					local _contact = ParaUI.GetUIObject("ShowContacts_Picture")
					_contact.zorder = 100
					_contact.background = Mail.contacts_table[id].picture
					
				end
				};
			ctl:Show(true);
		end
		
		local showcontacts_ctn = ParaUI.CreateUIObject("container", "ShowContacts_Container","_rt",-220, 10, 200, 200)
		contacts_container:AddChild(showcontacts_ctn)
		showcontacts_ctn.visible = false
						
		local showcontacts_txt = ParaUI.CreateUIObject("text", "ShowContacts_Text","_lt",0, 0, 90, 90)
		showcontacts_ctn:AddChild(showcontacts_txt)
		
		local showcontacts_pic = ParaUI.CreateUIObject("container", "ShowContacts_Picture","_lt",90, 0, 90, 90)
		showcontacts_pic.enabled = false
		showcontacts_ctn:AddChild(showcontacts_pic)
		
		local addcontacts_btn = ParaUI.CreateUIObject("button", "AddContacts_Button","_lt",10, 10, 90, 20)
		addcontacts_btn.background = "Texture/box.png:8 8 8 8"
		addcontacts_btn.text = "Add Contact"
		addcontacts_btn.onclick = string.format(";MyCompany.Orion.Mail.OnClickAddContactBtn(%q);", "Contacts_Container")
		contacts_container:AddChild(addcontacts_btn)
		
		local deletecontacts_btn = ParaUI.CreateUIObject("button", "DeleteContacts_Button","_lt",10+100, 10, 90, 20)
		deletecontacts_btn.background = "Texture/box.png:8 8 8 8"
		deletecontacts_btn.text = "Delete Contact"
		deletecontacts_btn.onclick = string.format(";MyCompany.Orion.Mail.OnClickDeleteContactBtn(%q);", "Contacts_Container")
		contacts_container:AddChild(deletecontacts_btn)
		
end

function Mail.OnClickAddContactBtn(container_name)
	
	table.insert(Mail.contacts_table, {name="张呈鹏", email="e@gmail.com", picture="Texture/face/05.png"}) 
	
	--Mail.contacts_table["e@gmail.com"] = {name="E", email="e@gmail.com", picture="Texture/face/05.png"};
	
	--{name="E", email="e@gmail.com", picture="Texture/face/05.png"}
	
	local _container = ParaUI.GetUIObject(container_name)
	if(_container == nil) then return end
	
	local i = #Mail.contacts_table
	
	local ctl = CommonCtrl.checkbox:new{
		name = "contacts_checkbox"..tostring(i),
		alignment = "_lt",
		left = 10,
		top = 40 + 64*(i-1),
		width = 100,
		height = 30,
		parent = _container,
		isChecked = false,
		text = Mail.contacts_table[i].name,
		oncheck = function (sCtrlName, checked)
					if(checked == false) then return end
					local ctl = CommonCtrl.GetControl(sCtrlName)
					if(ctl == nil) then return end
					
					local id = 0
					for k = 1, #Mail.contacts_table do
						if(Mail.contacts_table[k].name == ctl.text) then 
							id = k
							--break
						 end
						-- Mail.contacts_table[k].SetCheck(false)
					end
					if(id==0) then return end
					--_guihelper.MessageBox(Mail.contacts_table[id].email)
					local _container = ParaUI.GetUIObject("ShowContacts_Container")
					if(_container:IsValid() == true) then
						_container.visible = true
					else
						return
					end
					
					local _contact = ParaUI.GetUIObject("ShowContacts_Text")
					_contact.text = "Name:\n"..Mail.contacts_table[id].name.."\nEmail:\n"..Mail.contacts_table[id].email
					_contact.font= "system;14;bold";
					_guihelper.SetFontColor( _contact, "255 0 0")
					
					local _contact = ParaUI.GetUIObject("ShowContacts_Picture")
					_contact.zorder = 100
					_contact.background = Mail.contacts_table[id].picture
					
				end
		};
	ctl:Show(true);
	
end

function Mail.OnClickDeleteContactBtn(container_name)
	local k = #Mail.contacts_table 
	local p = k
	for i = 1, k do
		local ctl = CommonCtrl.GetControl("contacts_checkbox"..tostring(i))
		if(ctl and ctl.isChecked) then
			ctl:Show(false)
			table.remove(Mail.contacts_table, i) 
			k = k - 1
		end
	end
	
	for i = 1, p do
		local ctl = CommonCtrl.GetControl("contacts_checkbox"..tostring(i))
		if(ctl) then
			CommonCtrl.DeleteControl("contacts_checkbox"..tostring(i))
		end
	end
	
	local _container = ParaUI.GetUIObject(container_name)
	if(_container == nil) then return end
	
	for i = 1, #Mail.contacts_table do
		local ctl = CommonCtrl.checkbox:new{
			name = "contacts_checkbox"..tostring(i),
			alignment = "_lt",
			left = 10,
			top = 40 + 64*(i-1),
			width = 100,
			height = 30,
			parent = _container,
			isChecked = false,
			text = Mail.contacts_table[i].name,
			oncheck = function (sCtrlName, checked)
					if(checked == false) then return end
					local ctl = CommonCtrl.GetControl(sCtrlName)
					if(ctl == nil) then return end
					
					local id = 0
					for k = 1, #Mail.contacts_table do
						if(Mail.contacts_table[k].name == ctl.text) then 
							id = k
							--break
						 end
						 --Mail.contacts_table[k].SetCheck(false)
					end
					if(id==0) then return end
					--_guihelper.MessageBox(Mail.contacts_table[id].email)
					local _container = ParaUI.GetUIObject("ShowContacts_Container")
					if(_container:IsValid() == true) then
						_container.visible = true
					else
						return
					end
					
					local _contact = ParaUI.GetUIObject("ShowContacts_Text")
					_contact.text = "Name:\n"..Mail.contacts_table[id].name.."\nEmail:\n"..Mail.contacts_table[id].email
					_contact.font= "system;14;bold";
					_guihelper.SetFontColor( _contact, "255 0 0")
					
					local _contact = ParaUI.GetUIObject("ShowContacts_Picture")
					_contact.zorder = 100
					_contact.background = Mail.contacts_table[id].picture
					
				end
			};
		ctl:Show(true);
	end
end

--Show just one Mail in Inbox or Sent mail or Drafts or Spam
function Mail.ShowOneEmail(treeview_name, treenode_title, treenode_date)
	local ctl = CommonCtrl.GetControl(treeview_name);
	if(ctl) then ctl:Show(false) end

	local _ui = ParaUI.GetUIObject("TreeView_Orion_Mail_ShowOne")
	-- +TIP+: remember: ParaUI.GetUIObject will always return something (not nil), you only check the validiaty by IsValid()
	--		other assets in the engine following the same, characters, models, animations .etc.
	if(_ui) then
		_ui:GetChild("title").text = treenode_title 
		_ui:GetChild("date").text = treenode_date
		_ui.visible = true
	end
end

--to Store TreeViews that have ever been shown
local TreeViewOpenedNameTable = {}
--to Show TreeView

-- +TIP+: first of all this param ctlName is not actually ctlName, which "compose_cont" in a container ui object
--		you've mixed two different logics in the same functions, so the code looks a lot of if("compose_cont")
--		if you continue with that, the code will be "compose_cont"-ed

function Mail.ShowMailTreeView(ctlName)

	-- +TIP+: there is a logic between these two functions(ShowMailTreeView and ShowOneEmail) that 
	--		"ShowMailTreeView" close the "TreeView_Orion_Mail_ShowOne"
	--		"ShowOneEmail" close the TreeView containers
	--		that's not a wrong code. But if you depend on such schemes, you will maintain the logics between each pairs
	--		improve the functions
	
	local _ui = ParaUI.GetUIObject("TreeView_Orion_Mail_ShowOne")
	if(_ui.visible) then _ui.visible = false end
	
	local flag = false
	
	-- +TIP+: ctl is too far away from ctl:Show(true); and no nil check
	
	for i = 1, #TreeViewOpenedNameTable do
		if(TreeViewOpenedNameTable[i] == "compose_cont" or "Contacts_Container" == TreeViewOpenedNameTable[i]) then 
			local pg = ParaUI.GetUIObject(TreeViewOpenedNameTable[i])
			if(pg) then pg.visible = false end
		else
			local temp = CommonCtrl.GetControl(TreeViewOpenedNameTable[i])
			if(temp) then temp:Show(false) end
		end
		if(TreeViewOpenedNameTable[i] == ctlName) then flag = true end
	end
	
	if(not flag) then  table.insert(TreeViewOpenedNameTable, ctlName) end
	
	if("compose_cont" == ctlName or "Contacts_Container" == ctlName) then
		local pg = ParaUI.GetUIObject(ctlName)
		if(pg) then pg.visible = true end
	else
		local ctl = CommonCtrl.GetControl(ctlName);
		if(ctl) then ctl:Show(true) end
	end
	
end

--to Save the being Composed mail
function Mail.SaveComposedMail()
	local ctl = ParaUI.GetUIObject("MailShowArea_EditboxTo");
	local composed_mail_to = ctl.text
	
	ctl = ParaUI.GetUIObject("MailShowArea_EditboxSubject");
	local composed_mail_subject = ctl.text

	ctl = CommonCtrl.GetControl("MultiLineEditbox_Mail_Compose");
	local composed_mail_content = ctl:GetText()
	
	-- +TIP+: this is a typical should-use-string.format example
	
	local composed_mail = "to:"..composed_mail_to.."\r\nsubject:"..composed_mail_subject.."\r\ncontent:"..composed_mail_content
	
	-- +TIP+: i've seen this kind of comparing for many times, 0 == #composed_mail_to, "compose_cont" == ctlName, .etc.
	--		in C++, you will get a compilation error if the type don't match or invalid and more specifically you miss-type "==" by "="
	--		in lua/NPL, any assignment "=" operation in if statement will be stated as an error.
	--		IMHO, C++ code shouldn't depend on "compilation" for error checking
	
	if(0 == #composed_mail_to) then composed_mail_to = "unknown" end
	local f = ParaIO.open("mail/"..composed_mail_subject..".txt", "w")
	if(f:IsValid()) then
		f:writeline(composed_mail)
		f:close()
	end
end

--to Discard the being Composed mail
function Mail.DiscardComposedMail()
	local ctl = ParaUI.GetUIObject("MailShowArea_EditboxTo");
	if(ctl) then ctl.text = "" end
	
	ctl = ParaUI.GetUIObject("MailShowArea_EditboxSubject");
	if(ctl) then ctl.text = "" end

	ctl = CommonCtrl.GetControl("MultiLineEditbox_Mail_Compose");
	if(ctl) then ctl:SetText("") end
end