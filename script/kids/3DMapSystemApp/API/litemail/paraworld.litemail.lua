--[[
Title: litemail info
Author(s): Leio
Date: 2009/11/17
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/API/litemail/paraworld.litemail.lua");
-------------------------------------------------------
]]

-- create class
commonlib.setfield("paraworld.litemail", {});
----------------------------------------------------------------------------------------------

--[[
	/// <summary>
	/// �û��ύͶ��
	/// ���ղ�����
	/// nid ��ǰ�û���NID
	/// cid ������1�������䣬2��������£�3:�û���Ը��100������ 101:С����
	/// title Ͷ��ı��⣨���200���ַ���
	/// msg Ͷ�����ݣ����1000���ַ���
	/// ����ֵ��
	/// issuccess
	/// [errorcode]
	/// </summary> 
--]]
paraworld.create_wrapper("paraworld.litemail.Add", "%MAIN%/API/Posts/Add");


