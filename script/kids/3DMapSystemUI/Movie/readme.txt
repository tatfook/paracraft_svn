--[[
Title: architecture design
Author(s): LiXizhi, leio
Date: 2008/8/18
Desc: 
The implementation is the traditional model, view and controller pattern. 
   * model: MovieScript is the model (data) class, which can be serialized to/from xml (mcml) file. 
   * view, controller: MovieManager, SoundManager , EventManager, CameraManager, ClipManager are the view and controller class. they have bindings to the model class.
	 users interacts with the view and controller classes to play or edit the model file. The view and controller class are implemented via treenode and mcml controls 
   * MovieAssetsPage, ClipManagerPage, MovieAssetsPage are mcml window classes that hosts the above view/control managers. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Movie/readme.lua");
------------------------------------------------------------
]]

if(not Map3DSystem.Movie.MovieManager) then Map3DSystem.Movie.MovieManager={}; end

------------------------------------------------------------
-- movie script is a tree-like hierachy, containing a number of movies, clips, camera shots, and tracks(assets) for cameras, events and sounds, 
-- each clip contains a number of camera shots that belongs to the same scene. each camera shot references tracks in the assets and movie is defined as the playback of all camera shots in sequence.
-- movie script can be serialized to and from xml (mcml).
-- movie script <===> xml(mcml) file
------------------------------------------------------------

local MovieScript = {
	-- a movie contains a number of clips(from this movie script or from other script).
	-- this movies section is automatically added and for future use and is not mendatory in movie script.
	movies = {
		-- a movie instance contains a sequence of clips.  
		[1] = {
			name = "movie name", 
			desc = "Movie clip description",
			author = nil,
			-- a sequence of movie clips.  
			clips = {
				[1] = {
					-- the file path of the containing movie script file.if nil, it is this one. it can be relative path to this file. 
					moviescript = nil
					-- the referenced clip id in the above movie script. 
					clip_id = 1, 
					-- some fade in effect
					in_effect = nil,
					-- some fade out effect
					out_effect = nil,
				},
			},
			-- out of screen white text.  
			-- UI_position, text, duration, etc. 
			white_text = {track_data},
		},
	},
	
	-- all movie clips defined in this movie script.
	-- each movie clip contains a number of camera shots that belongs to the same scene.
	clips = {
		-- the world path or world id of the 3d scene, in which all following clips resides. 
		-- if nil, it can resides in any world. 
		worldpath = "worlds/MyWorlds/scene00",
		world_id = nil,
		-- some movie clip instance
		[1] = {
			-- clip id
			id = 1,
			name = "Movie clip name",
			desc = "Movie clip description",
			-- some camera shots
			camera_shots = {
				[1] = {
					--camera track id
					camera_id = 1,
					name = "camera shot name", 
					enabled = true, 
					-- components of the shots
					components = {
						{type="event", id = 1, start_time=0, visible = true},
						{type="event", id = 2, start_time=10, visible = true},
						{type="sound", id = 1, start_time=0, visible = true},
					},
				},
				[2] = {
					--camera track id
					camera_id = 2,
					name = "camera shot name", 
					enabled = true, 
					components = {
						{type="event", id = 3, start_time=2, visible = true},
						{type="event", id = 4, start_time=0, visible = true},
						{type="sound", id = 2, start_time=0, visible = true},
					},
				},
			},
		},
	},
	-- a mapping from id to clips 
	clips_mapping = {},
	-- next available id. 
	clip_next_id = 2,
		
	-- assets are tracks (time series) of camera, events and sounds. They are referenced by camera shots. 
	assets = {
		--
		-- an array of camera tracks
		--
		cameras = {
			-- a camera asset contains following info,
			{
				id=1, start_time=0, end_time=30, isLooping=false, 
				-- camera look at position(x,y,z), camera eye polar position (a,b, height)
				track={track_data}, 
			},
			{
				id=2, start_time=5, end_time=20, isLooping=false, 
				track={track_data}, 
			},
		},
		-- a mapping from id to cameras for finding a camera asset by id fast. 
		cameras_mapping = {},
		-- next available id. 
		camera_next_id = 3,
		
		--
		-- an array of event tracks
		--
		events = {
			[1] = {
				id=1, 
				actors = {
					[1] = {
						-- event type: 1 for actor event, 2 for effect event.
						type=1, 
						-- global character name
						actor_name = nil,
						-- currently it is always 0
						start_time=0,
						-- if nil, it will be the longest non-looping time in action items. 
						-- if -1, it will remain in the last frame.
						-- Otherwise, it can be a number in seconds, after which the character should dissappear, unless isLooping is true. 
						end_time=nil,
						-- whether it is looping. 
						isLooping = false,
						-- actions in this event: there are four action types, all of them can be nil except that entry
						-- entrance time
						entry = {
							start_time = 0,
							-- character information: name, primary asset, facing, position (vector3), ccs_info, etc.
							-- and/or object creations and modifications track, can be nil
							track = {track_data},
						},
						-- movement track, can be nil
						moves = {
							-- position track of the character. 
							-- run/walk (a bit), target position, facing.
							track = {track_data},
						},
						-- dialog track, can be nil
						dialog = {
							-- chat track data of the character.
							-- dialog text 
							track = {track_data},
						},
						-- animations track, can be nil
						anims = {
							-- animation track data of the character. 
							-- anim_id/anim_string, 
							track = {track_data},
						},
					},
				},
			},
		},
		-- a mapping from id to events
		events_mapping = {},
		-- next available id. 
		events_next_id = 2,
		
		--
		-- an array of sound tracks
		--
		sounds = {
			{id=1, start_time=0, end_time=30, isLooping=false, track={track_data}, },
			{id=2, start_time=5, end_time=20, isLooping=false, track={track_data}, },
		},
		-- a mapping from id to sounds
		sounds_mapping = {},
		-- next available id. 
		sounds_next_id = 3,
	}
};

