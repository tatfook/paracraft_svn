local function activate()
local __this,__parent,__font,__texture;
__this=ParaUI.CreateUIObject("container","container1", "_lt",8,20,260,340);
__parent=ParaUI.GetUIObject("skill_container");__parent:AddChild(__this);
__this.scrollable=false;
__this.background="Texture/skill_bro.png";
__this.candrag=false;
texture=__this:GetTexture("background");
texture.transparency=127;--[0-255]
end
NPL.this(activate);
