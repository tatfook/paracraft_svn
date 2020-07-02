--[[
Title:
Author(s):
Date: 
Note: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/tutorials/WDTest/HelloWorld.lua");
local Test = commonlib.gettable("WD.Test");
Test.Hello();
-------------------------------------------------------
]]

--[[
local Test = commonlib.gettable("WD.Test");
function Test.Hello()
	_guihelper.MessageBox("hello");
end

--]]
NPL.load("(gl)script/ide/IDE.lua");
NPL.load("(gl)script/config.lua");

local Test = commonlib.gettable("WD.Test");

function Test.onCheckChanged()
	_guihelper.MessageBox("call onCheckChanged");
end

function Test.InitDialog()
	--create dialog window for test
	local form = ParaUI.CreateUIObject("container","dlgInfo","_ctr",0,0,369,369);
	local form2 = ParaUI.CreateUIObject("container","dlgInfo2","_ctl",0,0,369,369);
	local pnlForm3 = ParaUI.CreateUIObject("container","pnlForm3","_ctt",0,0,369,369);


	NPL.load("(gl)script/ide/CheckBox.lua");
	local ctl = CommonCtrl.checkbox:new{
		name = "chkTest",
		alignment = "_lt",
		left = 0,
		top = 50,
		width = 150,
		height = 26,
		parent = form,
		isChecked = false,
		text = "check box",
		oncheck =  Test.onCheckChanged(),
	};
	ctl:Show();


	--attach dialog window to the root
	form:AttachToRoot();
	form2:AttachToRoot();
	pnlForm3:AttachToRoot();

	--RGBA arguments not use "," seperate eachother
	_guihelper.SetUIColor(form,"255 123 0 128");
	
	--create button at parent area on left top
	local btnLT = ParaUI.CreateUIObject("button","btnLT","_lt",0,0,71,31);
	btnLT.text = "Left Top";
	form:AddChild(btnLT);

	--create button at parent area on center top
	local btnCTT = ParaUI.CreateUIObject("button","btnCTT","_ctt",0,0,71,31);
	btnCTT.text = "Center Top";
	form:AddChild(btnCTT);

	--create button at parent area on right top
	local btnRT = ParaUI.CreateUIObject("button","btnRT","_rt",-71,0,71,31);
	btnRT.text = "Right Top";
	form:AddChild(btnRT);

	--create button at parent area on left center 
	local btnCTL = ParaUI.CreateUIObject("button","btnCTL","_ctl",0,0,71,31);
	btnCTL.text = "Center Left";
	form:AddChild(btnCTL);
	
	--create button at parent area on right center 
	local btnCTR = ParaUI.CreateUIObject("button","btnCTR","_ctr",0,0,71,31);
	btnCTR.text = "Center Right";
	form:AddChild(btnCTR);

	--create button at parent area on left bottom 
	local btnLB = ParaUI.CreateUIObject("button","btnLB","_lb",0,-31,71,31);
	btnLB.text = "Left Bottom";
	form:AddChild(btnLB);
	
	--create button at parent area on center bottom 
	local btnCTB = ParaUI.CreateUIObject("button","btnCTB","_ctb",0,0,71,31);
	btnCTB.text = "Center Bottom";
	form:AddChild(btnCTB);
	
	--create button at parent area on right bottom 
	local btnRB = ParaUI.CreateUIObject("button","btnRB","_rb",-71,-31,71,31);
	btnRB.text = "Right Bottom";
	form:AddChild(btnRB);

	--create button at parent area on middle top 
	local btnMT = ParaUI.CreateUIObject("button","btnMT","_mt",0,0,71,31);
	btnMT.text = "Middle Top";
	form2:AddChild(btnMT);

	--create button at parent area on middle left 
	local btnML = ParaUI.CreateUIObject("button","btnML","_ml",0,0,71,31);
	btnML.text = "Middle Left";
	form2:AddChild(btnML);

	--create button at parent area on middle right 
	local btnMR = ParaUI.CreateUIObject("button","btnMR","_mr",0,0,71,31);
	btnMR.text = "Middle Right";
	form2:AddChild(btnMR);

	--create button at parent area on middle bottom
	local btnMB = ParaUI.CreateUIObject("button","btnMB","_mb",0,0,71,31);
	btnMB.text = "Middle Bottom";
	form2:AddChild(btnMB);
	
	--create button at parent area on full area
	local btnFill = ParaUI.CreateUIObject("button","btnFill","_ctl",0,0,160,35);
	btnFill.text = "Click me,Drag and Drop";
	pnlForm3:AddChild(btnFill);
	pnlForm3.receivedrag= true;
	btnFill.candrag = true;

	local lblCoord = ParaUI.CreateUIObject("text","lblCoord","_lt",0,0,330,35);
	pnlForm3:AddChild(lblCoord);
	lblCoord.color = "212 0 0 138"; 
	lblCoord.text= "just a label";

	--register window's events
	pnlForm3.onmousemove= ";WD.Test.pnlForm3_onMouseMove();";
	btnFill.onmousedown= ";WD.Test.btnFill_onMouseDown();";
	btnFill.onmouseup= ";WD.Test.btnFill_onMouseUp();";
	btnFill.onmouseenter= ";WD.Test.btnFill_onMouseEnter();";
	btnFill.onmouseleave= ";WD.Test.btnFill_onMouseLeave();";
	btnFill.background= "Texture/Taurus/Button_Normal_Large.png;0,0,0,0";
	
	btnClose.onclick = ";ParaUI.Destroy(\"dlgInfo\");";

	btnClose = ParaUI.CreateUIObject("button","btnClose","_ct",-71/2,-31/2,71,31);
	btnClose.text = "Close";
	--btnClose.background = "Texture/whitedot.png;0 0 0 0";
	btnClose.tooltip = "Close Window";

	form:AddChild(btnClose);

end

local isDraged = false;

function Test.btnFill_onMouseEnter()
	ParaUI.GetUIObject("btnFill").background= "Texture/Taurus/Button_Highlight_Large.png;0 0 4 4: 2 2 2 2";
end

function Test.btnFill_onMouseLeave()
	ParaUI.GetUIObject("btnFill").background= "Texture/Taurus/Button_Normal_Large.png;0 0 0 0";
end
 
function Test.pnlForm3_onMouseMove()
	local mouseX,mouseY  = ParaUI.GetMousePosition();
	ParaUI.GetUIObject("lblCoord").text = string.format("relative application work area x/y:%.5f,%.5f",mouseX,mouseY);
end

function Test.btnFill_onMouseDown()
	--isDraged = true;
	print(isDraged);
	--_guihelper:MessageBox("beginning drag.");
end

function Test.btnFill_onMouseUp()
	--if(isDraged == true) then
		--local x,y = ParaUI.GetMousePosition();
		_guihelper:MessageBox("is droped.");
		--ParaUI.GetUIObject("btnFill").position = string.format("%.3f,%.3f,%.3f,%.3f", x,y,100,35);
	--end
	--reset drag state of button
	--isDraged = false;
end

local main_state = nil;
local function activate()
	if(main_state == 0) then
		log("tick\n");
	elseif(main_state == nil) then
		main_state = 0;
		Test.InitDialog();
	end
end

NPL.this(activate);