-- implementation use treenode as base class. 
-- to view and edit the tree node data defined above, we will data bind them to display treenodes

-------------------------------------------------------------
-- The view and controller of of all movies in a movie script
-- Note: this is not defined in design doc. So postpone its implementation. 
-------------------------------------------------------------

local MovieManager = {
	
}

-------------------------------------------------------------
-- The view and controller of all clips in a movie script
-------------------------------------------------------------

local ClipManager = {
	-- clips via treenode
	clips = CommonCtrl.TreeNode:new({Text = "clips", Name = "clips"})
}

-- to data bind the clip manager to a given movie script model. 
-- @param moviescript: the movie script object (treenode) to bind to. 
function ClipManager:DataBind(moviescript)
	self.clips:ClearAllChildren();
	-- for each clip in moviescript.clips do
	--	create a view clip tree node and bind it to model treenode. 
	-- end
end

-------------------------------------------------------------
-- The view and controller of of all cameras in a movie script
-------------------------------------------------------------

local CameraManager = {
	
}

-------------------------------------------------------------
-- The view and controller of of all events in a movie script
-------------------------------------------------------------
local EventManager = {
	
}
	
-------------------------------------------------------------	
-- The view and controller of of all sounds in a movie script
-------------------------------------------------------------
local SoundManager = {
	
}

---------------------------------------------
-- the mcml page to present the movie manager. 
-- note: this is optional.
---------------------------------------------
local MovieManagerPage = {}

---------------------------------------------
-- the mcml page to present the clip manager. 
---------------------------------------------
local ClipManagerPage = {}

---------------------------------------------
-- the mcml page to present the camera, event and sound manager 
---------------------------------------------
local MovieAssetsPage = {}

---------------------------------------------
-- the node of movies
---------------------------------------------
local MovieNode = {canEdit = true,detailMode = true}
function MovieNode.DrawEventViewNodeHandler(_parent,treeNode)
	local state = treeNode.state;
	if(canEdit)then
		if(detailMode)then
			-- draw node use canedit and detail mode
		else
			-- other mode
		end
	else
		-- other mode
	end
end
local ClipNode = {}
local CameraNode = {}
local EventNode = {}
local SoundNode = {}
