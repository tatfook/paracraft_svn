--[[
Title:
Author(s): Leio
Date: 2009/9/3
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/API/minigame/paraworld.minigame.lua");
-------------------------------------------------------
]]

-- create class
commonlib.setfield("paraworld.minigame", {});
--[[
/// <summary>
    /// �ύ��Ϸ����
    /// ���ղ�����
    ///     gameName
    ///     score
    /// ����ֵ��
    ///     issucccess
    ///     [ errorcode ]
    /// </summary>

--]]
paraworld.create_wrapper("paraworld.minigame.SubmitRank", "%MAIN%/API/MiniGame/SubmitRank");
--[[
/// <summary>
    /// ȡ��ָ����Ϸ�Ļ������а�
    /// ���ղ�����
    ///     gameName
    /// ����ֵ��
    ///     ranks[list]
    ///         nid
    ///         score
    ///     [ errorcode ]
    /// </summary>
--]]
paraworld.create_wrapper("paraworld.minigame.GetRank", "%MAIN%/API/MiniGame/GetRank");