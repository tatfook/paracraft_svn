---++ Battle Field Server in GSL
Author: LiXizhi
Date: 2011.12.5
File: script/apps/GameServer/BattlefieldService/readme.txt

---+++ Overview
A battle field is a multi-player PvP scenario, where each party has a group of 10-20 people battle against the opponent team.
   * Rule 1: players are allowed to join or leave the battle at any time. The system will automatically add players to the minority party. 
   * Rule 2: at the beginning of the battles, players of both parties gathered in their base camp behind a bar. 
   * Rule 3: when players are full and after 50 seconds, the bars are opened simultaniously and all players rushed down to occupy resource points. 
   * Rule 4: 5 resource points are located in the battle field. 
   * Rule 5: TODO

---+++ Architecture
Battlefield service is implemented as a server side NPC and a global service. It works with the combat system tightly on the server side, especially the battle arena object.  

GSL_BattleServer (server agent) <---> gridnode <---> GSL_BattleClient <---> UI, 3D, etc. 
GSL CombatSystem (battle arena) <--->                Client Arena Object

The above shows that battle server and combat system communicate with each other since they are both connected with their parent gsl gridnode. 
Battle information is automatically sent to the gsl_battleclient which will tell the UI and 3d module to update accordingly. 

---+++ Server side logics
GSL_BattleServer acts as a rule judger. 
The GSL_BattleServer knows nothing about the external world, it simply has a data interface for external modules to query or update its states. 
And it is also reponsible for sync states with all connected clients. 

When the server sees a new player it will either reject it or allocate a side to the requester. 
Rejected request is usually shibecause battle reaches it compacity. 
But a rejected player can still choose to watch the game but not able to join any battle. 

the battle field server will automatically add the player to its side group
when players are full, it will begin the battle. If any player is inactive for 3 minutes, it will be kicked out and a new player may be allowed to join. 

---++++ GSL_BattleServer data API
the following shows a number of commonly used data api of the GSL_BattleServer. These api are called by the combat arena system to update its internal state. 

<verbatim>
local battle_server = my_gridnode:GetServerObject("battle");
if(battle_server and battle_server.battle_field) then
	local bf = battle_server.battle_field;

	if(bf:has_begun()) then
		-- adding score
		bf:add_score("nid_string", nil, 10000);

		-- get nid side: return 0, 1, or nil.
		local side = bf:get_player_side(nid);
	
		-- set balance number on 1-5 resource point
		local rp = bf:get_resource_point(1)
		if(rp) then
			rp:set_balance_num(1);
		end
	end
end
</verbatim>