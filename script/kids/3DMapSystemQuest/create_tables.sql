-- Title: NPC, NPCStatus, Quest tables...
-- Author(s): WangTian
-- Date: 2008/12/11
-- Decs: Create tables SQL

DROP TABLE IF EXISTS `NPC`;
CREATE TABLE [NPC](
	[ID] INTEGER PRIMARY KEY,
	[Name] [nchar](20) UNIQUE NOT NULL,
	[AssetName] [nchar](10)  NOT NULL,
	[IsGlobal] [smallint] NOT NULL DEFAULT ((1)),
	[SnapToTerrain] [smallint] NOT NULL DEFAULT ((1)),
	[Radius] [float] NOT NULL DEFAULT ((0.35)),
	[Facing] [float] NOT NULL DEFAULT ((0)),
	[Scaling] [float] NOT NULL DEFAULT ((1)),
	[posX] [float] NOT NULL DEFAULT ((0)),
	[posY] [float] NOT NULL DEFAULT ((0)),
	[posZ] [float] NOT NULL DEFAULT ((0)),
	[CharacterType] [int] NOT NULL DEFAULT ((0)),
	[MentalState0] [int] NOT NULL DEFAULT ((0)),
	[MentalState1] [int] NOT NULL DEFAULT ((0)),
	[MentalState2] [int] NOT NULL DEFAULT ((0)),
	[MentalState3] [int] NOT NULL DEFAULT ((0)),
	[LifePoint] [float] NOT NULL DEFAULT ((100)),
	[Age] [float] NOT NULL DEFAULT ((1)),
	[Height] [float] NOT NULL DEFAULT ((1.78)),
	[Weight] [float] NOT NULL DEFAULT ((55)),
	[Occupation] [int] NOT NULL DEFAULT ((0)),
	[RaceSex] [int] NOT NULL DEFAULT ((0)),
	[Strength] [float] NOT NULL DEFAULT ((0)),
	[Dexterity] [float] NOT NULL DEFAULT ((0)),
	[Intelligence] [float] NOT NULL DEFAULT ((0)),
	[BaseDefense] [float] NOT NULL DEFAULT ((0)),
	[Defense] [float] NOT NULL DEFAULT ((0)),
	[Defenseflat] [float] NOT NULL DEFAULT ((0)),
	[DefenseMental] [float] NOT NULL DEFAULT ((0)),
	[BaseAttack] [float] NOT NULL DEFAULT ((0)),
	[AttackMelee] [float] NOT NULL DEFAULT ((0)),
	[AttackRanged] [float] NOT NULL DEFAULT ((0)),
	[AttackMental] [float] NOT NULL DEFAULT ((0)),
	[MaxLifeLoad] [float] NOT NULL DEFAULT ((10)),
	[HeroPoints] [int] NOT NULL DEFAULT ((0)),
	[PerceptiveRadius] [float] NOT NULL DEFAULT ((7)),
	[SentientRadius] [float] NOT NULL DEFAULT ((50)),
	[GroupID] [int] NOT NULL DEFAULT ((0)),
	[SentientField] [int] NOT NULL DEFAULT ((0)),
	[OnLoadScript] [nvarchar](2048) NULL,
	[CustomAppearance] [nvarchar](255) NULL
);

