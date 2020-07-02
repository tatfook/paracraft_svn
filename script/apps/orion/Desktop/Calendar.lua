--[[
Title: Calendar for Orion App
Author(s): Ma Keguang
Date: 2009/03/02
Desc: The Calendar contains 
	1. left top area: month display and changed dropdownlistbox
	2. right top area: year information display and changed NumericUpDown
	3. middle bottom area: show the date of calendar
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Orion/Desktop/Calendar.lua");
MyCompany.Orion.Desktop.InitCalendar();
MyCompany.Orion.Desktop.SendMessage({type = MyCompany.Orion.Calendar.MSGTYPE.SHOW_CALENDAR, bShow = true});
------------------------------------------------------------
]]

-- create class
local libName = "Calendar";
local Calendar = {};
commonlib.setfield("MyCompany.Orion.Calendar", Calendar);

-- messge types
Calendar.MSGTYPE = {
	-- show/hide the task bar, 
	-- msg = {bShow = true}
	SHOW_CALENDAR = 1100,
};
-- Calendar window handler,Show the window and close the window
function Calendar.MSGProc(window, msg)
	if(msg.type == Calendar.MSGTYPE.SHOW_CALENDAR) then
-- +TIP+: you defined a message type SHOW_CALENDAR, but you never use that
		-- show/hide the task bar, 
		--msg = {bShow = true}
		Calendar.ShowTest(msg.bShow);
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		window:ShowWindowFrame(false);
	end
end
--------------------------------------------------------
function Calendar.ShowTest(bShow)
end

-- create a new window form to display the calendar window 
local function CreateCalendarWindow(wndName)
	local _app = MyCompany.Orion.app._app;
	local calendarWindow = _app:FindWindow(wndName) or _app:RegisterWindow(wndName, nil, Calendar.MSGProc);
	
	--NPL.load("(gl)script/ide/WindowFrame.lua");		
	local calendarWindowsParam = {
		wnd = calendarWindow, -- a CommonCtrl.os.window object
		text = "Calendar Frame",
		zorder = 15,
		
		isShowTitleBar = true, -- default show title bar
		isShowToolboxBar = false, -- default hide title bar
		isShowStatusBar = false, -- default show status bar
		
		initialWidth = 800, -- initial width of the window client area
		initialHeight = 600, -- initial height of the window client area
		
		initialPosX = 50,
		initialPosY = 10,
		maxWidth = 420,
		maxHeight = 420,
		minWidth = 300,
		minHeight = 300,
		
		style = CommonCtrl.WindowFrame.DefaultStyle,
				
		alignment = "Free", -- Free|Left|Right|Bottom
		ShowUICallback = calendar_display,
		
	};
	--Create a new windowFrame by invoke the CommonCtrl.os.window:CreateWinowFrame(winParams) function
	local _frame = calendarWindow:CreateWindowFrame(calendarWindowsParam)
	--Just return the window by the index of frame.wnd
	return _frame.wnd;
end
--------------------------------------------------------
--funtion to be invoke,to show the Calendar window
function Calendar.show()
	-- +TIP+: what happen if CreateCalendarWindow() function is called multiple times
	local _app = MyCompany.Orion.app._app;
	--check if the window existed, if not ,create it
	local _window= _app:FindWindow("Calendar");
	if(_window == nil) then
		_window = CreateCalendarWindow("Calendar");
	end
	local wndname = _window.name;
	--find the window and show it
	local _wnd = _app:FindWindow(wndname);
	if(_wnd ~= nil) then
		local frame = _wnd:GetWindowFrame();
		if(frame ~= nil) then
			--frame:Show2(true);
			_wnd:ShowWindowFrame(true);
		end
	end	
end
--------------------------------------------------------
--get the date,month and year in number of gived day 
local function get_date_parts(date_str)
	local _,_,y,m,d=string.find(date_str, "(%d+)-(%d+)-(%d+)");
	return tonumber(y),tonumber(m),tonumber(d);
