NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/sqlite/sqlite3.lua");
NPL.load("(gl)script/mapMarkProvider.lua");


--markInfo_db intent to connect world map-mark-db and my-map-mark db
--since most operation on these db are the same
--so i create 2 different connection
--and reuse all markInfo_db methods
if(not markInfo_db)then markInfo_db = {};end

markInfo_db.isWorldDBConnect = false;
markInfo_db.isLocalDBConnect = false;
markInfo_db.valid = false;

markInfo_db.worldDBFile = "database/mapplayers.db";
if( ParaIO.DoesFileExist(markInfo_db.worldDBFile,true))then
	local errMsg;
	markInfo_db.worldDB,errMsg = sqlite3.open(markInfo_db.worldDBFile);
	if( markInfo_db.worldDB == nil)then
		if( errMsg ~= nil)then
			log(errMsg.."\n");
		end
		markInfo_db.isWorldDBConnect = false;
		log("can not connect mappplayers.db\n");
	else
		markInfo_db.isWorldDBConnect = true;
	end
else
	markInfo_db.isWorldDBConnect = false;
	log("can not connect mappplayers.db\n");
end

markInfo_db.localDBFile =  "database/localMarks.db";
if( ParaIO.DoesFileExist( markInfo_db.localDBFile))then
	local errMsg;
	markInfo_db.localDB,errMsg = sqlite3.open(markInfo_db.localDBFile);
	if(markInfo_db.localDB == nil)then
		if( errMsg ~= nil)then
			log(errMsg.."\n");
		end
		markInfo_db.isLocalDBConnect = false;
		log("warning: can not connect "..markInfo_db.localDBFile.." it may be read-only.\n");
	else
		markInfo_db.isLocalDBConnect = true;
	end
else
	markInfo_db.isLocalDBConnect = false;
	log("warning: can not connect "..markInfo_db.localDBFile.." it does not exist.\n");
end

if( markInfo_db.isWorldDBConnect)then
	markInfo_db.activeDB = markInfo_db.worldDB;
	markInfo_db.valid = true;
else
	markInfo_db.valid = false;
end
markInfo_db.isUsingLocalDB = false;
markInfo_db.resultLimit = 200;

function markInfo_db.Select(_markID)
	if( markInfo_db.valid == false)then
		return;
	end
	
	local row;
	for row in markInfo_db.activeDB:rows( string.format([[SELECT markID, level, location, isOnline, detail, logo, markStyle, displayLevel, coordinate_x, coordinate_y FROM mapMarkInfos WHERE markID = "%s"]],_markID)) do
		row.isOnline = ( row.isOnline == 1);
		return  CommonCtrl.markInfo:new(row);
	end
end

function markInfo_db.SelectMarkInRegion(x_min,x_max,y_min,y_max)
	if( markInfo_db.valid == false)then
		return;
	end
	
	local _playerInfos = {}
	local i=1;
	for row in markInfo_db.activeDB:rows(string.format("SELECT markID, level, location, isOnline, detail, logo, markStyle, displayLevel, coordinate_x, coordinate_y FROM mapMarkInfos WHERE (coordinate_x BETWEEN %d AND %d) and (coordinate_y BETWEEN %d AND %d) ORDER BY displayLevel LIMIT %d",
	x_min,x_max,y_min,y_max,markInfo_db.resultLimit))do
		row.isOnline = ( row.isOnline == 1);
		_playerInfos[i] = CommonCtrl.markInfo:new(row);
		i = i + 1;
	end	
	return _playerInfos;
end

function markInfo_db.SearchMarkInRegion(keywords,bMatchKeyword,x_min,x_max,y_min,y_max)
	if( markInfo_db.valid == false)then
		return nil;
	end	
	local _playerInfos = {};
	local row;
	local i = 1;
	local command1;
	if( bMatchKeyword == true or bMatchKeyword == nil)then
		command1 = "SELECT * FROM mapMarkInfos WHERE markID like '%%%%";
	else
		command1 = "SELECT * FROM mapMarkInfos WHERE markID not like '%%%%"
	end
	local command2 = "%%%%'";
	local command3 = string.format("and (coordinate_x BETWEEN %d AND %d) and (coordinate_y BETWEEN %d AND %d) ORDER BY displayLevel LIMIT %d",x_min,x_max,y_min,y_max,markInfo_db.resultLimit);
	local command = command1..keywords..command2..command3;
	for row in markInfo_db.activeDB:rows(command) do
		row.isOnline = ( row.isOnline == 1);
		_playerInfos[i] = CommonCtrl.markInfo:new(row);
		i = i + 1;
	end
	return _playerInfos;
