--[[
Title: FireMasterCanvas
Author(s): Leio
Date: 2009/7/31
Desc: 

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/FireMaster/FireMasterCanvas.lua");
Map3DSystem.App.FireMaster.FireMasterCanvas.ShowPage();
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemUI/FireMaster/FireMasterLogic.lua");
local FireMasterCanvas ={
	name = "FireMasterCanvas",
	gameLogic = nil,
	root_sprite = nil,
	progressbar = nil,
	cur_score =  0,
	cur_score_bean = 0,
	cur_score_zhu = 0,
}  
commonlib.setfield("Map3DSystem.App.FireMaster.FireMasterCanvas",FireMasterCanvas);
function FireMasterCanvas.ClosePage()
	
	-- Leio: i manually hook the close page action to perform some quest requirements
	local msg = { aries_type = "OnFireMasterGameClose"};
	msg.wndName = "main";
	CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", msg)
	
	local self = FireMasterCanvas;
	if(self.gameLogic)then
		self.gameLogic:Stop();

	end
	ParaUI.Destroy(self.name);
	self.UnHook();
end
function FireMasterCanvas.DoAway()
	local self = FireMasterCanvas;
	if(self.gameLogic and self.gameLogic.isStart)then
		self.gameLogic.isStart = false;
		self.gameLogic:StopAllEffect();
		local s = string.format("大战火毛怪！ 你一共打中了%d个火毛怪\r\n获得了:\r\n%d个奇豆\r\n%d个火龙珠",self.cur_score or 0,self.cur_score_bean or 0,self.cur_score_zhu or 0);
		_guihelper.MessageBox_Plain(s, function(result) 
		    if(_guihelper.DialogResult.Yes == result) then
				self.gameLogic.isStart = true;
			elseif(_guihelper.DialogResult.No == result) then
				self.ClosePage();
				-- hard code the AddMoney here, move to the game server in the next release candidate
				local AddMoneyFunc = commonlib.getfield("MyCompany.Aries.Player.AddMoney");
				if(AddMoneyFunc) then
					AddMoneyFunc(self.cur_score_bean or 0, function(msg) 
						log("======== FireMasterCanvas.DoAway returns: ========\n")
						commonlib.echo(msg);
						-- send log information
						if(msg.issuccess == true) then
							paraworld.PostLog({action = "joybean_obtain_from_minigame", joybeancount = (self.cur_score_bean or 0), gamename = "FireMasterCanvas"}, 
								"joybean_obtain_from_minigame_log", function(msg)
							end);
						end
					end);
				end
			end
		end, _guihelper.MessageBoxButtons.YesNo,nil,{Yes = "继续玩", No = "退出游戏"});
	end
end
function FireMasterCanvas.ShowPage()
	local self = FireMasterCanvas;
	self.cur_score =  0;
	self.cur_score_bean = 0;
	self.cur_score_zhu = 0;
	self.gameLogic = Map3DSystem.App.FireMaster.FireMasterLogic:new();
	self.gameLogic.OnMsg = Map3DSystem.App.FireMaster.FireMasterCanvas.GetGameMsg;
	
	local parent = ParaUI.CreateUIObject("container", self.name, "_fi", 0,0,0,0);
	parent.background = "Texture/bg_black.png";
	parent:AttachToRoot();
	
	
	--bg
	local bg = self.gameLogic.bg;
	local _, _, screenWidth, screenHeight = ParaUI.GetUIObject("root"):GetAbsPosition();
	local dx = (screenWidth - bg.w)/2;
	local dy = (screenHeight - bg.h)/2;
	self.gameLogic.root_offset.x = dx;
	self.gameLogic.root_offset.y = dy;
	
	left,top,width,height = dx,dy,bg.w,bg.h;
	_this = ParaUI.CreateUIObject("container", self.name.."bg", "_lt", left,top,width,height);
	_this.background = bg.texture;
	parent:AddChild(_this);
	
	--logic_sprite
	_this = ParaUI.CreateUIObject("container", self.name.."logic_sprite", "_fi", 0,0,0,0);
	_this.background = "";
	parent:AddChild(_this);
	
	self.gameLogic:InitSprite(_this);
	--bg_mask
	local bg_mask = self.gameLogic.bg_mask
	left,top,width,height = dx,dy,bg_mask.w,bg_mask.h;
	_this = ParaUI.CreateUIObject("container", self.name.."bg_mask", "_lt", left,top,width,height);
	_this.background = bg_mask.texture;
	parent:AddChild(_this);
	
	--cursor_sprite
	local sinker = self.gameLogic.sinker_up;
	left,top,width,height = sinker.x,sinker.y,sinker.w,sinker.h;
	_this = ParaUI.CreateUIObject("container", self.name.."cursor_sprite", "_lt", left,top,width,height);
	_this.background = sinker.texture;
	_this.visible = false;
	parent:AddChild(_this);
	self.gameLogic.cursor_sprite = _this;
	
	--particle_sprite
	local particle = self.gameLogic.particle;
	--left,top,width,height = particle.x,particle.y,particle.w,particle.h;
	_this = ParaUI.CreateUIObject("container", self.name.."particle_sprite", "_fi", 0,0,0,0);
	_this.background = "";
	parent:AddChild(_this);
	self.gameLogic.particle_sprite = _this;
	
	--close_btn
	left,top,width,height = -50,10,42,42;
	_this = ParaUI.CreateUIObject("button", self.name.."close_btn", "_rt", left,top,width,height);
	_this.onclick = ";Map3DSystem.App.FireMaster.FireMasterCanvas.DoAway();";
	_this.background = "Texture/Aries/Homeland/close_small_32bits.png;0 0 42 42";
	parent:AddChild(_this);
	
	--progressbar
	NPL.load("(gl)script/ide/progressbar.lua");
	local ctl = CommonCtrl.progressbar:new{
			name = self.name.."progressbar",
			alignment = "_lb",
			left = 246,
			top = -80,
			width = screenWidth - 492,
			height = 24,
 			parent = parent,
			Minimum = 0,
			Maximum = 100,
			Step = 10,
			Value = 0,
			block_bg = "Texture/3DMapSystem/Loader/progressbar_filled.png: 7 7 13 7",
			container_bg = "Texture/3DMapSystem/Loader/progressbar_bg.png:7 7 6 6",
			block_color = "255 255 255",
		};
	ctl:Show();
	self.progressbar = ctl;
	----txt
	--left,top,width,height = 20,50,200,40;
	--_this = ParaUI.CreateUIObject("text", self.name.."txt", "_lt", left,top,width,height);
	--_guihelper.SetFontColor(_this, "255 0 0 255")
	--parent:AddChild(_this);
	
	--zhu_bg
	left,top,width,height = 100,-154,146,144;
	_this = ParaUI.CreateUIObject("container", self.name.."zhu_bg", "_lb", left,top,width,height);
	_this.background = "Texture/Aries/MiniGame/FireMaster/others/score_1.png";
	parent:AddChild(_this);
	--zhu_text
	left,top,width,height = 100 + 114 - 32 ,-154 + 70,64,64;
	_this = ParaUI.CreateUIObject("button", self.name.."zhu_text", "_lb", left,top,width,height);
	_this.background = "";
	_this.text = "0";
	_guihelper.SetFontColor(_this, "255 0 0 255")
	parent:AddChild(_this);
	
	--bean_bg
	left,top,width,height = -246,-154,146,144;
	_this = ParaUI.CreateUIObject("container", self.name.."bean_bg", "_rb", left,top,width,height);
	_this.background = "Texture/Aries/MiniGame/FireMaster/others/score_2.png";
	parent:AddChild(_this);
	--bean_text
	left,top,width,height = -246 + 29 - 32,-154 + 70 ,64,64;
	_this = ParaUI.CreateUIObject("button", self.name.."bean_text", "_rb", left,top,width,height);
	_this.background = "";
	_this.text = "0";
	_guihelper.SetFontColor(_this, "255 0 0 255")
	parent:AddChild(_this);
	
	
	self.RegHook();
	self.DoStart();
end
function FireMasterCanvas.RegHook()
	local self = FireMasterCanvas;
	local hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROC;
	local o = {hookType = hookType, 		 
		hookName = "FireMasterCanvas_mouse_down_hook", appName = "input", wndName = "mouse_down"}
			o.callback = FireMasterCanvas.OnMouseDown;
	CommonCtrl.os.hook.SetWindowsHook(o);
	o = {hookType = hookType, 		 
		hookName = "FireMasterCanvas_mouse_move_hook", appName = "input", wndName = "mouse_move"}
			o.callback = FireMasterCanvas.OnMouseMove;
	CommonCtrl.os.hook.SetWindowsHook(o);
	o = {hookType = hookType, 		 
		hookName = "FireMasterCanvas_mouse_up_hook", appName = "input", wndName = "mouse_up"}
			o.callback = FireMasterCanvas.OnMouseUp;
	CommonCtrl.os.hook.SetWindowsHook(o);
end
function FireMasterCanvas.UnHook()
	local self = FireMasterCanvas;
	local hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROC;
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "FireMasterCanvas_mouse_down_hook", hookType = hookType});
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "FireMasterCanvas_mouse_move_hook", hookType = hookType});
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "FireMasterCanvas_mouse_up_hook", hookType = hookType});
end
--[[
msg = {
  IsComboKeyPressed=false,
  IsMouseDown=true,
  MouseDragDist={ x=0, y=0 },
  dragDist=0,
  lastMouseDown={ x=583, y=492 },
  lastMouseUpTime=0,
  lastMouseUp_x=0,
  lastMouseUp_y=0,
  mouse_button="left",
  mouse_x=583,
  mouse_y=492,
  virtual_key=150,
  wndName="mouse_down" 
}
--]]
function FireMasterCanvas.OnMouseDown(nCode, appName, msg)
	local self = FireMasterCanvas;
	local point = {x = msg.mouse_x, y = msg.mouse_y};
	if(self.gameLogic)then
		self.gameLogic:DoMouseDwon(point);
	end
	return nil;
