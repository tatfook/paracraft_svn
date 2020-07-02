--[[
Title: 
Author(s): Leio
Date: 2009/12/25
Desc:
use the lib:
------------------------------------------------------------
时报汇总
NPL.load("(gl)script/apps/Aries/Books/TimesMagazine/TimesMagazineCabinet.lua");
MyCompany.Aries.Books.TimesMagazineCabinet.ShowPage();
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Books/TimesMagazineWeb/TimesMagazineWeb.lua");

local TimesMagazineCabinet = commonlib.gettable("MyCompany.Aries.Books.TimesMagazineCabinet");

function TimesMagazineCabinet.Init()
	if(TimesMagazineCabinet.inited) then
		return;
	end
	TimesMagazineCabinet.inited = true;
	local XMLList = ParaXML.LuaXML_ParseFile("script/apps/Aries/Books/TimesMagazineWeb/TimesMagazineWeb.xml");
	local i;
	local tmp;
	TimesMagazineCabinet.items = {}
	for i=1,table.getn(XMLList[1]) do
		tmp = { url = XMLList[1][i].attr.url, label = XMLList[1][i].attr.label, pagecount = XMLList[1][i].attr.pagecount, mailpage=XMLList[1][i].attr.mailpage,};
		table.insert(TimesMagazineCabinet.items,tmp);
	end
end

function TimesMagazineCabinet.DS_Func_Items(index)
	if(not TimesMagazineCabinet.items)then return 0 end
	if(index == nil) then
		return #(TimesMagazineCabinet.items);
	else
		return TimesMagazineCabinet.items[index];
	end
end
function TimesMagazineCabinet.ShowPage()
	TimesMagazineCabinet.Init();
	local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);
	-- show the panel
    System.App.Commands.Call("File.MCMLWindowFrame", {
        url = "script/apps/Aries/Books/TimesMagazine/TimesMagazineCabinet.html", 
        app_key = MyCompany.Aries.app.app_key, 
        name = "TimesMagazineCabinet.ShowPage", 
        isShowTitleBar = false,
        DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
        style = style,
        zorder = 2,
        allowDrag = false,
		isTopLevel = true,
        directPosition = true,
            align = "_ct",
            x = -950/2,
            y = -550/2,
            width = 950,
            height = 512,
    });
end
function TimesMagazineCabinet.ClosePage()
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name="TimesMagazineCabinet.ShowPage", 
		app_key=MyCompany.Aries.app.app_key, 
		bShow = false,bDestroy = true,});
end  

function TimesMagazineCabinet.GetLastUrl()
	TimesMagazineCabinet.Init()
	return TimesMagazineCabinet.items[1].url;
end

function TimesMagazineCabinet.PreInitLast()
	TimesMagazineCabinet.Init()
	local tmp = table.getn(TimesMagazineCabinet.items);
	local list = MyCompany.Aries.Books.TimesMagazineWeb.PreInit(tmp,tonumber(TimesMagazineCabinet.items[1].pagecount),TimesMagazineCabinet.items[1].mailpage);
	return list;
end

function TimesMagazineCabinet.OpenBook(index)
	TimesMagazineCabinet.Init()
	if(not index)then return end
	local idx = tonumber(index);
	echo("========idx");
	echo(TimesMagazineCabinet.items);
	echo("========idx");
	echo(idx);
	NPL.load("(gl)script/apps/Aries/Books/BookPreloadAssets.lua");
	local tmp = table.getn(TimesMagazineCabinet.items);
	local download_list = MyCompany.Aries.Books.TimesMagazineWeb.PreInit(tmp-idx + 1,tonumber(TimesMagazineCabinet.items[idx].pagecount),TimesMagazineCabinet.items[idx].mailpage);
	NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/PreLoaderDialog.lua");
	commonlib.echo("=============before TimesMagazine");
	Map3DSystem.App.MiniGames.PreLoaderDialog.StartDownload({download_list = download_list,txt = {"正在打开时报，请稍等......"}},function(msg)
	commonlib.echo("=============after TimesMagazine");
		commonlib.echo(msg);
		--if(msg and msg.state == "finished")then
			 
			System.App.Commands.Call("File.MCMLWindowFrame", {
				url = TimesMagazineCabinet.items[idx].url, 
				name = "TimesMagazine", 
				isShowTitleBar = false,
				DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
				style = CommonCtrl.WindowFrame.ContainerStyle,
				zorder = 2,
				allowDrag = false,
				directPosition = true,
					align = "_ct",
						x = -960/2+50,
						y = -560/2,
						width = 960,
						height = 560,
			});
		--end
	end)
end