end

function markInfo_db.SearchAll(keywords,bMatchKeyword)
	if( markInfo_db.valid == false)then
		return;
	end
	
	local _playerInfos = {};
	local command1;
	if( bMatchKeyword == nil or bMatchKeyword == true)then
		command1 = "SELECT * FROM mapMarkInfos WHERE markID like '%%%%";
	else
		command1 = "SELECT * FROM mapMarkInfos WHERE markID not like '%%%%";
	end
	local command2 = "%%%%'";
	local command3 = string.format(" ORDER BY displayLevel LIMIT %d",markInfo_db.resultLimit);
	local command = command1..keywords..command2;
	
	local i = 1;	
	for row in markInfo_db.activeDB:rows(command) do
		row.isOnline = ( row.isOnline == 1);
		_playerInfos[i] = CommonCtrl.markInfo:new(row);
		i = i + 1;
	end
	return _playerInfos;		 
end

--TODO:update take no effect
function markInfo_db.Update(markInfo)
	log("update\n");
	if( markInfo_db.valid == false)then
		return;
	end 

	if( markInfo_db.Exist(markInfo:GetMarkID()) == false)then
		return;
	end

	local _isOnline = (markInfo:GetIsOnline() and 1) or 0;
	local x,y = markInfo:GetCoordinate();
		
	markInfo_db.activeDB:exec(string.format([[UPDATE mapMarkInfos SET level =%d, location =%q, isOnline =%d, detail =%q, logo =%q, markStyle =%q, displayLevel =%d,coordinate_x =%d, coordinate_y = %d WHERE markID =%q]],markInfo:GetLevel(),markInfo:GetLocation(),_isOnline,markInfo:GetDetail(),markInfo:GetLogo(),markInfo:GetMarkStyle(),markInfo:GetDisplayLvl(),x,y,markInfo:GetMarkID()));
end

--TODO:Insert may failed sometimes
function markInfo_db.Insert(_newMark)
	if( markInfo_db.valid == false)then
		return;
	end
	
	if(markInfo_db.Exist(_newMark:GetMarkID()))then
		log(string.format("map mark: %s already exist,insert faild -_- \r\n",_newMark:GetMarkID()));
		return;
	end
	local _isOnline = (_newMark:GetIsOnline() and 1) or 0;
	markInfo_db.activeDB:exec(string.format([[ INSERT INTO mapMarkInfos (markID, level, location, isOnline, detail, logo, markStyle, displayLevel, coordinate_x, coordinate_y) VALUES("%s",%d,"%s",%d,"%s","%s","%s",%d,%d,%d)]],_newMark:GetMarkID(),_newMark:GetLevel(),
		_newMark:GetLocation(),_isOnline,_newMark:GetDetail(),_newMark:GetLogo(),_newMark:GetMarkStyle(),_newMark:GetDisplayLvl(),_newMark:GetCoordinate()));
end

function markInfo_db.Exist(_markID)
	if( markInfo_db.valid == false)then
		return;
	end

	local result = false;
	for row in markInfo_db.activeDB:rows(string.format([[SELECT markID FROM mapMarkInfos WHERE markID = "%s"]],_markID)) do
		result = true;
	end
	return result;
end

function markInfo_db.Delete(_markID)
	if( markInfo_db.valid == false)then
		return;
	end
	
	markInfo_db.activeDB:exec( string.format([[ DELETE FROM mapMarkInfos WHERE markID = "%s"]],_markID));
end
 
function markInfo_db.DownloadDB()
end

function markInfo_db.ActiveLocalDB( _isActive)
	if(_isActive == true)then
		if( markInfo_db.isLocalDBConnect)then
			markInfo_db.activeDB = markInfo_db.localDB;
			markInfo_db.isUsingLocalDB = true;
			markInfo_db.valid = true;
		else
			markInfo_db.valid = false;
		end
	else
		if( markInfo_db.isWorldDBConnect)then
			markInfo_db.activeDB = markInfo_db.worldDB;
			markInfo_db.isUsingLocalDB = false;
			markInfo_db.valid = true;
		else
			markInfo_db.valid = false;
		end
	end
end

function markInfo_db.SetResultLimit(_limit)
	markInfo_db.resultLimit = limit;
end

function markInfo_db.IsUsingLocalDB()
	return markInfo_db.isUsingLocalDB;
end