DROP TABLE IF EXISTS `quest_template`;
CREATE TABLE [quest_template](
  [entry] INTEGER NOT NULL PRIMARY KEY UNIQUE, 
  [Method] INTEGER NOT NULL DEFAULT (2), 
  [PrevQuestId] INTEGER NOT NULL DEFAULT (0), 
  [NextQuestId] INTEGER NOT NULL DEFAULT (0), 
  [ExclusiveGroup] INTEGER NOT NULL DEFAULT (0), 
  [NextQuestInChain] INTEGER NOT NULL DEFAULT (0), 
  [Title] VARCHAR NOT NULL DEFAULT ('Title'), 
  [Details] VARCHAR DEFAULT ('Details'), 
  [Objectives] VARCHAR DEFAULT ('Objectives'), 
  [OfferRewardText] VARCHAR DEFAULT ('OfferRewardText'), 
  [RequestItemsText] VARCHAR DEFAULT ('RequestItemsText'), 
  [EndText] VARCHAR DEFAULT ('EndText'), 
  [ObjectiveText1] VARCHAR, 
  [ObjectiveText2] VARCHAR, 
  [ObjectiveText3] VARCHAR, 
  [ObjectiveText4] VARCHAR, 
  [SReqItemId1] INTEGER NOT NULL DEFAULT (0), 
  [SReqItemId2] INTEGER NOT NULL DEFAULT (0), 
  [SReqItemId3] INTEGER NOT NULL DEFAULT (0), 
  [SReqItemId4] INTEGER NOT NULL DEFAULT (0), 
  [SReqItemCount1] INTEGER NOT NULL DEFAULT (0), 
  [SReqItemCount2] INTEGER NOT NULL DEFAULT (0), 
  [SReqItemCount3] INTEGER NOT NULL DEFAULT (0), 
  [SReqItemCount4] INTEGER NOT NULL DEFAULT (0), 
  [SReqCreatureOrGOId1] INTEGER NOT NULL DEFAULT (0), 
  [SReqCreatureOrGOId2] INTEGER NOT NULL DEFAULT (0), 
  [SReqCreatureOrGOId3] INTEGER NOT NULL DEFAULT (0), 
  [SReqCreatureOrGOId4] INTEGER NOT NULL DEFAULT (0), 
  [SReqCreatureOrGOCount1] INTEGER NOT NULL DEFAULT (0), 
  [SReqCreatureOrGOCount2] INTEGER NOT NULL DEFAULT (0), 
  [SReqCreatureOrGOCount3] INTEGER NOT NULL DEFAULT (0), 
  [SReqCreatureOrGOCount4] INTEGER NOT NULL DEFAULT (0), 
  [CReqGoalId1] INTEGER NOT NULL DEFAULT (0), 
  [CReqGoalId2] INTEGER NOT NULL DEFAULT (0), 
  [CReqGoalId3] INTEGER NOT NULL DEFAULT (0), 
  [CReqGoalId4] INTEGER NOT NULL DEFAULT (0), 
  [CReqCount1] INTEGER NOT NULL DEFAULT (0), 
  [CReqCount2] INTEGER NOT NULL DEFAULT (0), 
  [CReqCount3] INTEGER NOT NULL DEFAULT (0), 
  [CReqCount4] INTEGER NOT NULL DEFAULT (0), 
  [RewChoiceItemId1] INTEGER NOT NULL DEFAULT (0), 
  [RewChoiceItemId2] INTEGER NOT NULL DEFAULT (0), 
  [RewChoiceItemId3] INTEGER NOT NULL DEFAULT (0), 
  [RewChoiceItemId4] INTEGER NOT NULL DEFAULT (0), 
  [RewChoiceItemId5] INTEGER NOT NULL DEFAULT (0), 
  [RewChoiceItemId6] INTEGER NOT NULL DEFAULT (0), 
  [RewChoiceItemCount1] INTEGER NOT NULL DEFAULT (0), 
  [RewChoiceItemCount2] INTEGER NOT NULL DEFAULT (0), 
  [RewChoiceItemCount3] INTEGER NOT NULL DEFAULT (0), 
  [RewChoiceItemCount4] INTEGER NOT NULL DEFAULT (0), 
  [RewChoiceItemCount5] INTEGER NOT NULL DEFAULT (0), 
  [RewChoiceItemCount6] INTEGER NOT NULL DEFAULT (0), 
  [RewItemId1] INTEGER NOT NULL DEFAULT (0), 
  [RewItemId2] INTEGER NOT NULL DEFAULT (0), 
  [RewItemId3] INTEGER NOT NULL DEFAULT (0), 
  [RewItemId4] INTEGER NOT NULL DEFAULT (0), 
  [RewItemCount1] INTEGER NOT NULL DEFAULT (0), 
  [RewItemCount2] INTEGER NOT NULL DEFAULT (0), 
  [RewItemCount3] INTEGER NOT NULL DEFAULT (0), 
  [RewItemCount4] INTEGER NOT NULL DEFAULT (0), 
  [RewOrReqMoney] INTEGER NOT NULL DEFAULT (0), 
  [RewSpell] INTEGER NOT NULL DEFAULT (0), 
  [RewSpellCast] INTEGER NOT NULL DEFAULT (0), 
  [RewCharTitleId] INTEGER NOT NULL DEFAULT (0), 
  [StartScript] INTEGER DEFAULT (''), 
  [EndScript] INTEGER DEFAULT (''))
);

DROP TABLE IF EXISTS `npc_quest_start_relation`;
CREATE TABLE [npc_quest_start_relation] (
  [id] INTEGER NOT NULL, 
  [quest] INTEGER NOT NULL
  );

DROP TABLE IF EXISTS `npc_quest_finish_relation`;  
CREATE TABLE [npc_quest_finish_relation] (
  [id] INTEGER NOT NULL, 
  [quest] INTEGER NOT NULL
  );
  
DROP TABLE IF EXISTS `npc_gossip`;  
CREATE TABLE [npc_gossip] (
  [ID] INTEGER PRIMARY KEY NOT NULL, 
  [gossiptext] VARCHAR NOT NULL DEFAULT ('Hi')
  );

DROP TABLE IF EXISTS `character_queststatus`;
CREATE TABLE [character_queststatus](
	[guid] INTEGER UNIQUE PRIMARY KEY NOT NULL,
	[quest] INTEGER NOT NULL,
	[status] INTEGER NOT NULL,
	[rewarded] BOOL NOT NULL,
	[explored] BOOL NOT NULL,
	[timer] INTEGER NOT NULL,
	[mobcount1] INTEGER NOT NULL,
	[mobcount2] INTEGER NOT NULL,
	[mobcount3] INTEGER NOT NULL,
	[mobcount4] INTEGER NOT NULL,
	[itemcount1] INTEGER NOT NULL,
	[itemcount2] INTEGER NOT NULL,
	[itemcount3] INTEGER NOT NULL,
	[itemcount4] INTEGER NOT NULL,
	[creqcount1] INTEGER NOT NULL,
	[creqcount2] INTEGER NOT NULL,
	[creqcount3] INTEGER NOT NULL,
	[creqcount4] INTEGER NOT NULL,
);



DROP TABLE IF EXISTS `creq_goals`;
CREATE TABLE [creq_goals](
	[id] INTEGER UNIQUE PRIMARY KEY NOT NULL,
	[app_key]  VARCHAR NOT NULL,
	[commandname]  VARCHAR NOT NULL,
	[questiondata] VARCHAR NOT NULL,
	[answerdata] VARCHAR NOT NULL
);