local function activate()
local __this,__parent,__font,__texture;
if(_demo_state_openedwin~="state_cintainer")then
	if(_demo_state_openedwin~=nil)then
		ParaUI.Destroy(_demo_state_openedwin);
	end

_demo_state_openedwin="state_cintainer";
	
	_guihelper.CheckRadioButtons( _demo_person_pages, "person_state", "255 0 0");
	
	
__this=ParaUI.CreateUIObject("container","state_cintainer", "_lt",30,60,299,390);
__parent=ParaUI.GetUIObject("demo_main");__parent:AddChild(__this);
__this.scrollable=false;
__this.background="Texture/dxutcontrols.dds;13 124 228 141";
__this.candrag=false;
texture=__this:GetTexture("background");
texture.transparency=0;--[0-255]
__this=ParaUI.CreateUIObject("container","state_c1", "_lt",8,35,280,90);
__parent=ParaUI.GetUIObject("state_cintainer");__parent:AddChild(__this);
__this.scrollable=false;
__this.background="Texture/dxutcontrols.dds;13 124 228 141";
__this.candrag=false;
texture=__this:GetTexture("background");
texture.transparency=0;--[0-255]
__this=ParaUI.CreateUIObject("text","text6", "_lt",18,15,59,22);
__parent=ParaUI.GetUIObject("state_c1");__parent:AddChild(__this);
__this.text="力量：";
__this.autosize=true;
__this.background="Texture/dxutcontrols.dds;0 0 0 0";
__this.candrag=false;
texture=__this:GetTexture("background");
texture.transparency=127;--[0-255]

__this.onclick="";
__this.onmousehover="";
__this=ParaUI.CreateUIObject("text","text7", "_lt",145,16,59,22);
__parent=ParaUI.GetUIObject("state_c1");__parent:AddChild(__this);
__this.text="敏捷：";
__this.autosize=true;
__this.background="Texture/dxutcontrols.dds;0 0 0 0";
__this.candrag=false;
texture=__this:GetTexture("background");
texture.transparency=127;--[0-255]

__this.onclick="";
__this.onmousehover="";
__this=ParaUI.CreateUIObject("text","text8", "_lt",18,46,59,22);
__parent=ParaUI.GetUIObject("state_c1");__parent:AddChild(__this);
__this.text="体力：";
__this.autosize=true;
__this.background="Texture/dxutcontrols.dds;0 0 0 0";
__this.candrag=false;
texture=__this:GetTexture("background");
texture.transparency=127;--[0-255]

__this.onclick="";
__this.onmousehover="";
__this=ParaUI.CreateUIObject("text","text9", "_lt",145,44,59,22);
__parent=ParaUI.GetUIObject("state_c1");__parent:AddChild(__this);
__this.text="智力：";
__this.autosize=true;
__this.background="Texture/dxutcontrols.dds;0 0 0 0";
__this.candrag=false;
texture=__this:GetTexture("background");
texture.transparency=127;--[0-255]

__this.onclick="";
__this.onmousehover="";
__this=ParaUI.CreateUIObject("text","text4", "_lt",12,11,76,22);
__parent=ParaUI.GetUIObject("state_cintainer");__parent:AddChild(__this);
__this.text="基本属性";
__this.autosize=true;
__this.background="Texture/dxutcontrols.dds;0 0 0 0";
__this.candrag=false;
texture=__this:GetTexture("background");
texture.transparency=127;--[0-255]

__this.onclick="";
__this.onmousehover="";
__this=ParaUI.CreateUIObject("text","text5", "_lt",12,143,76,22);
__parent=ParaUI.GetUIObject("state_cintainer");__parent:AddChild(__this);
__this.text="扩展属性";
__this.autosize=true;
__this.background="Texture/dxutcontrols.dds;0 0 0 0";
__this.candrag=false;
texture=__this:GetTexture("background");
texture.transparency=127;--[0-255]

