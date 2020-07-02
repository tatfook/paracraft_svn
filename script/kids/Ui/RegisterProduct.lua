--[[
Title: Collect your information and register product via web service
Author(s): LiXizhi
Date: 2007/4/30
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/Ui/RegisterProduct.lua");
RegisterProduct.Show("1234-1234-1234-1234");
-------------------------------------------------------
]]
-- common control library
NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/network/LoginBox.lua");

local L = CommonCtrl.Locale("KidsUI");
if(not RegisterProduct) then RegisterProduct={}; end

-- web service address
RegisterProduct.webservice =  L"RegProduct.asmx";
--RegisterProduct.webservice =  "http://lixizhi/WebServiceSite/RegProduct.asmx"; -- just for testing locally.

--appearance
RegisterProduct.editbox_bg = "Texture/kidui/explorer/editbox128x32.png"
RegisterProduct.listbox_bg = "Texture/kidui/explorer/listbox_bg.png"
RegisterProduct.dropdownarrow_bg = "Texture/kidui/explorer/dropdown_arrow.png"
RegisterProduct.dropdownlist_cont_bg = "Texture/kidui/explorer/editbox256x32.png"

RegisterProduct.ProductKey = "";

function RegisterProduct.Show(ProductKey)
	RegisterProduct.ProductKey = ProductKey;
	if(not kids_db.User.IsAuthenticated) then
		_guihelper.MessageBox(L"In order to activate your product, you need to login to our community web site", function ()
			NPL.load("(gl)script/network/LoginBox.lua");
			LoginBox.Show(true, RegisterProduct.Show_imp);
		end)
	else
		RegisterProduct.Show_imp();
	end	
end

-- actual implementation
function RegisterProduct.Show_imp()
	local ProductKey = RegisterProduct.ProductKey;
	if(ProductKey == nil) then ProductKey = "" end
	
	local _this,_parent;
	
	_this=ParaUI.GetUIObject("RegisterProduct");
	if(_this:IsValid() == false) then
		
		local width, height = 488, 464;
		-- RegisterProduct
		_this = ParaUI.CreateUIObject("container", "RegisterProduct", "_ct", -width/2, -height/2, width, height)
		_this.background="Texture/net_bg.png;0 0 470 395";
		_this:AttachToRoot();
		_this:SetTopLevel(true); -- _this.candrag and TopLevel and not be true simultanously 
		_parent = _this;

		_this = ParaUI.CreateUIObject("text", "label1", "_lt", 25, 68, 100, 16)
		_this.text = L"User name";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label2", "_lt", 25, 247, 100, 16)
		_this.text = L"Age";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label10", "_lt", 23, 215, 408, 16)
		_this.text = L"For better customer services, please also provide:";
		_this:GetFont("text").color = "65 105 225";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label7", "_lt", 13, 25, 424, 16)
		_this.text = L"Please help us fill following required customer info";
		_this:GetFont("text").color = "255 255 100";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label4", "_lt", 25, 280, 64, 16)
		_this.text = L"Country";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("imeeditbox", "RegProduct_Name", "_lt", 135, 65, 193, 26)
		_this.background=RegisterProduct.editbox_bg;
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label5", "_lt", 25, 100, 100, 16)
		_this.text = L"Product Key";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label3", "_lt", 25, 133, 100, 16)
		_this.text = L"Email";
		_parent:AddChild(_this);
	
		_this = ParaUI.CreateUIObject("text", "label6", "_lt", 25, 316, 264, 16)
		_this.text = L"Where you heard of this product?";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("editbox", "RegProduct_Key", "_lt", 135, 97, 193, 26)
		_this.background=RegisterProduct.editbox_bg;
		_this.text = tostring(ProductKey);
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("imeeditbox", "RegProduct_Email", "_lt", 135, 130, 193, 26)
		_this.background=RegisterProduct.editbox_bg;
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("imeeditbox", "RegProduct_Country", "_lt", 135, 277, 193, 26)
		_this.background=RegisterProduct.editbox_bg;
		_parent:AddChild(_this);

		NPL.load("(gl)script/ide/dropdownlistbox.lua");
		local ctl = CommonCtrl.dropdownlistbox:new{
			name = "RegProduct_AgeComboBox",
			alignment = "_lt",
			left = 135,
			top = 244,
			width = 193,
			height = 24,
			dropdownheight = 106,
 			parent = _parent,
 			container_bg = RegisterProduct.dropdownlist_cont_bg,
			editbox_bg = "Texture/whitedot.png;0 0 0 0",
			dropdownbutton_bg = RegisterProduct.dropdownarrow_bg,
			listbox_bg = RegisterProduct.listbox_bg,
			text = "",
			items = {"0-7", "7-12", "12-18", "18-30", "30-50", "50-100", },
		};
		ctl:Show();

		NPL.load("(gl)script/ide/dropdownlistbox.lua");
		local ctl = CommonCtrl.dropdownlistbox:new{
			name = "RegProduct_WhereHeardOfCombo",
			alignment = "_lt",
			left = 28,
			top = 335,
			width = 300,
			height = 24,
			dropdownheight = 106,
 			parent = _parent,
 			container_bg = RegisterProduct.dropdownlist_cont_bg,
			editbox_bg = "Texture/whitedot.png;0 0 0 0",
			dropdownbutton_bg = RegisterProduct.dropdownarrow_bg,
			listbox_bg = RegisterProduct.listbox_bg,
			text = "",
			items = L:GetTable("RegProduct_WhereHeardOfCombo"),
		};
		ctl:Show();

		_this = ParaUI.CreateUIObject("button", "button1", "_lb", 28, -67, 105, 28)
		_this.text = L"register";
		_this.onclick=";RegisterProduct.OnClickRegister();";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button2", "_rb", -156, -67, 105, 28)
		_this.text = L"Cancel";
		_this.onclick=";RegisterProduct.OnDestory();";
		_parent:AddChild(_this);

		NPL.load("(gl)script/ide/CheckBox.lua");
		local ctl = CommonCtrl.checkbox:new{
			name = "RegProduct_ReceiveUpdates_CheckBox",
			alignment = "_lt",
			left = 28,
			top = 169,
			width = 411,
			height = 20,
			parent = _parent,
			isChecked = true,
			text = L"I would like to receive product news and updates",
		};
		ctl:Show();
		
		KidsUI.PushState({name = "RegisterProduct", OnEscKey = RegisterProduct.OnDestory});
	else
		RegisterProduct.OnDestory();
	end	
