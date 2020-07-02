NPL.load("(gl)script/ide/gui_helper.lua");
_demo_person_pages = {"person_state", "person_items", "person_skills", "person_career"};

local function activate()
local __this,__parent,__font,__texture;

local temp = ParaUI.GetUIObject("demo_main");
if (temp:IsValid() == false) then

__this=ParaUI.CreateUIObject("container","demo_main", "_lt",50,80,360,540);
__this:AttachToRoot();
__this.scrollable=false;
__this.background="Texture/user_bro.png";
__this.candrag=true;

__this=ParaUI.CreateUIObject("button","person_state", "_lt",117,30,60,30);
__parent=ParaUI.GetUIObject("demo_main");__parent:AddChild(__this);
__this.text="状态";
__this.background="Texture/b_up.png;";
__this.onclick="(gl)script/demo/state/state_form.lua";

__this=ParaUI.CreateUIObject("button","person_items", "_lt",50,30,60,30);
__parent=ParaUI.GetUIObject("demo_main");__parent:AddChild(__this);
__this.text="装备";
__this.background="Texture/b_up.png;";
__this.onclick="(gl)script/demo/state/item_form.lua";

__this=ParaUI.CreateUIObject("button","person_skills", "_lt",184,30,60,30);
__parent=ParaUI.GetUIObject("demo_main");__parent:AddChild(__this);
__this.text="技能";
__this.background="Texture/b_up.png;";
__this.onclick="(gl)script/demo/state/skill_main_form.lua";

__this=ParaUI.CreateUIObject("button","person_career", "_lt",251,30,60,30);
__parent=ParaUI.GetUIObject("demo_main");__parent:AddChild(__this);
__this.text="事业";
__this.background="Texture/b_up.png;";

__this=ParaUI.CreateUIObject("button","close_button", "_lt",240,460,60,30);
__parent=ParaUI.GetUIObject("demo_main");__parent:AddChild(__this);
__this.text="关闭";
__this.background="Texture/b_up.png;";
__this.onclick="(gl)empty.lua;ParaUI.Destroy(\"demo_main\");_demo_state_openedwin=nil;";
__this.candrag=false;

NPL.activate("(gl)script/demo/state/item_form.lua");	

end
end
NPL.this(activate);
