--[[
Title: Popup editor
Author(s): LiXizhi
Date: 2007/4/16
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/EBook/PopupEditor.lua");
local ctl = CommonCtrl.PopupEditor:new{
	name = "PopupEditor1",
	alignment = "_lt",
	left=0, top=0,
	width = 400,
	textwidth = 360,
	height = 300,
	item_count = 3,
	item_height = 26,
	item_spacing = 2,
	parent = nil,
};
ctl:Show(true, "hello\nall!");
-------------------------------------------------------
]]

-- common control library
NPL.load("(gl)script/ide/common_control.lua");
local L = CommonCtrl.Locale("ParaWorld");

-- define a new control in the common control libary

-- default member attributes
local PopupEditor = {
	-- the top level control name
	name = "PopupEditor1",
	-- normal window size
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 400,
	height = 400,
	textwidth = nil, 
	item_count = 3,
	item_height = 26,
	item_spacing = 2,
	parent = nil,
	-- appearance
	main_bg = nil,
	editbox_bg = "",
	-- OnOK event, it can be nil, a string to be executed or a function of type void ()(Ctrl, text)
	-- it will be called when the user pressed the OK button. 
	on_ok= nil,
}
CommonCtrl.PopupEditor = PopupEditor;

-- constructor
function PopupEditor:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

-- Destroy the UI control
function PopupEditor:Destroy ()
	ParaUI.Destroy(self.name);
end

--@param bShow: boolean to show or hide. if nil, it will toggle current setting. 
--@param text: text to be displayed. this can be nil.
function PopupEditor:Show(bShow, text, left, top)
	local _this,_parent;
	if(self.name==nil)then
		log("PopupEditor instance name can not be nil\r\n");
		return
	end
	
	_this=ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false) then
		if(bShow == false) then return	end
		bShow = true;
		
		if(not left) then left = self.left end
		if(not top) then top = self.top end
		
		_this=ParaUI.CreateUIObject("container",self.name,self.alignment,left,top,self.width,self.height);
		_this.background=self.main_bg;
		_this.onmouseup=string.format([[;CommonCtrl.PopupEditor.OnHideMe("%s");]],self.name);
		_this:SetTopLevel(true);
		_parent = _this;
		
		if(self.parent==nil) then
			_this:AttachToRoot();
		else
			self.parent:AddChild(_this);
		end
		CommonCtrl.AddControl(self.name, self);
		
		_this=ParaUI.CreateUIObject("container","","_fi",8,9,8,8);
		_this.background="";
		-- TODO: shall we make this container scrollable?
		_parent:AddChild(_this);
		_parent = _this;
		
		if(not self.textwidth) then
			self.textwidth = self.width - 32;
		end
		-- item count
		local i;
		for i=0, self.item_count-1 do
			_this=ParaUI.CreateUIObject("imeeditbox",self.name.."EditBoxLine"..(i+1),"_mt",self.item_spacing,i*(self.item_height+self.item_spacing), self.item_spacing, self.item_height);
			_this.onkeyup=string.format([[;CommonCtrl.PopupEditor.OnText("%s", %d);]], self.name, i+1);
			_this.background=self.editbox_bg;
			_parent:AddChild(_this);
		end
		
		_this=ParaUI.CreateUIObject("button",self.name.."OK", "_lb",10,-30,80,26);
		_this.text=L"OK";     
		_this.onclick=string.format([[;CommonCtrl.PopupEditor.OnOK("%s");]],self.name);
		_parent:AddChild(_this);
		
		_this=ParaUI.CreateUIObject("button",self.name.."Cancel", "_lb",90,-30,80,26);
		_this.text=L"Cancel";     
		_this.onclick=string.format([[;CommonCtrl.PopupEditor.OnHideMe("%s");]],self.name);
		_parent:AddChild(_this);
	else
		if(bShow == nil) then
			bShow = (_this.visible == false);
		end
		_this.visible = bShow;
		if(bShow) then
			_this:SetTopLevel(true);
		end
	end	
	
	-- set the text if any
	if(text) then
		self:SetText(text);
	end	
	if(bShow) then
		Map3DSystem.PushState({name = self.name, OnEscKey = string.format([[CommonCtrl.PopupEditor.OnHideMe("%s")]], self.name)});
	else
		Map3DSystem.PopState(self.name);
	end
