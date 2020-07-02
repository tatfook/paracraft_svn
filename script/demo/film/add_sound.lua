local function activate()
local __this,__parent,__font,__texture;

__this=ParaUI.CreateUIObject("container","sound_main", "_lt",460,120,360,350);
__this:AttachToRoot();
__this.scrollable=false;
__this.background="Texture/add_bro.png";
__this.candrag=true;
texture=__this:GetTexture("background");
texture.transparency=255;--[0-255]


__this.onclick="";
__this.onmousehover="";
__this=ParaUI.CreateUIObject("text","text", "_lt",25,23,100,22);
__parent=ParaUI.GetUIObject("sound_main");__parent:AddChild(__this);
__this.text="添加配音：";
__this.autosize=true;
__this.background="Texture/dxutcontrols.dds;0 0 0 0";
__this.candrag=false;
texture=__this:GetTexture("background");
texture.transparency=255;--[0-255]

-- 一行的开始
__this=ParaUI.CreateUIObject("button","button4", "_lt",30,50,40,40);
__parent=ParaUI.GetUIObject("sound_main");__parent:AddChild(__this);
__this.background="Texture/skill/item.png";
__this.onclick="";
__this.candrag=false;


__this=ParaUI.CreateUIObject("button","button4", "_lt",80,50,40,40);
__parent=ParaUI.GetUIObject("sound_main");__parent:AddChild(__this);
__this.background="Texture/skill/item.png";
__this.onclick="";
__this.candrag=false;


__this=ParaUI.CreateUIObject("button","button4", "_lt",130,50,40,40);
__parent=ParaUI.GetUIObject("sound_main");__parent:AddChild(__this);
__this.background="Texture/skill/item.png";
__this.onclick="";
__this.candrag=false;


__this=ParaUI.CreateUIObject("button","button4", "_lt",180,50,40,40);
__parent=ParaUI.GetUIObject("sound_main");__parent:AddChild(__this);
__this.background="Texture/skill/item.png";
__this.onclick="";
__this.candrag=false;


__this=ParaUI.CreateUIObject("button","button4", "_lt",230,50,40,40);
__parent=ParaUI.GetUIObject("sound_main");__parent:AddChild(__this);
__this.background="Texture/skill/item.png";
__this.onclick="";
__this.candrag=false;


__this=ParaUI.CreateUIObject("button","button4", "_lt",280,50,40,40);
__parent=ParaUI.GetUIObject("sound_main");__parent:AddChild(__this);
__this.background="Texture/skill/item.png";
__this.onclick="";
__this.candrag=false;


-- 一行的结束

-- 一行的开始
__this=ParaUI.CreateUIObject("button","button4", "_lt",30,100,40,40);
__parent=ParaUI.GetUIObject("sound_main");__parent:AddChild(__this);
__this.background="Texture/skill/item.png";
__this.onclick="";
__this.candrag=false;


__this=ParaUI.CreateUIObject("button","button4", "_lt",80,100,40,40);
__parent=ParaUI.GetUIObject("sound_main");__parent:AddChild(__this);
__this.background="Texture/skill/item.png";
__this.onclick="";
__this.candrag=false;


__this=ParaUI.CreateUIObject("button","button4", "_lt",130,100,40,40);
__parent=ParaUI.GetUIObject("sound_main");__parent:AddChild(__this);
__this.background="Texture/skill/item.png";
__this.onclick="";
__this.candrag=false;


__this=ParaUI.CreateUIObject("button","button4", "_lt",180,100,40,40);
__parent=ParaUI.GetUIObject("sound_main");__parent:AddChild(__this);
__this.background="Texture/skill/item.png";
__this.onclick="";
__this.candrag=false;


__this=ParaUI.CreateUIObject("button","button4", "_lt",230,100,40,40);
__parent=ParaUI.GetUIObject("sound_main");__parent:AddChild(__this);
__this.background="Texture/skill/item.png";
__this.onclick="";
__this.candrag=false;