end
--caluate the total days in each month
local function get_days_in_month(month, year)
	local days_in_month = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }   
	local d = days_in_month[month]
	-- check for leap year
	if (month == 2) then
		if (math.mod(year,4) == 0) then
			if (math.mod(year,100) == 0)then                
				if (math.mod(year,400) == 0) then 
					d = 29; 
				end
			else 
				d = 29; 
			end
		end
	end
	return d;  
end
--caluate the week number of some day
local function get_day_of_week(dd, mm, yy)
	local days = { "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" };
	local mmx = mm;
	if (mm == 1) then  mmx = 13; yy = yy-1  end
	if (mm == 2) then  mmx = 14; yy = yy-1  end
	local val8 = dd + (mmx*2) +  math.floor(((mmx+1)*3)/5)   + yy + math.floor(yy/4)  - math.floor(yy/100)  + math.floor(yy/400) + 2;
	local val9 = math.floor(val8/7);
	local dw = val8-(val9*7);
	if (dw == 0) then
		dw = 7;
	end
	return days[dw],dw;
end
-------------------------------------------------------
local function show_message(dd,mm,yy)
	local window = ParaUI.GetUIObject("calendar_window");
	--create a new text box called "text2" at (50,-5)
	local _text = ParaUI.GetUIObject("text2");
	if(_text:IsValid() == false) then
		_text = ParaUI.CreateUIObject("text","text2","_lt",50,-5,0,0);
		--attach the text box to window
		window:AddChild(_text); 
	end
	_text.text= "日历（D）";
	local _text0 = ParaUI.GetUIObject("text0");
	if(_text0:IsValid() == false) then
		_text0 = ParaUI.CreateUIObject("text","text0","_lt",150,60,0,0);
		window:AddChild(_text0); 
	end
	--local dates = get_days_in_month(mm,yy);
	_text0.text="This month has "..get_days_in_month(mm,yy).." days";
	local _text1 = ParaUI.GetUIObject("text1");
	if(_text1:IsValid() == false) then
		_text1 = ParaUI.CreateUIObject("text","text1","_rb",-100,-20,100,0);
		window:AddChild(_text1); 
	end
	_text1.text="Today is "..get_day_of_week(dd,mm,yy);
