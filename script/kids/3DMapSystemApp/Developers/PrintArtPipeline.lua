--[[
Title: code behind page for PrintArtPipeline.html
Author(s): LiXizhi
Date: 2009/2/4
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/Developers/PrintArtPipeline.lua");
-------------------------------------------------------
]]
local PrintArtPipeline = {};
commonlib.setfield("Map3DSystem.App.Developers.PrintArtPipeline", PrintArtPipeline)

---------------------------------
-- page event handlers
---------------------------------

-- init
function PrintArtPipeline.OnInit()
	local self = document:GetPageCtrl();
end

-- print it  
function PrintArtPipeline.OnPrint(name, values)
	
	NPL.load("(gl)script/ide/SaveFileDialog.lua");
	local ctl = CommonCtrl.SaveFileDialog:new{
		name = "SaveFileDialog1",
		alignment = "_ct",
		left=-256, top=-150,
		width = 512,
		height = 380,
		parent = nil,
		-- initial file name to be displayed, usually "" 
		FileName = "ArtPipeline_"..string.gsub(values.folder, "%W", "_")..".txt",
		fileextensions = {"text file(*.txt)", },
		folderlinks = {
			{path = "temp", text = "temp"},
		},
		onopen = function(ctrlName, filename)
			PrintArtPipeline.PrintToFile(filename, values)
		end
	};
	ctl:Show(true);
end

-- print to files
function PrintArtPipeline.PrintToFile(filename, values)
	NPL.load("(gl)script/ide/Encoding.lua");

	local rootfolder = values.folder
	local file = ParaIO.open(filename, "w");
	if( file:IsValid() )then
		local output = commonlib.Files.Find({}, rootfolder, 20, 50000, function(item)
			local ext = commonlib.Files.GetFileExtension(item.filename);
			if(ext) then
				ext = string.lower(ext)
				return (ext == "x") or (ext == "dds") or (ext == "png")
			elseif(item.filesize==0) then
				return true; -- this might be a folder
			end
		end)
		if(output and #output>0) then
			local _, item;
			for _, item in ipairs(output) do
				local bWarning;
				local utfFileName = commonlib.Encoding.DefaultToUtf8(item.filename)
				if(utfFileName ~= item.filename and values.ValidateNaming) then
					bWarning = true;
					file:WriteString("WARNING: 文件名不能是中文--------------\r\n")
				end
				if(bWarning or not values.ExportOnlyWarning) then
					file:WriteString(string.format("%s/%s\r\n", rootfolder,utfFileName))
				end	
			end
		end
		file:close();
	end	
end	