__this.onclick="";
__this.onmousehover="";
__this=ParaUI.CreateUIObject("container","state_c2", "_lt",10,168,280,180);
__parent=ParaUI.GetUIObject("state_cintainer");__parent:AddChild(__this);
__this.scrollable=false;
__this.background="Texture/dxutcontrols.dds;13 124 228 141";
__this.candrag=false;
texture=__this:GetTexture("background");
texture.transparency=0;--[0-255]
__this=ParaUI.CreateUIObject("text","text10", "_lt",20,13,76,22);
__parent=ParaUI.GetUIObject("state_c2");__parent:AddChild(__this);
__this.text="攻击力：";
__this.autosize=true;
__this.background="Texture/dxutcontrols.dds;0 0 0 0";
__this.candrag=false;
texture=__this:GetTexture("background");
texture.transparency=127;--[0-255]

__this.onclick="";
__this.onmousehover="";
__this=ParaUI.CreateUIObject("text","text11", "_lt",144,13,76,22);
__parent=ParaUI.GetUIObject("state_c2");__parent:AddChild(__this);
__this.text="命中率：";
__this.autosize=true;
__this.background="Texture/dxutcontrols.dds;0 0 0 0";
__this.candrag=false;
texture=__this:GetTexture("background");
texture.transparency=127;--[0-255]

__this.onclick="";
__this.onmousehover="";
__this=ParaUI.CreateUIObject("text","text12", "_lt",21,40,76,22);
__parent=ParaUI.GetUIObject("state_c2");__parent:AddChild(__this);
__this.text="爆击率：";
__this.autosize=true;
__this.background="Texture/dxutcontrols.dds;0 0 0 0";
__this.candrag=false;
texture=__this:GetTexture("background");
texture.transparency=127;--[0-255]

__this.onclick="";
__this.onmousehover="";
__this=ParaUI.CreateUIObject("text","text13", "_lt",22,66,76,22);
__parent=ParaUI.GetUIObject("state_c2");__parent:AddChild(__this);
__this.text="防御力：";
__this.autosize=true;
__this.background="Texture/dxutcontrols.dds;0 0 0 0";
__this.candrag=false;
texture=__this:GetTexture("background");
texture.transparency=127;--[0-255]

__this.onclick="";
__this.onmousehover="";
__this=ParaUI.CreateUIObject("text","text14", "_lt",146,67,76,22);
__parent=ParaUI.GetUIObject("state_c2");__parent:AddChild(__this);
__this.text="隔挡率：";
__this.autosize=true;
__this.background="Texture/dxutcontrols.dds;0 0 0 0";
__this.candrag=false;
texture=__this:GetTexture("background");
texture.transparency=127;--[0-255]

__this.onclick="";
__this.onmousehover="";
__this=ParaUI.CreateUIObject("text","text15", "_lt",21,93,76,22);
__parent=ParaUI.GetUIObject("state_c2");__parent:AddChild(__this);
__this.text="躲避率：";
__this.autosize=true;
__this.background="Texture/dxutcontrols.dds;0 0 0 0";
__this.candrag=false;
texture=__this:GetTexture("background");
texture.transparency=127;--[0-255]

__this.onclick="";
__this.onmousehover="";
__this=ParaUI.CreateUIObject("text","text16", "_lt",22,119,110,22);
__parent=ParaUI.GetUIObject("state_c2");__parent:AddChild(__this);
__this.text="魔法攻击力：";
__this.autosize=true;
__this.background="Texture/dxutcontrols.dds;0 0 0 0";
__this.candrag=false;
texture=__this:GetTexture("background");
texture.transparency=127;--[0-255]

__this.onclick="";
__this.onmousehover="";
__this=ParaUI.CreateUIObject("text","text17", "_lt",22,145,110,22);
__parent=ParaUI.GetUIObject("state_c2");__parent:AddChild(__this);
__this.text="魔法防御力：";
__this.autosize=true;
__this.background="Texture/dxutcontrols.dds;0 0 0 0";
__this.candrag=false;
texture=__this:GetTexture("background");
texture.transparency=127;--[0-255]

__this.onclick="";
__this.onmousehover="";
end
end
NPL.this(activate);