end
--------------------------------------------------------
local function show_calendar(dd,mm,yy)
	local window = ParaUI.GetUIObject("calendar_window");
	--define a local p to index the UIObject 
	local p;
	local sub_window = ParaUI.GetUIObject("sub_window_show_calendar");
	if(sub_window:IsValid() == false) then
		--create a new window called "sub_window_show_calendar" at (-160,-120) with size 320*280
		sub_window=ParaUI.CreateUIObject("container","sub_window_show_calendar","_ct",-160,-120,320,280);
		local days = { "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" };
		for k =1,7 do
			p = ParaUI.CreateUIObject("text","txt","_lt",-20 + 42*k,5,40,0 );
			sub_window:AddChild(p);
			p.text = days[k];
		end
		for k = 1,31 do
			p = ParaUI.CreateUIObject("button","_date"..k,"_lt",0,0,20,20);
			p.visible = false;
			p.text = tostring(k);
			p.background = "";
			--Always we shouldn't note the UI in the table, use a string or a number instead
			sub_window:AddChild(p);
		end
		window:AddChild(sub_window); 
	else 
		for k = 1,31 do
			p = sub_window:GetChild("_date"..k);
			p.background = "";
			p.visible = false;
		end
	end
	-------------------------------------------
	local _ctl = CommonCtrl.GetControl("dropdownlistbox_month");
	if(_ctl == nil) then 
		--Try to study the use of dropdownList
		NPL.load("(gl)script/ide/dropdownlistbox.lua");
		local ctl_month = CommonCtrl.dropdownlistbox:new{
				name = "dropdownlistbox_month",
				alignment = "_ct",
				left=-150, top=-170,
				width = 100,
				height = 26,
				parent = window,
				AllowUserEdit = false,
				-- onchange event, it can be nil, a string to be executed or a function of type void ()(sCtrlName)
				onselect = function (sCtrlName, item)
					--local ctl = CommonCtrl.GetControl(sCtrlName);
					local i,j = string.find(item,"%d+");			
					--local mm = tonumber(string.sub(item,i,j));
					mm = tonumber(string.sub(item,i,j));
					-- +TIP+: there is a potential hazard of infinite loop call of callback functions like these
					--	i don't mean that this piece of code is wrong, but just a warning if you came to a game engine shut down
					show_message(dd,mm,yy);				
					show_calendar(dd,mm,yy); 
				end,
				items = {"1月", "2月", "3月", "4月", "5月", "6月", "7月", "8月","9月", "10月", "11月", "12月",values=nil,},
				text = tostring(mm).."月";
			};
		ctl_month:Show();	
	end
	_ctl = CommonCtrl.GetControl("NumericUpDown_year");
	if(_ctl == nil) then 
		NPL.load("(gl)script/ide/NumericUpDown.lua");
		local ctl_year = CommonCtrl.NumericUpDown:new{
			name = "NumericUpDown_year",
			alignment = "_ct",
			left = 50,
			top = -170,
			width = 100,
			height = 26,
			parent = window,
			value = 2009, -- current value
			valueformat = "%d",
			canDrag = true,
			min = 1899,
			max = 2100,
			min_step = 1, 
			onchange = function(value)
					--local yy = tonumber(value);
					yy = tonumber(value);
					-- +TIP+: here is might the answer to the inversed mm, dd, just a guess:
					--		the dd, mm here is the function params show_calendar(dd,mm,yy), not the onchange dd, mm
					--		an inversed params pairs may be passed to show_calendar with the inversed order again, 
					--		which lead to the right calculation, no matter in which order the params are passed.
					--		BE CAREFUL when using variables outside function scope					
					show_message(dd,mm,yy);
					show_calendar(dd,mm,yy); 
			end
		};
		ctl_year:Show();	
	end
	-------------------------------------------
	local row_id = 1;
	for k=1,get_days_in_month(mm,yy) do
		local _q,q = get_day_of_week(k,mm,yy);
		if(k>1 and tonumber(q)==1) then
			row_id = row_id + 1;
		end
		--get the UIObject correspond to the date of k by name
		p = sub_window:GetChild("_date"..k);
		--let the UIObject visiable
		p.visible = true;
		--change the coordinate of p,both coordinateX and coordinateY
		p.x = -20 + 42*q;
		p.y = 5+40*row_id;
		if(k==dd) then
			p.background = "Texture/Aquarius/Desktop/Channel_Smiley_32bits.png; 7 7 7 7";
			p.onclick =";MyCompany.Orion.Calendar.OnDateKeep();"; 
		else
			p.onclick = string.format(";MyCompany.Orion.Calendar.OnDateChanged(%d,%d,%d);", k,mm,yy);
		end
	end
end
----------------------------------------

-- +TIP+: again if bShow is false

function calendar_display(bShow,_parent)
	local window = ParaUI.GetUIObject("calendar_window");
	if(window:IsValid() == false) then
		window=ParaUI.CreateUIObject("container","calendar_window","_ct",-200,-200,400,400);
		window.background = "Texture/alphadot.png:15 15 15 15";
		_parent:AddChild(window);
	end

	local date = ParaGlobal.GetDateFormat("yyyy-MM-dd"); 
	local thisyear,thismonth,thisdate = get_date_parts(date);
			
	show_message(thisdate,thismonth,thisyear);
	show_calendar(thisdate,thismonth,thisyear); 

end	
--Show message when user click the date which is today already
function Calendar.OnDateKeep()
	_guihelper.MessageBox("Already today, needn't to be modified!");
end
--Refresh the UIObject after the date changed
function Calendar.OnDateChanged(dd,mm,yy)
	show_message(dd,mm,yy);
	show_calendar(dd,mm,yy); 
end