end
function FireMasterCanvas.OnMouseMove(nCode, appName, msg)
	local self = FireMasterCanvas;
	local point = {x = msg.mouse_x, y = msg.mouse_y};
	if(self.gameLogic)then
		self.gameLogic:DoMouseMove(point);
	end
	return nil;
end

function FireMasterCanvas.OnMouseUp(nCode, appName, msg)
	local self = FireMasterCanvas;
	if(self.gameLogic)then
		self.gameLogic:DoMouseUp();
	end
	return nil;
end
--[[
local msg = {
			game_state = game_state,--游戏状态
			cur_score = self.cur_score,--积分
			cur_tollgate = self.cur_tollgate,--当前关卡
			cur_tollgate_runtime = self.cur_tollgate_runtime,
			tollgate_duration = self.tollgate_duration,
		}
--]]
function FireMasterCanvas.GetGameMsg(msg)
	local self = FireMasterCanvas;
	if(not msg)then return end
	local game_state = msg.game_state;
	local percent = math.floor(100 * msg.cur_tollgate_runtime/msg.tollgate_duration);
	if(self.progressbar)then
		self.progressbar:SetValue(100 - percent);
	end
	--local score = string.format("现在是第%d道关卡，共得到%d分",msg.cur_tollgate or 0,msg.cur_score or 0);
	--local txt = ParaUI.GetUIObject(self.name.."txt");
	--if(txt and txt:IsValid())then
		--local last_txt = txt.text;
		--if(last_txt ~= score)then
			--txt.text = score;
		--end
	--end
	--if(game_state)then
		--local score = string.format("你已经通关了，共得到%d分",msg.cur_score or 0);
		--if(game_state == "timeover_gameover")then
			--_guihelper.MessageBox_Plain(score, function(result) 
									--if(_guihelper.DialogResult.OK == result) then
										--self.ClosePage();
									--end
								--end, _guihelper.MessageBoxButtons.OK,nil,{OK = "退出游戏"});
		--elseif(game_state == "timeover")then
		--local score = string.format("共过了%d道关卡，得到%d分",msg.cur_tollgate or 0,msg.cur_score or 0);
		--_guihelper.MessageBox_Plain(score, function(result) 
				--if(_guihelper.DialogResult.Yes == result) then
						--if(self.gameLogic)then
							--self.gameLogic:NextLevel();
						--end
				--elseif(_guihelper.DialogResult.No == result) then
					--self.ClosePage();
				--end
				--end, _guihelper.MessageBoxButtons.YesNo,nil,{Yes = "继续玩", No = "退出游戏"});
		--end
	--end 
	--self.SetText(self.name.."txt",msg.cur_score);
	self.cur_score = msg.cur_score;
	self.cur_score_bean = msg.cur_score_bean;
	self.cur_score_zhu = msg.cur_score_zhu;
	self.SetText(self.name.."zhu_text",msg.cur_score_zhu);
	self.SetText(self.name.."bean_text",msg.cur_score_bean);
	if(game_state)then
		local score = string.format("大战火毛怪！ 你一共打中了%d个火毛怪\r\n获得了:\r\n%d个奇豆\r\n%d个火龙珠",msg.cur_score or 0,msg.cur_score_bean or 0,msg.cur_score_zhu or 0);
		if(game_state == "timeover_gameover" or game_state == "timeover")then
			_guihelper.MessageBox_Plain(score, function(result) 
				if(_guihelper.DialogResult.OK == result) then
					self.ClosePage();
					-- hard code the AddMoney here, move to the game server in the next release candidate
					local AddMoneyFunc = commonlib.getfield("MyCompany.Aries.Player.AddMoney");
					if(AddMoneyFunc) then
						AddMoneyFunc(self.cur_score_bean or 0, function(msg) 
							log("======== FireMasterCanvas.GetGameMsg returns: ========\n")
							commonlib.echo(msg);
							-- send log information
							if(msg.issuccess == true) then
								paraworld.PostLog({action = "joybean_obtain_from_minigame", joybeancount = (self.cur_score_bean or 0), gamename = "FireMasterCanvas"}, 
									"joybean_obtain_from_minigame_log", function(msg)
								end);
							end
						end);
					end
				end
			end, _guihelper.MessageBoxButtons.OK,nil,{OK = "确认"});
		end
	end 
end
function FireMasterCanvas.SetText(name,value)
	local score = tostring(value) or "0"
	local txt = ParaUI.GetUIObject(name);
	if(txt and txt:IsValid())then
		local last_txt = txt.text;
		if(last_txt ~= score)then
			txt.text = score;
			_guihelper.SetButtonTextColor(txt, "255 0 0 255")
		end
	end
end
function FireMasterCanvas.DoStart()
	local self = FireMasterCanvas;
	local s = "火毛怪大战\r\n1.	每次你只能可在魔法学院里待1分钟，在1分钟内要尽快的用锤子打火毛怪;\r\n2.	只要打中洞洞里冒出的火毛怪，就有可能获得奇豆或火灵珠碎片\r\n3.	打的过程也要当心，不能打到淘气的抱抱龙哦，否则锤子要失效3秒哦！"
	_guihelper.MessageBox_Plain(s, function(result) 
			    if(_guihelper.DialogResult.Yes == result) then
						if(self.gameLogic)then
							self.gameLogic:Start();
						end
				elseif(_guihelper.DialogResult.No == result) then
					self.ClosePage();
				end
			end, _guihelper.MessageBoxButtons.YesNo,nil,{Yes = "开始玩", No = "退出游戏"});
end