end

-- destory the control
function RegisterProduct.OnDestory()
	KidsUI.PopState("RegisterProduct");
	ParaUI.Destroy("RegisterProduct");
end

-- send a web service to collect user data
function RegisterProduct.OnClickRegister()
	--  collect data
	local allcontent = "";
	allcontent = allcontent..string.format("Country = %s\r\n", ParaUI.GetUIObject("RegProduct_Country").text);
	local ctl = CommonCtrl.GetControl("RegProduct_ReceiveUpdates_CheckBox");
	if(ctl ~=nil) then
		allcontent = allcontent..string.format("ReceiveUpdates = %s\r\n", tostring(ctl:GetCheck()));
	end
	local ctl = CommonCtrl.GetControl("RegProduct_AgeComboBox");
	if(ctl ~=nil) then
		allcontent = allcontent..string.format("Age = %s\r\n", tostring(ctl:GetText()));
	end
	local ctl = CommonCtrl.GetControl("RegProduct_WhereHeardOfCombo");
	if(ctl ~=nil) then
		allcontent = allcontent..string.format("WhereHeardOf = %s\r\n", tostring(ctl:GetText()));
	end
	
	local msg = {
		--username = ParaUI.GetUIObject("RegProduct_Name").text,
		username = kids_db.User.Name,
		Password = kids_db.User.Password,
        ProductKey = ParaUI.GetUIObject("RegProduct_Key").text,
        Email = ParaUI.GetUIObject("RegProduct_Email").text,
        AllContent = allcontent,
    }
    if(msg.username == "" or msg.ProductKey == "" or msg.Email == "" or msg.AllContent == "" ) then
		_guihelper.MessageBox((L"Please fill in all required fields."));	
		return
    end
    log(RegisterProduct.webservice.."  ")
    --log(commonlib.serialize(msg).." \r\n");
    
	-- send out the web serivce
	NPL.RegisterWSCallBack(RegisterProduct.webservice, "RegisterProduct.RegProduct_Callback();");
	NPL.activate(RegisterProduct.webservice, msg);
		
	_guihelper.MessageBox((L"Your product registration information is submitted."));
	ParaUI.Destroy("RegisterProduct");
end

-- web service returned 
function RegisterProduct.RegProduct_Callback()
	if(msg == true) then
		
		if(not kids_db.User.userinfo.IsProductRegistered) then
			kids_db.User.userinfo.IsProductRegistered = true;
			kids_db.User.SaveUserInfo();
		end	
		_guihelper.MessageBox(L"Thank you very much. We have received your product registration information.".."\r\n\r\n")
	else
		_guihelper.MessageBox(L"We have received your product registration information. But there is an error during processing.".."\r\n\r\n")
	end	
end