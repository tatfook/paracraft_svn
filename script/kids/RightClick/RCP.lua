--  编辑模式下右键点击人物产生画面

local function activate()
local __this,__parent,__font,__texture;

--  传入参数: 右键点击人物中心所在的屏幕位置 x,y
local x = 200;
local y = 200;

--  调整人物大小
__this=ParaUI.CreateUIObject("button","RCP_size", "_lt",x - 53,y + 54,70,30);
__this:AttachToRoot();
__this.text="大小";
__this.background="Texture/b_up.png;0 0 128 32";
__this.onclick="";
__this.candrag=false;
__this.font="System;15;bold;true";

--  调整人物朝向
__this=ParaUI.CreateUIObject("button","RCP_direction", "_lt",x + 53,y + 54,70,30);
__this:AttachToRoot();
__this.text="朝向";
__this.background="Texture/b_up.png;0 0 128 32";
__this.onclick="";
__this.candrag=false;
__this.font="System;15;bold;true";

--  调整人物外貌
__this=ParaUI.CreateUIObject("button","RCP_skin", "_lt",x - 86,y - 13,70,30);
__this:AttachToRoot();
__this.text="外貌";
__this.background="Texture/b_up.png;0 0 128 32";
__this.onclick="";
__this.candrag=false;
__this.font="System;15;bold;true";

--  调整人物对话
__this=ParaUI.CreateUIObject("button","RCP_words", "_lt",x + 86,y - 13,70,30);
__this:AttachToRoot();
__this.text="对话";
__this.background="Texture/b_up.png;0 0 128 32";
__this.onclick="(gl)script/kids/RightClick/RCP_words.lua";
__this.candrag=false;
__this.font="System;15;bold;true";

--  调整人物动作
__this=ParaUI.CreateUIObject("button","RCP_action", "_lt",x,y - 68,70,30);
__this:AttachToRoot();
__this.text="动作";
__this.background="Texture/b_up.png;0 0 128 32";
__this.onclick="(gl)script/kids/RightClick/RCP_action.lua";
__this.candrag=false;
__this.font="System;15;bold;true";

end
NPL.this(activate);
