-- Func: 战斗命令解析系统
-- Author: Johny

-- 命令格式：
--        1                    2        3
-- 战斗类型_角色Group.instanceID_角色指令 
-- cityhall
-- pve

module("FCmdParseSystem", package.seeall)

-- 传入命令总接口
function parseCommand(_cmd)
	local _table = extern_string_split_(_cmd, '_')
	local _type = _table[1]
	if _type == "cityhall" then
	   parseCommand_CityHall(_table)
	elseif _type == "pve" then
	   parseCommand_Pve(_table)
	end
end

-- 解析城镇大厅指令
function parseCommand_CityHall(_table)
	local _role = FightSystem.mHallManager:getMyRole()
	if not _role then return end
	local _cmd = _table[3]
	if _cmd == "move" then
	   parseCommand_Move(_role, _table)
	end
end

-- 解析副本闯关指令
function parseCommand_Pve(_table)
	local _role = nil
	local _roleID = _table[2]
	if _roleID == "0" then 
	   _role = FightSystem:GetKeyRole()
	else
	   local _tmp = extern_string_split_(_roleID, '+')
	   _role = FightSystem.mRoleManager:getRole(_tmp[1], tonumber(_tmp[2]))
	end
	if not _role then return end 
	local _cmd = _table[3]
	if _cmd == "move" then
	   parseCommand_Move(_role, _table)
	elseif _cmd == "jump" then
	   parseCommand_Jump(_role, _table)
	elseif _cmd == "block" then
	   parseCommand_Block(_role, _table)
	elseif _cmd == "skill" then
	   parseCommand_skill(_role, _table)
	elseif _cmd == "chooserole" then
	   parseCommand_ChooseRole(_table)
	elseif _cmd == "cancelblock" then
	   parseCommand_Cancelblock(_role,_table)
	end
end

-- 解析移动指令
-- pve_roleid_move_param1_param2
function parseCommand_Move(_role, _table)
	local _dir = tonumber(_table[4])
	local _deg = tonumber(_table[5])
	if not _role then return end
	_role:OnFTCommand(_dir, _deg)
end

-- 解析跳跃指令
function parseCommand_Jump(_role)
	if not _role then return end
	_role:PlayJump()
end

function parseCommand_Block(_role)
	if not _role then return end
	_role:PlayBlock()
end

-- 解析取消格挡指令
function parseCommand_Cancelblock(_role)
	if not _role then return end
	_role:StopBlock()
end

-- 解析技能
-- pve_roleid_skill_skilltype_param1_param2
-- skilltype: combine : skillid : roleskill : clear
function parseCommand_skill(_role, _table)
	if not _role then return end
   local _skilltype = _table[4]
   local _skillid = _table[5]
   if _skilltype == "combine" then
      _role.mSkillCon:playCombineSkill()
   elseif _skilltype == "skillid" then

   elseif _skilltype == "roleskill" then
   	  if _skillid == "special1" then
   	     _role:playSpecialSkill1()
   	  elseif _skillid == "special2" then
   	  	 _role:playSpecialSkill2()
   	  elseif _skillid == "special3" then
   	  	 _role:playSpecialSkill3()
   	  elseif _skillid == "normal" then
   	  	 
   	  end
   elseif _skilltype == "clear" then
   	  _role.mSkillCon:ClearSkillStack()
   end
end

-- 解析战斗中选角色指令
-- pve_roleid_chooserole_roleindex
function parseCommand_ChooseRole(_table)
	local _posIndex = tonumber(_table[4])
	cclog("parseCommand_ChooseRole == " .. _posIndex)
	FightSystem.mTouchPad:ChooseRoleIndex(_posIndex)
end