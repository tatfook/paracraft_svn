---++ Trade Server in GSL
Author: LiXizhi
Date: 2011.10.12
File: script/apps/GameServer/TradeService/readme.txt

---+++ Overview
A general MMO trade server between two players
   * phase1: request trade from player1 to player2 (cancel previous trades on both players if exist)
   * phase2: add and remove items to trade and confirm
   * phase3: submit and finish trade

---+++ Requirements
   * trade only occurs when two players are close to each other in one (or proxied) game world.
   * player database may be in two locations. 
   * Both players talks to a central trusted trade service on game server, and the trade service calls the database interface of the first player to complete a trade transaction. 
   * all trade actions must be logged on database server; and post logged on game server. 

---+++ Architecture
There are four logics units: a trade client, a trade server and db server

Trade client is part of the GSL service client, and is connected with a GSL gridnode service(trade server).  A gsl proxy may be used in case gridnode is on a home server. 
The trade server acts as a broker between the two clients and the db server, it ensures that both clients agrees on the trade and then invoke the trade api to complete the trade transaction. 

---+++ Message Sequence Graph
Basically after a trade is started, the client send TRADE_ITEM_UPDATE message once the user changes anything. 
and the server broadcast trade_transaction to both clients whenever data changes and periodically at low interval. 

---++++ Requesting a trade transaction
Client1                         Client2                            Server                           DB
TradeClient:TRADE_REQUEST{target_nid = client2}                 ---> TradeServer
				            TradeClient:<---------TradeServer:TRADE_REQUEST{from_nid = client1}
																	(Spawn a trade_transaction)
					Cond1:	TradeClient:TRADE_RESPONSE{accepted=true}-->TradeServer
							(InvokeTradeUI)                          
TradeClient    <-------------                     TradeServer:TRADE_RESPONSE{accepted=true}
(InvokeTradeUI)

					Cond2:	TradeClient:TRADE_RESPONSE{accepted=false}-->TradeServer
																	(remove trade_transaction)
TradeClient    <-------------                     TradeServer:TRADE_RESPONSE{accepted=false}


---++++ Trading process
Client1                         Client2                            Server                           DB
TradeClient:TRADE_ITEM_UPDATE{trad_cont={...}}                 ---> TradeServer:update
				TradeClient:TRADE_ITEM_UPDATE{trad_cont={...}} ---> TradeServer:update

TradeClient:                   TradeClient:                  <----- TradeServer:TRADE_ITEM_RESPONSE{trad_trans={}}
																	TradeServer:DBAPI -----------> DBAPI
																	TradeServer:DBAPI <----------  DBAPI

TradeClient:                   TradeClient:                  <----- TRADE_COMPLETE(remove trade_transaction)
TradeClient:                   TradeClient:                  <----- TRADE_CANCEL(remove trade_transaction)
