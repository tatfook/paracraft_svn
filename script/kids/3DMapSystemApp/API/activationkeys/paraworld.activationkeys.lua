--[[
Title:
Author(s): Leio
Date: 2009/12/7
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/API/activationkeys/paraworld.activationkeys.lua");
-------------------------------------------------------
]]

-- create class
commonlib.setfield("paraworld.activationkeys", {});
--[[
 /// <summary>
        /// ȡ��ָ���û����䵽��CDKeys���û��ɽ���ת���������û�
        /// ���ղ�����
        ///     nid
        /// ����ֵ��
        ///     list [list]
        ///         keycode
        ///         owner  -1��ʾ��δ��ʹ�ã������ʾʹ���ߵ�NID
        ///     [ errorcode ]
        /// </summary>

--]]
paraworld.create_wrapper("paraworld.activationkeys.GetActivationKeys", "%MAIN%/API/Users/GetActivationKeys");
--[[
 /// <summary>
    /// ָ�����û����Ƽ��û���ý���
    /// ���ղ�����
    ///     nid ��ȡ�������û�
    /// ����ֵ��
    ///     issuccess
    ///     [ errorcode ]
    /// </summary>

--]]
paraworld.create_wrapper("paraworld.activationkeys.IAmInvitedBy", "%MAIN%/API/Users/IAmInvitedBy");