end

-- close the given control
function PopupEditor.OnClose(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting PopupEditor instance "..sCtrlName.."\r\n");
		return;
	end
	ParaUI.Destroy(self.name);
end

-- call to hide
function CommonCtrl.PopupEditor.OnHideMe(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting PopupEditor instance "..sCtrlName.."\r\n");
		return;
	end
	-- hide
	self:Show(false);
end

-- called when the text changes
function CommonCtrl.PopupEditor.OnText(sCtrlName, nLineIndex)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting PopupEditor instance "..sCtrlName.."\r\n");
		return;
	end
	if(virtual_key == Event_Mapping.EM_KEY_DOWN) then
		-- if the user pressed the enter key, change to the next line.
		if(nLineIndex < self.item_count) then
			local nextLine = ParaUI.GetUIObject(self.name.."EditBoxLine"..(nLineIndex+1));
			local thisLine = ParaUI.GetUIObject(self.name.."EditBoxLine"..nLineIndex);
			if(thisLine:IsValid() and nextLine:IsValid()) then
				nextLine:Focus();
				nextLine:SetCaretPosition(thisLine:GetCaretPosition());
			end	
			ParaUI.GetUIObject(self.name.."EditBoxLine"..(nLineIndex+1)):Focus();
		end
	elseif(virtual_key == Event_Mapping.EM_KEY_RETURN or virtual_key == Event_Mapping.EM_KEY_NUMPADENTER ) then
		-- insert return key
		self:ProcessLine(nLineIndex, 2, true);
	elseif(virtual_key == Event_Mapping.EM_KEY_UP)	then
		-- if the user pressed the up key, change to the previous line.
		if(nLineIndex >=2 ) then
			local lastLine = ParaUI.GetUIObject(self.name.."EditBoxLine"..(nLineIndex-1));
			local thisLine = ParaUI.GetUIObject(self.name.."EditBoxLine"..nLineIndex);
			if(thisLine:IsValid() and lastLine:IsValid()) then
				lastLine:Focus();
				lastLine:SetCaretPosition(thisLine:GetCaretPosition());
			end	
		end
	elseif(virtual_key == Event_Mapping.EM_KEY_BACKSPACE or virtual_key == Event_Mapping.EM_KEY_DELETE)	then	
		
		local thisLine = ParaUI.GetUIObject(self.name.."EditBoxLine"..nLineIndex);
		if(thisLine:IsValid()) then
			local thisCharPos = thisLine:GetCaretPosition();
			local thisLineCharCount = thisLine:GetTextSize();
			if(thisLine.text == "") then
				-- only delete the current line if it is already empty
				self:ProcessLine(nLineIndex, 5);
				if(virtual_key == Event_Mapping.EM_KEY_BACKSPACE) then
					-- move to the previous line
					if(nLineIndex >=2 ) then
						local lastLine = ParaUI.GetUIObject(self.name.."EditBoxLine"..(nLineIndex-1));
						if(lastLine:IsValid()) then
							lastLine:Focus();
							lastLine:SetCaretPosition(-1);
						end	
					end	
				end
			else
				if(virtual_key == Event_Mapping.EM_KEY_BACKSPACE and thisCharPos ==0) then
					-- backspace key when the caret is at beginning.
					if(nLineIndex>=2) then
						local lastLine = ParaUI.GetUIObject(self.name.."EditBoxLine"..(nLineIndex-1));
						if(lastLine:IsValid()) then
							local caretPos = lastLine:GetTextSize();
							local oldtext = thisLine.text;
							thisLine.text = "";
							self:ProcessLine(nLineIndex-1, 4, oldtext);
							lastLine:SetCaretPosition(caretPos);
							lastLine:Focus();
						end
					end	
				elseif(virtual_key == Event_Mapping.EM_KEY_DELETE and thisCharPos ==thisLineCharCount) then
					-- delete key when the caret is at ending.
					if(nLineIndex < self.item_count) then
						local nextLine = ParaUI.GetUIObject(self.name.."EditBoxLine"..(nLineIndex+1));
						if(nextLine:IsValid()) then
							local caretPos = thisLine:GetCaretPosition();
							local oldtext = nextLine.text;
							nextLine.text = "";
							self:ProcessLine(nLineIndex, 4, oldtext);
							thisLine:SetCaretPosition(caretPos);
						end
					end	
				end
			end
		end
	else
		-- if there is input, switch to the next line.
		-- GetFirstVisibleCharIndex	
		self:ProcessLine(nLineIndex, 0, true);
	end	
end

-- update the given line; if necessary, it will also update subsequent lines recursively.
-- @param nLineIndex: line index
-- @param command: 
--   0: update the line. If param1 is nil, it will not change the focus, otherwise change the focus if necessary.
--   1: prepend text(param1) to the given line
--   4: append text(param1) to the given line
--   2: insert return key at the current caret position.If param1 is nil, it will not change the focus, otherwise change the focus if necessary.
--   3: insert a new line of text(param1) at the current line
--   5: delete a given line
function CommonCtrl.PopupEditor:ProcessLine(nLineIndex, command, param1)
	local thisLine = ParaUI.GetUIObject(self.name.."EditBoxLine"..nLineIndex);
	if(thisLine:IsValid()) then
		if(command == 0)then
			local oldtext = thisLine.text;
			local nCharsCount = thisLine:GetTextSize();
			local nTrailPos = nCharsCount;
			
			if(nTrailPos>0) then
				-- find the last word position that can be displayed within self.textwidth
				while true do
					local x,y = thisLine:CPtoXY(nTrailPos, true, 0,0);
					if(x<=self.textwidth or x==0) then
						break;
					end
					local nTestTrailPos = thisLine:GetPriorWordPos(nTrailPos, 0);
					
					--log(string.format("trailpos=%s, testPriorWordPos=%s, charcount = %s\r\n", nTrailPos, nTestTrailPos, nCharsCount))
					x=0;
					if(nTestTrailPos<nTrailPos) then
						if(nTestTrailPos == 0) then
							nTrailPos = nCharsCount;
							break;
						end
					else
						if(nTestTrailPos == 0) then
							nTrailPos = nCharsCount;
						end
						break;
					end
					
					-- if the last word has trailing space characters, just regard each space as a word and try again.
					local wordTextLastChar = ParaMisc.UniSubString(oldtext, nTrailPos, nTrailPos);
					--log(string.format("wordTextLastChar = %s oldtext = <%s>\r\n", tostring(wordTextLastChar), oldtext))
					if(wordTextLastChar == " ") then
						nTrailPos = nTrailPos -1;
					else
						nTrailPos = nTestTrailPos;	
					end	
				end	
			end
			
			-- if the line is full, break to the next line
			if(nTrailPos<nCharsCount) then
				-- only break, if it is not the last line
				if(nLineIndex < self.item_count) then
					local CharCount = ParaMisc.GetUnicodeCharNum(oldtext); -- need a unicode version for Chinese characters.
					local oldCaretPosThisLine = thisLine:GetCaretPosition();
					thisLine.text = ParaMisc.UniSubString(oldtext, 1, nTrailPos);
					local leftovertext = ParaMisc.UniSubString(oldtext, nTrailPos+1,-1);
					
					self:ProcessLine(nLineIndex+1, 1, leftovertext);
					
					if(param1) then
						local newSize = thisLine:GetTextSize();
						if(oldCaretPosThisLine >= newSize) then
							local nextline = ParaUI.GetUIObject(self.name.."EditBoxLine"..(nLineIndex+1));
							if(nextline:IsValid()) then
								nextline:Focus();
								nextline:SetCaretPosition(oldCaretPosThisLine-nTrailPos);
							end	
						else
							thisLine:SetCaretPosition(oldCaretPosThisLine);
						end	
					end	
				end	
			end
		elseif(command == 1)then
			--   1: prepend text(param1) to the given line
			if(type(param1) == "string") then
				thisLine.text = param1..thisLine.text;
				--thisLine:SetCaretPosition(-1); -- this is tricky: set caret to the end of the string for firstCharIndex updating
				self:ProcessLine(nLineIndex, 0);
			end	
		elseif(command == 4)then
			--   1: append text(param1) to the given line
			if(type(param1) == "string") then
				thisLine.text = thisLine.text..param1;
				self:ProcessLine(nLineIndex, 0);
			end
		elseif(command == 2)then
			--   2: insert return key at the current caret position.
			-- only break, if it is not the last line
			if(nLineIndex < self.item_count) then
				if(param1) then
					ParaUI.GetUIObject(self.name.."EditBoxLine"..(nLineIndex+1)):Focus();
				end	
				local oldtext = thisLine.text;
				local CharCount = ParaMisc.GetUnicodeCharNum(oldtext); -- need a unicode version for Chinese characters.
				local CaretPos = thisLine:GetCaretPosition();
				if(CaretPos < (CharCount))then
					thisLine.text = ParaMisc.UniSubString(oldtext, 1, CaretPos);
					local leftovertext = ParaMisc.UniSubString(oldtext, CaretPos+1,-1);
					self:ProcessLine(nLineIndex+1, 3, leftovertext);
				else
					self:ProcessLine(nLineIndex+1, 3, "");	
				end
			end	
		elseif(command == 3)then
			--   3: insert a new line of text(param1) at the current line
			if(nLineIndex < self.item_count) then
				if(type(param1) == "string") then
					local oldtext = thisLine.text;
					thisLine.text = param1;
					self:ProcessLine(nLineIndex+1, 3, oldtext);
				end	
			else
				if(type(param1) == "string") then
					thisLine.text = param1..thisLine.text;
				end	
			end
		elseif(command == 5)then
			--   5: delete a given line
			local i;
			for i = nLineIndex, self.item_count-1 do
				ParaUI.GetUIObject(self.name.."EditBoxLine"..i).text = ParaUI.GetUIObject(self.name.."EditBoxLine"..(i+1)).text;
			end
			ParaUI.GetUIObject(self.name.."EditBoxLine"..self.item_count).text = ""
		else
			-- TODO: 
		end
	end
end

-- set the text
function CommonCtrl.PopupEditor:SetText(text)
	local line_text;
	local i = 1;
	for line_text in string.gfind(text, "([^\r\n]*)\n?") do
		if(i<=self.item_count) then
			ParaUI.GetUIObject(self.name.."EditBoxLine"..i).text = line_text;
			i=i+1;
		else
			break
		end
	end
	local k;
	for k=i,self.item_count do
		ParaUI.GetUIObject(self.name.."EditBoxLine"..k).text = "";
	end
end

-- return the concartenated text
function CommonCtrl.PopupEditor:GetText()
	local text="";
	local i;
	for i = 1, self.item_count do
		local line_text = ParaUI.GetUIObject(self.name.."EditBoxLine"..i).text;
		if(line_text ~= nil and line_text ~= "") then
			line_text = string.gsub(line_text, "([^\r\n]+)", "%1\n");
			text = text..line_text;
		else
			if(i<self.item_count) then
				text = text.."\n"
			end	
		end
	end
	--log(text.." gettext\r\n"..self.item_count.." numbers\r\n")
	return text;
end

-- close the given control
function CommonCtrl.PopupEditor.OnOK(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting PopupEditor instance "..sCtrlName.."\r\n");
		return;
	end
	
	-- call the event handler if any
	if(self.on_ok~=nil)then
		if(type(self.on_ok) == "string") then
			NPL.DoString(self.on_ok);
		else
			self.on_ok(self, self:GetText());
		end
	end
	
	-- hide
	self:Show(false);
end
