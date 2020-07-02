--[[
Title: test GSL transaction
Author(s): LiXizhi
Date: 2011.2.28
Desc:  
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/GameServer/test/test_GSL_lobbyservice.lua");
local test_GSL_lobby = commonlib.gettable("MyCompany.Aries.test_GSL_lobby")
test_GSL_lobby:test_MatchMaker()
test_GSL_transaction:TestFunction()
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/GameServer/LobbyService/GSL_LobbyClient.lua");
local test_GSL_lobby = commonlib.gettable("MyCompany.Aries.test_GSL_lobby")

--[[ results is as below. 
echo:"{players={user001={nid=\"user001\",rank_index=1,},},player_count=1,worldname=\"worlds/abc\",owner_nid=\"user001\",}"
echo:"{players={user001={nid=\"user001\",rank_index=1,},user002={nid=\"user002\",rank_index=2,},},player_count=2,worldname=\"worlds/abc\",owner_nid=\"user001\",}"
echo:"{players={user002={nid=\"user002\",rank_index=2,},user003={nid=\"user003\",rank_index=3,},user004={nid=\"user004\",rank_index=4,},},player_count=3,worldname=\"worlds/abc\",owner_nid=\"user002\",}"
echo:"{players={user005={nid=\"user005\",rank_index=1,},user002={nid=\"user002\",rank_index=2,},user003={nid=\"user003\",rank_index=3,},user004={nid=\"user004\",rank_index=4,},},player_count=4,worldname=\"worlds/abc\",owner_nid=\"user002\",}"
echo:"{players={user005={nid=\"user005\",rank_index=1,},user002={nid=\"user002\",rank_index=2,},user003={nid=\"user003\",rank_index=3,},user004={nid=\"user004\",rank_index=4,},},player_count=4,worldname=\"worlds/abc\",owner_nid=\"user005\",}"
]]
function test_GSL_lobby:test_game_info()
	NPL.load("(gl)script/apps/GameServer/LobbyService/GSL_LobbyData.lua");
	local game_info = commonlib.gettable("Map3DSystem.GSL.Lobby.game_info");
	local player_info = commonlib.gettable("Map3DSystem.GSL.Lobby.player_info");
	
	local game1 = game_info:new({max_players = 4});
	game1.worldname = "worlds/abc";
	game1.owner_nid = "owner nid";
	game1:add_user("user001", player_info:new({nid = "user001"}))
	commonlib.echo(game1:tostring());
	game1:add_user("user002", player_info:new({nid = "user002"}))
	game1:add_user("user001", player_info:new({nid = "user001_repeated_ignored"}))
	commonlib.echo(game1:tostring());
	game1:add_user("user003", player_info:new({nid = "user003"}))
	game1:add_user("user004", player_info:new({nid = "user004"}))
	assert(game1:add_user("user005", player_info:new({nid = "user005_full"})) == false);
	game1:remove_player("user001")
	commonlib.echo(game1:tostring());
	game1:add_user("user005", player_info:new({nid = "user005"}))
	commonlib.echo(game1:tostring());
	game1:make_owner("user005")
	commonlib.echo(game1:tostring());
end

function test_GSL_lobby:test_LobbyServerStatic()
	local new_game_setting = {
		name="MyGameName",
		worldname = "SomeSampleWorldName",
		game_type = "PvE",
		min_level = 0,
		max_level = 0,
		start_mode = "auto",
		--friends_join_only = false,
	};

	NPL.load("(gl)script/apps/GameServer/LobbyService/GSL_LobbyServer.lua");
	local server = Map3DSystem.GSL.Lobby.GSL_LobbyServer:new();
	server:init({my_nid="1003", lobbyserver_nid="1003", proxy_thread_name="main"})
	local game_info = server:CreateNewGame(new_game_setting);
	commonlib.echo(game_info);
end

function test_GSL_lobby:test_CreateLeaveRoom()
	NPL.load("(gl)script/apps/GameServer/LobbyService/GSL_LobbyClient.lua");
	local new_game_setting = {
		name="MyGameName",
		worldname = "SomeSampleWorldName",
		game_type = "PvE",
		min_level = 0,
		max_level = 0,
		start_mode = "auto",
		--friends_join_only = false,
	};
	local lobbyclient = Map3DSystem.GSL.Lobby.GSL_LobbyClient.GetSingleton();
	lobbyclient:SendMessage("create_game", new_game_setting)
end

function test_GSL_lobby:test_FindGames()
	NPL.load("(gl)script/apps/GameServer/LobbyService/GSL_LobbyClient.lua");
	local lobbyclient = Map3DSystem.GSL.Lobby.GSL_LobbyClient.GetSingleton();
	lobbyclient:SendMessage("find_game", {"FireCavern_1to10", "TreasureHouse_4"})
end


-- pure data and algorithm testing. 
function test_GSL_lobby:test_MatchMaker()
	NPL.load("(gl)script/apps/GameServer/LobbyService/GSL_LobbyServer.lua");
	local MatchMaker = commonlib.gettable("Map3DSystem.GSL.Lobby.MatchMaker");
	local game_info = commonlib.gettable("Map3DSystem.GSL.Lobby.game_info");
	local player_info = commonlib.gettable("Map3DSystem.GSL.Lobby.player_info");
	
	local matches = MatchMaker.FrameMove();
	commonlib.echo(matches); -- > empty

	local game1 = game_info:new({max_players = 2, id=1, game_type="PvP"});
	game1.worldname = "worlds/abc";
	game1.owner_nid = "user101";
	game1:add_user("user101", player_info:new({nid = "user101"}))
	game1:add_user("user102", player_info:new({nid = "user102"}))

	local game2 = game_info:new({max_players = 2, id=2, game_type="PvP"});
	game2.worldname = "worlds/abc";
	game2.owner_nid = "user203";
	game2:add_user("user203", player_info:new({nid = "user203"}))
	game2:add_user("user204", player_info:new({nid = "user204"}))

	local game3 = game_info:new({max_players = 2, id=3, game_type="PvP"});
	game3.worldname = "worlds/abc";
	game3.owner_nid = "user305";
	game3:add_user("user305", player_info:new({nid = "user305"}))
	game3:add_user("user306", player_info:new({nid = "user306"}))

	local game4 = game_info:new({max_players = 2, id=4, game_type="PvP"});
	game4.worldname = "worlds/abc";
	game4.owner_nid = "user407";
	game4:add_user("user407", player_info:new({nid = "user407"}))
	game4:add_user("user408", player_info:new({nid = "user408"}))


	MatchMaker.AddGame(game1);

	local matches = MatchMaker.FrameMove();
	commonlib.echo(matches); -- > empty

	MatchMaker.AddGame(game2);

	local matches = MatchMaker.FrameMove();
	commonlib.echo(matches); -- > empty: game1 and game2

	MatchMaker.AddGame(game1);
	MatchMaker.AddGame(game2);
	MatchMaker.RemoveGame(game1);
	MatchMaker.AddGame(game3);

	local matches = MatchMaker.FrameMove();
	commonlib.echo(matches); -- > empty: game2 and game3

	MatchMaker.AddGame(game3);
	MatchMaker.AddGame(game2);
	MatchMaker.AddGame(game1);
	MatchMaker.AddGame(game4);
	local matches = MatchMaker.FrameMove();
	commonlib.echo(matches); -- > empty: {game3 and game2}, {1,4}
end