--[[
Title: a sample module file
Author(s): LiXizhi
Date: 2008/3/5
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/Developers/sample_module.lua");
------------------------------------------------------------
-- file1.lua is assumed to be at the same directory as the sample_module. 
%MODULEFILE{"file1.lua", replace = {
	{from = "%SRC_DIR%", to="%INSTALL_DIR%"},
	{from = "2008/3/5", to="%DATE%"},
	{from = "SampleApp", to="%INSTALL_NAME%"},
}, post_func="", dest = "%INSTALL_DIR%/%SRC_NAME%", }%

%MODULEFILE{"file2.lua", replace = {
	{from = "%SRC_DIR%", to="%INSTALL_DIR%"},
	{from = "2008/3/5", to="%DATE%"},
	{from = "SampleApp", to="%INSTALL_NAME%"},
}, post_func="", dest = "%INSTALL_DIR%/%SRC_NAME%", }%

Description:
   * MODULEFILE: each module can contain one or several module files usually in its comment block, like this file. 
   * first string: the file path of the source template file. It does not contain parent path, it is assumed to be located at the same directory of the this module file. 
   * replace: an array of replaceables. Replaceable can contain predefined variables.	
   * INSTALL_DIR: where the user specified to install the module. such as "script/myapp"
   * INSTALL_NAME: what name the user specified to install, such as "MyModule"
   * SRC_NAME: name of the source template file. in the above case, it is "file1.lua"
   * SRC_DIR: directory of the source template file. in the above case, it is the directory of this module file. 
   * post_func: the function to be called to perform some manual refinement after replaceables are performed.
   * dest: the destination directory where the new instance of this file is installed. 
]]

if(not sample_modules) then sample_modules = {} end

-- this is an sample post processing function that replaces one string with another in the template file. 
-- @param input: input file text string
-- @return: result file text string. 
function sample_modules.file1_post_func(input)
	return string.gsub(input, "LiXizhi", "ParaEngine Corporation");
end