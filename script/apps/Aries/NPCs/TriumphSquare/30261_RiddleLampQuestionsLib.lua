--[[
Title: 
Author(s): Leio
Date: 2010/02/24
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/TriumphSquare/30261_RiddleLampQuestionsLib.lua");
local libs = MyCompany.Aries.Quest.NPCs.RiddleLampQuestionsLib.GetLibs();
commonlib.echo(libs);

NPL.load("(gl)script/apps/Aries/NPCs/TriumphSquare/30261_RiddleLampQuestionsLib.lua");
local question = MyCompany.Aries.Quest.NPCs.RiddleLampQuestionsLib.Get_Question();
commonlib.echo(question);

NPL.load("(gl)script/apps/Aries/NPCs/TriumphSquare/30261_RiddleLampQuestionsLib.lua");
MyCompany.Aries.Quest.NPCs.RiddleLampQuestionsLib.ParseFile_Xml();
-------------------------------------------------------
]]

local RiddleLampQuestionsLib = {
	file_path = "Texture/Aries/MapHelp/Csv/riddlelamp.xml",
	questions = nil,
}
commonlib.setfield("MyCompany.Aries.Quest.NPCs.RiddleLampQuestionsLib",RiddleLampQuestionsLib);
function RiddleLampQuestionsLib.ParseFile_Xml()
	local self = RiddleLampQuestionsLib;
	local xmlRoot = ParaXML.LuaXML_ParseFile(self.file_path);
	local result = {};
	if(xmlRoot) then
		local node;
		for node in commonlib.XPath.eachNode(xmlRoot, "/dataroot/Item") do
			if(node)then
				local k,v;
				local label;
				local option = {};
				local answer;
				for k,v in ipairs(node) do
					local content = string.gsub(v[1],"%s","");
					if(v.name == "a" or v.name == "b" or v.name == "c" or v.name == "d")then
						option[v.name] = content;
					end
					if(v.name == "tt")then
						label = content;
					end
					if(v.name == "da")then
						answer = content;
						answer = string.lower(answer);
					end
				end
				local item = {
					label = label,
					option = option,
					answer = answer,
				};
				--commonlib.echo(item);
				--{ label = "2010年是什么虎年？", option = {a = "己丑年", b = "庚寅年", c = "丁亥年",}, answer = "b",},
				table.insert(result,item);
			end
		end
	end	
	return result;
end
--parse a csv file and made a library of questions
function RiddleLampQuestionsLib.ParseFile()
	local self = RiddleLampQuestionsLib;
	local line;
	local file = ParaIO.open(self.file_path, "r");
	local label,desc,pointlabel,key;
	local result = {};
	if(file:IsValid()) then
		line=file:readline();
		while line~=nil do 
			local __,__,__, label,a,b,c,d,answer= string.find(line,"(.+),(.+),(.+),(.+),(.+),(.+),(.+)");
			answer = string.lower(answer);
			local option = {
				a = a,
				b = b,
				c = c,
				d = d,
			}
	
			local item = {
				label = label,
				option = option,
				answer = answer,
			};
			--{ label = "2010年是什么虎年？", option = {a = "己丑年", b = "庚寅年", c = "丁亥年",}, answer = "b",},
			table.insert(result,item);
			line=file:readline();
		end
		file:close();
	end
	return result;
end
-- get and made all of questions
function RiddleLampQuestionsLib.GetLibs()
	local self = RiddleLampQuestionsLib;
	if(not self.questions)then
		self.questions = self.ParseFile_Xml();
	end
	return self.questions;
end
-- get a question from libs
function RiddleLampQuestionsLib.Get_Question()
	local self = RiddleLampQuestionsLib;
	local libs = self.GetLibs();
	if(libs)then
		local len = #libs;
		local index = math.random(len);
		return libs[index];
	end
end