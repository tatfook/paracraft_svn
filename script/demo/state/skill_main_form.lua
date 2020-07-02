local function activate()
local __this,__parent,__font,__texture;
if(_demo_state_openedwin~="skill_container")then
	if(_demo_state_openedwin~=nil)then
		ParaUI.Destroy(_demo_state_openedwin);
	end
_demo_state_openedwin="skill_container";
	
	_guihelper.CheckRadioButtons( _demo_person_pages, "person_skills", "255 0 0");
	
__this=ParaUI.CreateUIObject("container","skill_container", "_lt",30,60,299,390);
__parent=ParaUI.GetUIObject("demo_main");__parent:AddChild(__this);
__this.scrollable=false;
__this.background="Texture/dxutcontrols.dds;13 124 228 141";
__this.candrag=false;
texture=__this:GetTexture("background");
texture.transparency=0;--[0-255]
__this=ParaUI.CreateUIObject("button","button2", "_lt",268,44,28,90);
__parent=ParaUI.GetUIObject("skill_container");__parent:AddChild(__this);
__this.text="技\n能\n熟\n练";
__this.background="Texture/b_2_up.png;";

__this=ParaUI.CreateUIObject("button","button3", "_lt",268,134,28,90);
__parent=ParaUI.GetUIObject("skill_container");__parent:AddChild(__this);
__this.text="魔\n法\n技\n能";
__this.background="Texture/b_2_up.png;";

NPL.activate("(gl)script/demo/state/skill_1_form.lua");	
end
end
NPL.this(activate);