__this=ParaUI.CreateUIObject("button","button4", "_lt",280,100,40,40);
__parent=ParaUI.GetUIObject("sound_main");__parent:AddChild(__this);
__this.background="Texture/skill/item.png";
__this.onclick="";
__this.candrag=false;


-- 一行的结束

-- 一行的开始
__this=ParaUI.CreateUIObject("button","button4", "_lt",30,150,40,40);
__parent=ParaUI.GetUIObject("sound_main");__parent:AddChild(__this);
__this.background="Texture/skill/item.png";
__this.onclick="";
__this.candrag=false;


__this=ParaUI.CreateUIObject("button","button4", "_lt",80,150,40,40);
__parent=ParaUI.GetUIObject("sound_main");__parent:AddChild(__this);
__this.background="Texture/skill/item.png";
__this.onclick="";
__this.candrag=false;


__this=ParaUI.CreateUIObject("button","button4", "_lt",130,150,40,40);
__parent=ParaUI.GetUIObject("sound_main");__parent:AddChild(__this);
__this.background="Texture/skill/item.png";
__this.onclick="";
__this.candrag=false;


__this=ParaUI.CreateUIObject("button","button4", "_lt",180,150,40,40);
__parent=ParaUI.GetUIObject("sound_main");__parent:AddChild(__this);
__this.background="Texture/skill/item.png";
__this.onclick="";
__this.candrag=false;


__this=ParaUI.CreateUIObject("button","button4", "_lt",230,150,40,40);
__parent=ParaUI.GetUIObject("sound_main");__parent:AddChild(__this);
__this.background="Texture/skill/item.png";
__this.onclick="";
__this.candrag=false;


__this=ParaUI.CreateUIObject("button","button4", "_lt",280,150,40,40);
__parent=ParaUI.GetUIObject("sound_main");__parent:AddChild(__this);
__this.background="Texture/skill/item.png";
__this.onclick="";
__this.candrag=false;


-- 一行的结束

-- 一行的开始
__this=ParaUI.CreateUIObject("button","button4", "_lt",30,200,40,40);
__parent=ParaUI.GetUIObject("sound_main");__parent:AddChild(__this);
__this.background="Texture/skill/item.png";
__this.onclick="";
__this.candrag=false;


__this=ParaUI.CreateUIObject("button","button4", "_lt",80,200,40,40);
__parent=ParaUI.GetUIObject("sound_main");__parent:AddChild(__this);
__this.background="Texture/skill/item.png";
__this.onclick="";
__this.candrag=false;


__this=ParaUI.CreateUIObject("button","button4", "_lt",130,200,40,40);
__parent=ParaUI.GetUIObject("sound_main");__parent:AddChild(__this);
__this.background="Texture/skill/item.png";
__this.onclick="";
__this.candrag=false;


__this=ParaUI.CreateUIObject("button","button4", "_lt",180,200,40,40);
__parent=ParaUI.GetUIObject("sound_main");__parent:AddChild(__this);
__this.background="Texture/skill/item.png";
__this.onclick="";
__this.candrag=false;


__this=ParaUI.CreateUIObject("button","button4", "_lt",230,200,40,40);
__parent=ParaUI.GetUIObject("sound_main");__parent:AddChild(__this);
__this.background="Texture/skill/item.png";
__this.onclick="";
__this.candrag=false;


__this=ParaUI.CreateUIObject("button","button4", "_lt",280,200,40,40);
__parent=ParaUI.GetUIObject("sound_main");__parent:AddChild(__this);
__this.background="Texture/skill/item.png";
__this.onclick="";
__this.candrag=false;


-- 一行的结束



__this=ParaUI.CreateUIObject("button","close_button", "_lt",240,270,60,30);
__parent=ParaUI.GetUIObject("sound_main");__parent:AddChild(__this);
__this.text="关闭";
__this.background="Texture/b_up.png;";
__this.onclick="(gl)empty.lua;ParaUI.Destroy(\"sound_main\");";

end
NPL.this(activate);
 