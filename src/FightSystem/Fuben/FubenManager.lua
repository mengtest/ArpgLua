-- Name: FubenManager
-- Func: 副本数据处理器
-- Author: Lvyunlong

require "FightSystem/Fuben/FubenConfig"
require "FightSystem/Fuben/FubenBaoxiang"
require "FightSystem/Fuben/FubenMoney"
require "FightSystem/Fuben/FubenDropController"
require "FightSystem/Fuben/FubenShowPveController"

local _INTERVAL_LOAD_FIGHT_CORUTINE_	=  0.03


FubenManager = {}

function FubenManager:initVars()
	self.mCurId = nil		--当前ID
	self.mBoardsData = nil		--最大通关时间
	self.mBoardMaxTime = nil 		--最大通关时间
	self.mLootID = nil   			--奖励ID
	self.mCount = 0   				--副本版面数量
	self.mMapData = nil				--地图数据
	self.mControllerData = nil		--控制器数据
	self.mCurBoardNum = 0		--当前第几个版面
	self.mCurTime = 0				--当前剩余时间
	self.mtablemonster = {}			--控制器里面
	self.isTick = false
	self.misAutoNextBoard = false
	self.mRoleLeftMargin = 0
	self.mtick = 0
	self.mCurControllerKill = 0
	self.mCurKillFriend = 0
	self.mResultTick = -1
	self.mIshuitui = false
	self.mHuitui_X = 0.0
	self.mAspeed_x = 0.0
	self.misTickBornMonster = true
	self.mBaoxiangtable = {}
	self.mPveLevel = nil
	self.mCurBoardMonster = nil
	self.misLookFriend = false
	self.mAutoAttack = false
	self.mLeftLineX = 0   --大于等于0的数
	self.mRightLineX = 0  --大于等于0的数

	self.mLeftMAXLineX = 0  --大于等于0的数
	self.mRightMAXLineX = 0 --大于等于0的数

	self.mResult = nil
	--CG列表
	--副本结束条件
	self.mFinishConditionTable = {}

	--副本当前替补
	self.mSubstitutionCount = 0
	self.mSubstitutionEnemyCount = 0
	self.mSendresult = "none"

	--副本已经结束
	self.mFubenFinishTick = nil
	--副本Go时间统计
	self.mGoTime = nil
	--副本掉落器
	
	--当前模式类型
	self.mFubenModel = nil
	--当前模式参数
	self.mFubenModelParameter = nil
	--AI移动延迟1秒
	self.mActivateAIaction = 0
	-- 预先加载怪物
	self.mPrestrainCount = 0
	-- 版面长度
	self.mCurBoardMinX = 0
	self.mCurBoardMaxX = 0
	self.mMidTextSize = 23
	-- 触发器延时
	self.TriggerDelayTimeList = {}
	self.ChibangNode = nil


	if not globaldata:isSectionVisited(1,1,1) and (globaldata.clickedchapter == 1 and globaldata.clickedsection == 1 and globaldata.clickedlevel == 1 ) and globaldata.PvpType == "fuben" then
		self.mIsFightGuide = true
		self.mMonsterCount = 0                                
	end
	if globaldata:isSectionVisited(1,1,1) and not globaldata:isSectionVisited(1,1,2) and (globaldata.clickedchapter == 1 and globaldata.clickedsection == 2 and globaldata.clickedlevel == 1 ) and globaldata.PvpType == "fuben" then
		self.mIsFightGuide_1_2 = true
	end
	if globaldata:isSectionVisited(1,1,2) and not globaldata:isSectionVisited(1,1,3) and (globaldata.clickedchapter == 1 and globaldata.clickedsection == 3 and globaldata.clickedlevel == 1 ) and globaldata.PvpType == "fuben" then
		self.mIsFightGuide_1_3 = true
	end
	if globaldata:isSectionVisited(1,1,3) and not globaldata:isSectionVisited(1,1,4) and (globaldata.clickedchapter == 1 and globaldata.clickedsection == 4 and globaldata.clickedlevel == 1 ) and globaldata.PvpType == "fuben" then
		self.mIsFightGuide_1_4 = true
	end

	if globaldata:isSectionVisited(1,1,4) and not globaldata:isSectionVisited(1,1,5) and (globaldata.clickedchapter == 1 and globaldata.clickedsection == 5 and globaldata.clickedlevel == 1 ) and globaldata.PvpType == "fuben" then
		self.mIsFightGuide_1_5 = true
	end

	if globaldata:isSectionVisited(1,1,5) and not globaldata:isSectionVisited(1,1,6) and (globaldata.clickedchapter == 1 and globaldata.clickedsection == 6 and globaldata.clickedlevel == 1 ) and globaldata.PvpType == "fuben" then
		self.mIsFightGuide_1_6 = true
	end
	if globaldata:isSectionVisited(1,1,7) and not globaldata:isSectionVisited(1,1,8) and (globaldata.clickedchapter == 1 and globaldata.clickedsection == 8 and globaldata.clickedlevel == 1 ) and globaldata.PvpType == "fuben" then
		self.mIsFightGuide_1_8 = true
		self.mSelectCount = 0
	end

	if globaldata:isSectionVisited(1,1,8) and not globaldata:isSectionVisited(1,2,1) and (globaldata.clickedchapter == 2 and globaldata.clickedsection == 1 and globaldata.clickedlevel == 1 ) and globaldata.PvpType == "fuben" then
		self.mIsFightGuide_2_1 = true
		self.mSelectCount = 0
	end

	self.mStartBoardX = 0

end

function FubenManager:Destroy()
	FightSystem:UnloadTouchPad()
	NetSystem:removeGSReLoginFunc("Fubenresult")
	self.mCurId = nil		
	self.mBoardsData = nil		--最大通关时间
	self.mBoardMaxTime = nil		--最大通关时间
	self.mLootID = nil  			--奖励ID
	self.mCount = nil  			--副本版面数量
	self.mMapData = nil 				--地图数据
	self.mControllerData = nil		--控制器数据
	self.mCurBoardNum = nil			--当前第几个版面
	self.mCurTime = nil				--当前剩余时间
	self.mtablemonster = nil
	self.isTick = nil
	self.misAutoNextBoard = nil
	self.mRoleLeftMargin = nil
	self.mtick = nil
	self.mCurControllerKill = nil
	self.mResult = nil
	self.mResultTick = -1
	self.mIshuitui = nil
	self.mHuitui_X = nil
	self.mAspeed_x =nil
	self.misTickBornMonster = nil
	self.mCurBoardMonster = nil
	self.mRoot = nil
	self.mFinishTick = nil
	self.mFubenFinishTick = nil
	self.mGoTime = nil
	self.mKofFirstmonsterPos = nil
	self.mKofmonsterTable = nil
	self.mDropController = nil
	self.Fuben1 = nil
	self.mPrestrainCount = nil
	self.mCurBoardMaxX = nil
	self.mCurBoardMinX = nil
	self.TriggerDelayTimeList = nil
	self.mCurKillFriend = nil
	self.mIsFightGuide = nil
	self.mDodgeCount = nil 
	self.mMonsterCount = nil 
	self.ChibangNode = nil
	self.IsGuideStep6_1 = nil
	self.IsGuideStep10_1 = nil
	self.mIsFightGuide_1_3 = nil
	self.mIsFightGuide_1_6 = nil
	self.mIsFightGuide_1_8 = nil
	self.mIsFightGuide_1_2 = nil
	self.mIsFightGuide_1_4 = nil
	self.mIsFightGuide_1_5 = nil
	self.mIsFightGuide_2_1 = nil

	globaldata.wait = nil
	self.IsExamineDis = nil
	self.IsShowGuanqia = nil
	self.mShowPveController = nil
end

function FubenManager:Release()
	--
	_G["FubenManager"] = nil
  	package.loaded["FubenManager"] = nil
  	package.loaded["FightSystem/Fuben/FubenManager"] = nil
end

function FubenManager:Init(rootNode,_id,PveLevel)
	self:initVars()
	self.mSectionId = _id
	self.mPveLevel = PveLevel
	self.mRoot = rootNode
	self:setInitBoardData(_id)
	
	self.isTick = true
	self:UpDateBoardLine()
	self:DetectAutoBtn()
	local function callFinish( ... )
		self:GuideStep1()
		self:Guide1_3Step1()
		self:Guide1_8Step1()
		self:Guide1_6Step1()
		self:Guide1_2Step1()
		self:Guide1_5Step1()
		self:Guide1_4Step1()
		self:Guide2_1Step1()
		if globaldata.PvpType == "fuben" then
			if FightSystem:isEnabledFubenAuto() then
				FightSystem.mTouchPad:setCheckAuto(true)
			end
		end
	end
	--放CG
	local reslut = self:PlayCGById(self.mBoardsData.Board_CGTrigger,true,callFinish)
	if not reslut then
		self:GuideStep1()
		self:Guide1_3Step1()
		self:Guide1_8Step1()
		self:Guide1_6Step1()
		self:Guide1_2Step1()
		self:Guide1_5Step1()
		self:Guide1_4Step1()
		self:Guide2_1Step1()
		if globaldata.PvpType == "fuben" then
			if FightSystem:isEnabledFubenAuto() then
				FightSystem.mTouchPad:setCheckAuto(true)
			end
		end
		self:ShowSchool()
	end
end

-- 加载模式类型
function FubenManager:LoadModel()
	self.mFubenModel = self.mBoardsData.Board_Model
	if self.mFubenModel == 4 then

		self.mKofmonsterTable = {}
		self.mKofFirstmonsterPos = nil
	elseif self.mFubenModel == 5 then
		self.mFubenModelParameter = self.mBoardsData.Board_ModelParam
		self.misArrive = false
		self.CurKillMonster = 0
	elseif self.mFubenModel == 7 then
		self.mFubenModelParameter = self.mBoardsData.Board_ModelParam
	end
	--当前模式参数
	self:loadFriendCount()
end

function FubenManager:loadFriendCount()

	if self.mFubenModel == 1 then
		self:loadAllFriend()
	elseif self.mFubenModel == 2 then
		self:loadThreeFriend()
	elseif self.mFubenModel == 3 then
		self:loadAllFriend()		
	elseif self.mFubenModel == 4 then
		-- KOF
		self:loadKOFFriend()
	elseif self.mFubenModel == 5 then
		-- 上一人
		self:loadOneFriend()
	elseif self.mFubenModel == 6 then
		self:loadAllFriend()
	elseif self.mFubenModel == 7 then
		self:loadAllFriend()
	elseif self.mFubenModel == 8 then
		self:loadAllFriend()
	end
end

function FubenManager:LoadBattleFriendCount(_id,_count)
	local Db = DB_BoardsConfig.getDataById(_id)

	if Db.Board_Model == 1 then
		return _count
	elseif Db.Board_Model == 2 then
		local FriendCount = 3
		if self.mBeginFriendCount > _count then
			FriendCount = _count
		end
		return FriendCount
	elseif Db.Board_Model == 3 then
		return _count		
	elseif Db.Board_Model == 4 then
		return _count
	elseif Db.Board_Model == 5 then
		return 1
	elseif Db.Board_Model == 6 then
		return _count
	elseif Db.Board_Model == 7 then
		return _count
	elseif Db.Board_Model == 8 then
		return _count
	end

end

-- 上所有人
function FubenManager:loadAllFriend()
	local _count = globaldata:getBattleFormationCount()
	self.mSubstitutionCount = _count - 3
	if self.mSubstitutionCount < 0 then
		self.mSubstitutionCount = 0
	end
	self.mBeginFriendCount = 3
	if self.mBeginFriendCount > _count then
		self.ShowHeadCount = _count
	else
		self.ShowHeadCount = self.mBeginFriendCount
	end
end
-- 上3个人
function FubenManager:loadThreeFriend()
	local _count = globaldata:getBattleFormationCount()
	self.mSubstitutionCount = 0
	self.mBeginFriendCount = 3
	if self.mBeginFriendCount > _count then
		self.ShowHeadCount = _count
	else
		self.ShowHeadCount = self.mBeginFriendCount
	end
end

-- 上1个人
function FubenManager:loadOneFriend()
	local _count = globaldata:getBattleFormationCount()
	self.mBeginFriendCount = 1
	self.mSubstitutionCount = 0
	self.ShowHeadCount = 1
end

-- 轮流上1 + 1 + 1 
function FubenManager:loadKOFFriend()
	local _count = globaldata:getBattleFormationCount()
	self.mBeginFriendCount = 1
	self.mSubstitutionCount = _count - 1
	if self.mSubstitutionCount < 0 then
		self.mSubstitutionCount = 0
	elseif self.mSubstitutionCount >= 3 then
		self.mSubstitutionCount = 2
	end
	self.ShowHeadCount = self.mBeginFriendCount
end

-- 载入友方
function FubenManager:loadFriendRoles(startX)
    local _pos = cc.p(self.mBoardsData.Board_StartPositionX*1140+startX,self.mBoardsData.Board_StartPositionY*770)
    local _friendPosTable = {_pos, cc.p(_pos.x - 50, _pos.y + 25), cc.p(_pos.x - 50, _pos.y - 25),cc.p(_pos.x - 75, _pos.y + 50),cc.p(_pos.x - 75, _pos.y - 50)}
	local _count = globaldata:getBattleFormationCount()
	for i = 1, _count do
		if i <= self.mBeginFriendCount then
			_pos = _friendPosTable[i]
			local role = FightSystem.mRoleManager:LoadFriendRoles(i, _pos)
			if i ~= 1 then
				role.mAI.mActivateFriendAI = true
				role.mAI:setOpenAI(false)
			else
				role.mAI.mActivateAIKeyRole = true
			end
			if self.mFubenModel == 6 then
				role:AddBuff(103)
			end
		end
	end

	-- for i=1,30 do
	-- 	FightSystem.mRoleManager:LoadFriendRoles(2, _pos)
	-- end
	--cclog("进入副本，共载入友军人数:  " .. _count)
end

function FubenManager:loadShowPveRoles()

    local _friendPosTable = {cc.p(0,770),cc.p(450,120),cc.p(0,770)}
	local _count = globaldata:getBattleFormationCount()
	for i = 1, _count do
		if i == 1 then
			local role = FightSystem.mRoleManager:LoadFriendRoles(i, _friendPosTable[i])
			role.mSkillCon.mMp = 100
		else
			local role = FightSystem.mRoleManager:LoadFriendRoles(i, _friendPosTable[i])
			role.mAI:setOpenAI(false)
			role.mSkillCon.mMp = 100
		end
	end
	local _enemyPosTable = {cc.p(2120,190),cc.p(2020,120),cc.p(2120,50)}
	local _count = globaldata:getBattleEnemyFormationCount()
	for i = 1, _count do
		local role = FightSystem.mRoleManager:LoadEnemyPlayer(i, _enemyPosTable[i])
		role.mAI:setOpenAI(false)
		role.mSkillCon.mMp = 100
		role:FaceLeft()
		role.mArmature:setVisiMonsterBlood(false)
	end

	self.mShowPveController:InitRoles()

	FightSystem.mSceneManager.mCamera:Tick()
	FightSystem.mSceneManager.mCamera:setStopTick(true)
end


function FubenManager:setInitBoardData(_id)
	self.mBoardsData = nil
	self.mBoardsData = DB_BoardsConfig.getDataById(_id)

	if self.mBoardsData.Board_Type == FubenConfig.BOARD_TYPE.START_BOARD then
		self.mLengthAdd = self.mBoardsData.Board_LengthAdd
	end
	--if self.mLengthAdd ~= 0 then
	if self.mCurBoardMaxX == 0 then
		self.mCurBoardMinX = 0
	else
		self.mCurBoardMinX = self.mCurBoardMaxX
	end
	self.mCurBoardMaxX = self.mCurBoardMaxX + 1140*(1+self.mLengthAdd)
	--end
	self:setFubenNeedData(self.mBoardsData)
	self:setFinishCondition(self.mBoardsData)
	self.mCurBoardNum = self.mCurBoardNum + 1
	if not self.mIsFightGuide then
		self:setFubenDifficultydegree()
	end
	self.mMapData = DB_MapConfig.getDataById(self.mBoardsData.Board_MapID)

end

function FubenManager:setFinishCondition(data)
	if data.Board_FinishCondition == 2 then
		self.mFinishConditionTable = {}

		local ConditionParam = data.Board_FinishConditionParam[self.mPveLevel]
		for k,v in pairs(ConditionParam ) do
			table.insert(self.mFinishConditionTable,v)
		end
	elseif data.Board_FinishCondition == 4 then
		 
	end
end

-- 检测人物是否到达指定区域
function FubenManager:TickKeyRoleDestination()
	if self.mBoardsData.Board_FinishCondition == 4 then
		local role = FightSystem:GetKeyRole()
		if role then
			local param = self.mBoardsData.Board_FinishConditionParam
			local _rect = cc.rect( param[1], param[2], param[3], param[4])
			if cc.rectContainsPoint(_rect, cc.p(role:getPositionX(),role:getPositionY())) then		
               	self:autoNextBoard()
			end
		end
	end
end


-- 三星通关奖励
function FubenManager:SanxingTongguan()
	self.mSanxingCondition = {}
	self.mSanxingCondition[self.mBoardsData.Star_Condition1] = {}
	self.mSanxingCondition[self.mBoardsData.Star_Condition1][1] = self.mBoardsData.Star1_Value1
	self.mSanxingCondition[self.mBoardsData.Star_Condition1][2] = self.mBoardsData.Star1_Value2
	self.mSanxingCondition[self.mBoardsData.Star_Condition1][3] = {1,1}

	self.mSanxingCondition[self.mBoardsData.Star_Condition2] = {}
	self.mSanxingCondition[self.mBoardsData.Star_Condition2][1] = self.mBoardsData.Star2_Value1
	self.mSanxingCondition[self.mBoardsData.Star_Condition2][2] = self.mBoardsData.Star2_Value2
	self.mSanxingCondition[self.mBoardsData.Star_Condition2][3] = {2,1}

	self.mSanxingText = {self.mBoardsData.Star1_Text,self.mBoardsData.Star2_Text,self.mBoardsData.Star3_Text}

	if self.mSanxingCondition[7] then
		self.mDeadscenelist = {}
	end

	if self.mSanxingCondition[2] then
		self.mFriendDeadCount = 0
	end
end

--查找当前副本需要的数值
function FubenManager:setFubenNeedData(data)
	if data.Board_Type == FubenConfig.BOARD_TYPE.START_BOARD then
		-- load scene
		if globaldata.PvpType == "fuben" then
			self:SanxingTongguan()
		end
		local _mapID = 2
		if self.mBoardsData then
	       _mapID = self.mBoardsData.Board_MapID
		end
		FightSystem.mSceneManager:LoadSceneView(FightConfig.FIGHTWINDOW_Z_SCENEVIEW, self.mRoot, _mapID)
		self:setdatainit()
		self.mBoardMaxTime = data.Board_MaxTime
		self.mCount = data.Board_Count
		self.mLeftMAXLineX = 0   --大于等于0的数
		self.mRightMAXLineX = FightSystem.mSceneManager:GetTiledLayer().mWidth --大于等于0的数
		if data.Board_OriginMove ~= 0 then
			self.mCurBoardMinX = 1140*data.Board_OriginMove
			self.mCurBoardMaxX = self.mCurBoardMaxX + self.mCurBoardMinX
			self.mStartBoardX = self.mCurBoardMinX
			FightSystem:GetFightSceneView():MoveAllLayersLeft(self.mStartBoardX)
			local keypos = cc.p(self.mBoardsData.Board_StartPositionX*1140+self.mStartBoardX ,self.mBoardsData.Board_StartPositionY*770)
			FightSystem.mSceneManager.mCamera:BeginCameraForFight(keypos,false)
		end
		-- load model
		self:LoadModel()
		-- load role
		if self.IsShowGuanqia then
			self:loadShowPveRoles()
		else
			self:loadFriendRoles(self.mCurBoardMinX)
		end
		
		-- load enemyplayer
		if globaldata.PvpType == "blackMarket" then
			self:loadPlunderRoles(self.mCurBoardMinX)
			FightSystem.mRoleManager:AllPlayerAiStop(false)
		end

		self.mCurTime = self.mBoardMaxTime

		FightSystem:LoadTouchPad(FightConfig.FIGHTWINDOW_Z_TOUCHPAD, self.mRoot,self.mCurTime)
		FightSystem.mTouchPad:SetTime(self.mCurTime)
		if self.mFubenModel == 5 then
			--FightSystem.mTouchPad:setPassText(string.format(getDictionaryText(self.mBoardsData.Name),self.mBoardMaxTime,0,self.mFubenModelParameter))
		else
			--FightSystem.mTouchPad:setPassText(getDictionaryText(self.mBoardsData.Name))
		end
		if self.IsShowGuanqia then
			FightSystem.mTouchPad:setCancelledTouchMove(true)
			FightSystem.mTouchPad:InitShowPveUI()
		end

		self:AutoFightFuben()
	elseif	data.Board_Type	== FubenConfig.BOARD_TYPE.OVER_BOARD then
		self.mLootID = data.Board_LootID
	end	
end

function FubenManager:AutoFightFuben()
	if globaldata.PvpType == "wealth" then
		if FightSystem:isEnabledFangkeAuto() then
			FightSystem.mTouchPad:setCheckAuto(true)
		end
	elseif globaldata.PvpType == "tower" then
		if FightSystem:isEnabledPataAuto() then
			FightSystem.mTouchPad:setCheckAuto(true)
		end
	end
end

-- 加载黑市敌方玩家
function FubenManager:loadPlunderRoles(startX)
	local _pos = cc.p((self.mBoardsData.Board_StartPositionX+0.5)*1140+startX,self.mBoardsData.Board_StartPositionY*770)
    local _enemyPlayerPosTable = {_pos, cc.p(_pos.x - 50, _pos.y + 25), cc.p(_pos.x - 50, _pos.y - 25),cc.p(_pos.x - 75, _pos.y + 50),cc.p(_pos.x - 75, _pos.y - 50)}
	local count = globaldata:getBattleEnemyFormationCount()
	self.mPlunderPlayerCount = count
	for i = 1, count do
		local _pos = _enemyPlayerPosTable[i]
		local role = FightSystem.mRoleManager:LoadEnemyPlayer(i, _pos)
		role:FaceLeft()
		role:Up_Bench(_pos.x,_pos.y,1)
	end
end

--设置副本控制难度系数
function FubenManager:setFubenDifficultydegree()
	--cclog("FubenDifficultydegree===== ".. self.mPveLevel)
	local diffdegreekey = "Board_EeayController"
	if self.mPveLevel == 1 then
		diffdegreekey = "Board_EeayController"
	elseif self.mPveLevel == 2 then
		diffdegreekey = "Board_NormalController"
	elseif self.mPveLevel == 3 then
		diffdegreekey = "Board_HardController"
	end
	self.mCurBoardMonster = 0
	self.mtablemonster = nil
	self.mIndexcontrollId = 0
	for i,v in ipairs(self.mBoardsData[diffdegreekey]) do
		self.mControllerData = DB_ControllerConfig.getDataById(v)
		self.mControllerType = self.mControllerData.Controller_Type
		if self.mControllerType == 1 then
			self.mGroupTime = self.mControllerData.Controller_GroupData[1]
			self.mGroupTickTime = 0
			self.mGroupDeadMonster = 0
			self.mGroupKillAllTime = 0
			self.mGroupAllCountIndex = 0
			self.mGroupAddCount = self.mControllerData.Controller_GroupData[2]
			self.mGroupLimitUp = self.mControllerData.Controller_GroupData[3]
			self.mGroupAllCount = self.mControllerData.Controller_GroupData[4]
			self.mGroupPriority = self.mControllerData.Controller_GroupPriority
		end
		self:InitController()
		self.mIndexcontrollId = self.mIndexcontrollId + 1
	end

	if self.mControllerType and self.mControllerType == 1 and self.mGroupTime < 0 then
		local monstercount = -self.mGroupTime
		for i=1,self.mGroupAllCount do
			monstercount = monstercount + i*self.mGroupLimitUp + self.mGroupAddCount
		end
		if type(self.mGroupPriority) == "table" then
			monstercount = monstercount + #self.mGroupPriority
		end
		self.mCurBoardMonster = monstercount
	end
	self:PrestrainBornMonster()

	if self.mFubenModel	== 4 then
		self.KofMaxCount = #self.mKofmonsterTable
	    for i = 1,#self.mKofmonsterTable do
          local _infoDB = DB_MonsterConfig.getDataById(self.mKofmonsterTable[i])
          local Icons = {_infoDB.Monster_Icon ,_infoDB.Monster_Icon }
          table.insert(FightSystem.mTouchPad.MonsterKofList,Icons)
        end
   	    FightSystem.mTouchPad:InitKofMonsterHead(true)
	end
	self:AddKOFMonster(self.mKofFirstmonsterPos)

	if globaldata.PvpType == "blackMarket" then
		FightSystem.mRoleManager:AllPlayerAiStop(false)
	end

end

-- 初始化当前KOF monster
function FubenManager:AddKOFMonster(pos,isup)
	if self.mFubenModel ~= 4 then return end
	if self.mKofmonsterTable then
		if #self.mKofmonsterTable ~= 0 then
			local index = self.KofMaxCount - #self.mKofmonsterTable + 1
			local role = FightSystem.mRoleManager:LoadMonster(self.mKofmonsterTable[1],pos,nil,index)
			if isup then
				role:Up_Bench(pos.x,pos.y)
			end
			FightSystem.mTouchPad:ShowTeamsCount("monster",index)
			table.remove(self.mKofmonsterTable,1)
		end
	end
end

--初始化FubenManager
function FubenManager:setdatainit()
	self.mBoardMaxTime = nil 		--最大通关时间
	self.mLootID = nil  				--奖励ID
	self.mCount = 0   				--副本版面数量
	self.mMapData = nil 				--地图数据
	self.mControllerData = nil		--控制器
	self.mCurBoardNum = 0			--当前第几个版面
	self.mCurTime = 0				--当前剩余时间
	self.mtick = 0
end

-- 检测掠夺胜利条件
function FubenManager:TickPlunderResult()
	if globaldata.PvpType == "blackMarket" and FightSystem.mAISceneIDlist[4] and FightSystem.mAISceneIDlist[4] > 0 then
		self:Result("success")
	end
end

--设置副本控制难度系数
function FubenManager:Tick(delta)
	if not self.isTick then return end
		--CG
	self:TickPlunderResult()
	if StorySystem.mCGManager.mCGRuning then return end
	if self.mIsFightGuide and self.IsExamineDis then
		local role = FightSystem:GetKeyRole()
		local pos  = role:getPosition_pos()
		if 80 < cc.pGetDistance(self.Step2Pos, pos) then
			self.IsExamineDis = false
			FightSystem.mTouchPad:setCancelledTouchMove(true)
			self:GuideStep3()
		end
	end
	FightSystem.mTouchPad:Tick(delta)

	-- 延迟一秒AI执行 暂时去掉
	--self:ActivateAITick(delta)

	--if self:ResultTick(delta) then return end

	self:TickDropItem(delta)

	if self.mFinishTick then return end

	self:TickKeyRoleDestination()

	self:FubenTime(delta)

	if self.mHuitui_X ~= 0.0 then
		self.mSpeedX = MathExt.GetDisInUniformDeceleration(self.mSpeedX, self.mAspeed_x, 1*FightSystem:getGameSpeedScale())
   		if self.mSpeedX < 10 then
   			self.mSpeedX = 10
   		end

		local a = self.mSpeedX
		if self.mHuitui_X - a >0 then
			self.mHuitui_X = self.mHuitui_X -a
		else
			a = self.mHuitui_X
			self.mHuitui_X = 0
		end
		FightSystem.mSceneManager.mSceneView:MoveAllLayersLeft(a)
	end	

	self:PrestrainTickBorn()

	self:TickBorn(delta)

	self:TickDelayedTrigger(delta)
end

function FubenManager:PrestrainTickBorn()
	if self.mPrestrainCount ~= 0 then
		for i,v in pairs(self.mtablemonster) do
			local isborn = v:PrestrainBorn()
			if isborn then
				local role = self:LoadControllerItem(v,true)
				if self.mCurBoardNum ~= 1 and self.misAutoNextBoard then
					if role then
						role:setInvincible(true)
					end
				end
				self.mPrestrainCount = self.mPrestrainCount - 1
				self.mtablemonster[i] = nil
				break
			end
		end
	end
end

function FubenManager:ActivateAITick(delta)
	if self.mActivateAIaction  then
		if self.mActivateAIaction <= 0 then
			local friends = FightSystem.mRoleManager:GetFriendTable()
			local enemyers = FightSystem.mRoleManager:GetEnemyTable()
			for k,v in pairs(friends) do
				if v.mAI and not v.mAI.mActionOpen then
					v.mAI.mActionOpen = true
				end
			end

			for k,v in pairs(enemyers) do
				if v.mAI and not v.IsShowTimeBorn then
					v.mAI.mActionOpen = true
				end
			end
			self.mActivateAIaction = nil
		else
			self.mActivateAIaction = self.mActivateAIaction - delta
		end
	end
end

function FubenManager:ShowResult()
	-- if self.mResultTick ~= -1 then
	-- 	self.mResultTick = self.mResultTick + delta
	-- 	if self.mResultTick >= 3 then
	-- 		self.mResultTick = -1
			self.isTick = false
			FightSystem.mTouchPad:setVisible(false)
			if self.mResult == "success" then
				EventSystem:PushEvent(Event.GUISYSTEM_SHOW_BATTLERESULT_WIN)
			elseif  self.mResult == "fail" then
				EventSystem:PushEvent(Event.GUISYSTEM_SHOW_BATTLERESULT_LOSE)
			end
			-- if self.mSendresult == "back" then
			-- 	FightSystem.mTouchPad:setVisible(false)
			-- 	if self.mResult == "success" then
			-- 		EventSystem:PushEvent(Event.GUISYSTEM_SHOW_BATTLERESULT_WIN)
			-- 	elseif  self.mResult == "fail" then
			-- 		EventSystem:PushEvent(Event.GUISYSTEM_SHOW_BATTLERESULT_LOSE)
			-- 	end
			-- end
	-- 	end
	-- 	return true	
	-- end
	-- return false
end

function FubenManager:LookFriendLeng()
	local keyRole = FightSystem:GetKeyRole()
	local Rolewidth = keyRole.mSize.width/2
	local  pox = 0
	local  direction = "none"
	for k,v in pairs(FightSystem.mRoleManager.mFriendRoles) do
		if not v.IsKeyRole then
			if math.abs(keyRole:getShadowPos().x - v:getShadowPos().x) + Rolewidth + v.mSize.width/2 > pox then
				if keyRole:getShadowPos().x >= v:getShadowPos().x then
					direction = "right"
				else
					direction = "left"
				end	
				pox = math.abs(keyRole:getShadowPos().x - v:getShadowPos().x) + Rolewidth + v.mSize.width/2
			end	
		end	
	end
	return pox , direction
end

function FubenManager:GetFriendRoleXMinAndMax()
	local min = nil
	local max = nil
	local Rolemin = nil
	local Rolemax = nil

	for k,v in pairs(FightSystem.mRoleManager.mFriendRoles) do
		if not min then
			min = v:getShadowPos().x
			Rolemin = v
		else
			if min > v:getShadowPos().x then
				min = v:getShadowPos().x
				Rolemin = v
			end	
		end 
		if not max  then
			max = v:getShadowPos().x
			Rolemax = v
		else
			if max < v:getShadowPos().x then
				max = v:getShadowPos().x
				Rolemax = v
			end	
		end
	end
	return Rolemin,Rolemax
end

--初始化控制器
function FubenManager:InitController()
	local monsternum = 0
	for i = 1 ,self.mControllerData.Controller_MonsterCount do
		local index = i
		local Controller_ID = string.format("Controller_ID%d",i) 
		local Controller_Type = string.format("Controller_Type%d",i)
		local Controller_DelayTime = string.format("Controller_DelayTime%d",i)
		local Controller_PositionX = string.format("Controller_PositionX%d",i)
		local Controller_PositionY = string.format("Controller_PositionY%d",i)
		local monster = MonsterObject.new()

		--cclog("FubenManager:InitController()0" .. self.mControllerData.Controller_MonsterCount)

		monster.ID = self.mControllerData[Controller_ID]
		--cclog("FubenManager:InitController()ID =" .. monster.ID)
		monster.Type = self.mControllerData[Controller_Type]
		if monster.Type == 1 then
			monsternum = monsternum + 1
		end	
		--cclog("FubenManager:InitController()Type=" .. monster.Type)
		monster.DelayTime = self.mControllerData[Controller_DelayTime]
		--cclog("FubenManager:InitController()DelayTime=" .. monster.DelayTime)
		monster.PositionX = self.mControllerData[Controller_PositionX]
		--cclog("FubenManager:InitController()monster.PositionX=" .. monster.PositionX)
		monster.PositionY = self.mControllerData[Controller_PositionY]
		--cclog("FubenManager:InitController()monster.PositionY=" .. monster.PositionY)
		if not self.mtablemonster then
			self.mtablemonster = {}
		end	
		--table.insert(self.mtablemonster,monster)
		local keyId = self.mIndexcontrollId*32+i
		self.mtablemonster[keyId] = monster
	end
	self.mCurBoardMonster = self.mCurBoardMonster + monsternum
end

-- 触发器延时生效
function FubenManager:DelayedTriggerMonster(_Triggerid,_time)
	if _time == 0 then
		self:AddTriggerMonster(_Triggerid)
	else
		if not self.TriggerDelayTimeList[_Triggerid] then
			self.TriggerDelayTimeList[_Triggerid] = _time
		end
	end
end

-- Tick触发器
function FubenManager:TickDelayedTrigger(delta)
	for k,v in pairs(self.TriggerDelayTimeList) do
		self.TriggerDelayTimeList[k] = self.TriggerDelayTimeList[k] - delta
		if self.TriggerDelayTimeList[k] <= 0 then
			self:AddTriggerMonster(k)
			self.TriggerDelayTimeList[k] = nil
		end
	end
end


-- 加载触发器ID的怪物
function FubenManager:AddTriggerMonster(_Triggerid)
	local tempdel = {}
	if self.mtablemonster then
		for i,v in pairs(self.mtablemonster) do
			local isborn = v:BornByTriggerid(_Triggerid)
			if isborn then
				self:LoadControllerItem(v)
				table.insert(tempdel,i)
			end
		end
		for k,v in pairs(tempdel) do
			self.mtablemonster[v] = nil
		end
	end

end

--预加载怪物
function FubenManager:PrestrainBornMonster()
	if not self.mtablemonster then return end
	if self.mFubenModel	== 4 then
		local tempdel = {}		
		for i,v in pairs(self.mtablemonster) do
			local isborn = v:PrestrainBorn()
			if isborn then
				self:LoadControllerItem(v,true)
				table.insert(tempdel,i)
			end
		end
		for k,v in pairs(tempdel) do
			self.mtablemonster[v] = nil
		end
	else
		self.mPrestrainCount = 0
		for i,v in pairs(self.mtablemonster) do
			local isborn = v:PrestrainBorn()
			if isborn then
				self.mPrestrainCount = self.mPrestrainCount + 1	
			end
		end
		if self.mPrestrainCount ~= 0 then
			for i,v in pairs(self.mtablemonster) do
				local isborn = v:PrestrainBorn()
				if isborn then
					local role = self:LoadControllerItem(v,true)
					if self.mCurBoardNum ~= 1 and self.misAutoNextBoard then
						if role then
							role:setInvincible(true)
						end
					end
					self.mPrestrainCount = self.mPrestrainCount - 1
					self.mtablemonster[i] = nil
					break
				end
			end
		end
	end
end

-- 加载KOF怪物
function FubenManager:LoadMonsterByKof(item)
	if not self.mKofFirstmonsterPos then
		self.mKofFirstmonsterPos = cc.p(item.PositionX,item.PositionY)
	end
	table.insert(self.mKofmonsterTable,item.ID)
end

--加载当前Controller里面生物
function FubenManager:LoadControllerItem(item,isshowborn)
	if item.Type == 1 then
		if FightConfig.__DEBUG_FUBEN_ONE_MONSTERID_ then
			if self.Fuben1 then
				return 
			end
		end
		self.Fuben1 = 1
		if self.mFubenModel == 4 then
			local _infoDB = DB_MonsterConfig.getDataById(item.ID)
			self:LoadMonsterByKof(item)
		else
			local monsterId = item.ID
			if FightConfig.__DEBUG_FUBEN_ONE_MONSTERID_ then
				monsterId = FightConfig.__DEBUG_FUBEN_ONE_MONSTERID_
			end
			local _infoDB = DB_MonsterConfig.getDataById(monsterId)
			--cclog("加载 人物==   item.PositionX ===="..item.PositionX .. "===ID=="..item.ID)
			local role = FightSystem.mRoleManager:LoadMonster(monsterId,cc.p(item.PositionX,item.PositionY))
			if not isshowborn then
				role:ShowTimeBorn()
				--role.mShadow:setVisibleShadow(false)
				role.mArmature:setVisiMonsterBlood(false)
			else
				if role.mAI then
					role.mAI:AIActionDelay(1)
				end

				-- if self.mCurBoardNum == 0 then
				-- 	if role.mAI then
				-- 		role.mAI.mActionOpen = false
				-- 	end
				-- end
			end
			if _infoDB.Monster_Grade == 4 then
				FightSystem.mTouchPad:InitBossBar(role)
				if FightSystem.mFightType == "fuben" and globaldata.PvpType == "fuben" then
					FightSystem.mTouchPad:BossWarning()
				end
			end
			return role
		end

	elseif item.Type == 2 then
		--cclog("999999999999999")
	elseif item.Type == 3 then
		--cclog("加载 场景==   item.PositionX ===="..item.PositionX)
		--cclog("加载 场景==   item ID ===="..item.ID)
		if self.mFubenModel == 7 and self.mFubenModelParameter == item.ID then
			local scene = FightSystem.mRoleManager:LoadSceneAnimation(item.ID,cc.p(item.PositionX,item.PositionY),true)
			scene:initSceneMark()
			FightSystem.mTouchPad:createSceneAniBlood()
			self.mProtectScene = scene
		else
			FightSystem.mRoleManager:LoadSceneAnimation(item.ID,cc.p(item.PositionX,item.PositionY))
		end
	end	
end

function FubenManager:isTypeModel(_type)
	if self.mFubenModel == _type then
		return true
	end
	return false
end

--Tick出生的怪物
function FubenManager:TickBorn(delta)
	if not self.misTickBornMonster then return end
	if not self.mControllerType then return end
	if self.mPrestrainCount ~= 0 then return end
	if self.mControllerType == 0 then
		self:TickBornConType1(delta)
	elseif self.mControllerType == 1 and self.mGroupTime > 0 then
		self:TickBornConType2(delta)
	end
end

function FubenManager:TickBornConType1(delta)
	if not self.mtablemonster then return end
	local tempdel = {}
	for i,v in pairs(self.mtablemonster) do
		local isborn = v:TickBorn(delta)
		if isborn then
			self:LoadControllerItem(v)
			table.insert(tempdel,i)
		end
	end
	for k,v in pairs(tempdel) do
		self.mtablemonster[v] = nil
	end
end

function FubenManager:TickBornConType2(delta)
	if not self.mtablemonster then return end
	self.mGroupTickTime = self.mGroupTickTime + delta
	if self.mGroupAllCount <= 0 then return end
	if self.mGroupTickTime >= self.mGroupTime then
		self.mGroupTickTime = 0
		local canAddcount = self.mGroupLimitUp - FightSystem.mRoleManager:GetEnemyCount()
		if canAddcount > self.mGroupAddCount  then
			canAddcount = self.mGroupAddCount
		end
		if canAddcount > 0 then
			if self.mGroupAllCount - canAddcount <= 0 then
				canAddcount = self.mGroupAllCount
				self.mGroupAllCount = 0
			end
			local tempBorn = {}
			if type(self.mGroupPriority) == "table" then
				for k,v in pairs(self.mGroupPriority) do
					if canAddcount <= 0 then 
						break
					end
					self:LoadControllerItem(self.mtablemonster[v])
					canAddcount = canAddcount - 1
				end
				for i,v in pairs(self.mtablemonster) do
					local isFlag = false
					for k,Prior in pairs(self.mGroupPriority) do
						if Prior == i then
							isFlag = true
							break
						end
					end
					if not isFlag then
						table.insert(tempBorn,v)
					end
				end
			else
				for i,v in pairs(self.mtablemonster) do
					table.insert(tempBorn,v)
				end
			end
			local tempItemList = {}
			if canAddcount > 0 then
				for i=1,canAddcount do
					local size = #tempBorn
					local num = math.random(1,size)
					local born = table.remove(tempBorn,num)
					table.insert(tempItemList,born)
				end
				for k,v in pairs(tempItemList) do
					self:LoadControllerItem(v)
				end
			end
		end
	end
end

function FubenManager:TickBornConType3(_group, _pos, _monsterID)
	if not self.mtablemonster then return end
	if self.mControllerType and self.mControllerType == 1 and self.mGroupTime < 0 then 
		if self.mGroupAllCount <= self.mGroupAllCountIndex then return end
		self.mGroupDeadMonster = self.mGroupDeadMonster - 1
		if self.mGroupDeadMonster == self.mGroupTime then
			-- 该刷1波怪了
			self.mGroupDeadMonster = 0
			self.mGroupAllCountIndex = self.mGroupAllCountIndex + 1
			self.mGroupTime = -(self.mGroupAddCount + self.mGroupAllCountIndex*self.mGroupLimitUp + 1)
			local tempBorn = {}
			if type(self.mGroupPriority) == "table" then
				local index = self.mGroupPriority[self.mGroupAllCountIndex]
				self:LoadControllerItem(self.mtablemonster[index])
				for i,v in pairs(self.mtablemonster) do
					local isFlag = false
					for k,Prior in pairs(self.mGroupPriority) do
						if Prior == i then
							isFlag = true
							break
						end
					end
					if not isFlag then
						table.insert(tempBorn,v)
					end
				end
			else
				for i,v in pairs(self.mtablemonster) do
					table.insert(tempBorn,v)
				end
			end
			local Allnum = -(self.mGroupTime+1)
			local tempItemList = {}
			if Allnum > 0 then
				for i=1,Allnum do
					local size = #tempBorn
					local num = math.random(1,size)
					local born = table.remove(tempBorn,num)
					table.insert(tempItemList,born)
				end
				for k,v in pairs(tempItemList) do
					self:LoadControllerItem(v)
				end
			end
		end
	end
end

function FubenManager:onSanxingResult()
-- 统计4 三星奖励
	if globaldata.PvpType == "fuben" then

		self.SanxingResult = {0,0}

		if self.mSanxingCondition[1] then
			self.mSanxingCondition[1][3][2] = 0
			if self.mBoardMaxTime - self.mCurTime <= self.mSanxingCondition[1][1]  then
				self.mSanxingCondition[1][3][2] = 1
			end
		end

		if self.mSanxingCondition[2] then
			self.mSanxingCondition[2][3][2] = 1
			if self.mSanxingCondition[2][1] < self.mFriendDeadCount then
				self.mSanxingCondition[2][3][2] = 0
			end
		end

		if self.mSanxingCondition[4] then
			self.mSanxingCondition[4][3][2] = 0
			if self.mProtectScene  and self.mProtectScene.mIsLiving and self.mSanxingCondition[4][1] == self.mProtectScene.mDB.ID then
				if self.mSanxingCondition[4][2] <= self.mProtectScene.mCurHp/self.mProtectScene.mMaxHp*100 then
					self.mSanxingCondition[4][3][2] = 1
				end
			end
		end

		if self.mSanxingCondition[5] then
			for k,v in pairs(FightSystem.mRoleManager:GetFriendTable()) do
				if v.mIsLiving then
					if self.mSanxingCondition[5][1] > v.mPropertyCon.mCurHP/v.mPropertyCon.mMaxHP*100 then
						self.mSanxingCondition[5][3][2] = 0
						break
					end
				end
			end
		end

		if self.mSanxingCondition[6] then
			self.mSanxingCondition[6][3][2] = 0
			local friendcount = globaldata:getBattleFormationCount()
			for i=1,friendcount do
				local heroId = globaldata:getBattleFormationInfoByIndexAndKey(i, "id")
				if heroId == self.mSanxingCondition[6][1] then
					self.mSanxingCondition[6][3][2] = 1
					break
				end
			end
		end

		if self.mSanxingCondition[7] then
			self.mSanxingCondition[7][3][2] = 1
			for k,v in pairs(self.mSanxingCondition[7][1]) do
				if self.mDeadscenelist[v] then
					self.mDeadscenelist[v] = self.mDeadscenelist[v] - 1
					if self.mDeadscenelist[v] < 0 then
						self.mSanxingCondition[7][3][2] = 0
						break
					end
				else
					self.mSanxingCondition[7][3][2] = 0
					break
				end
			end
		end

		if self.mSanxingCondition[8] then
			self.mSanxingCondition[8][3][2] = 0
			if FightSystem.mTouchPad.mCombotop then
				if FightSystem.mTouchPad.mCombotop.countMax >= self.mSanxingCondition[8][1] then
					self.mSanxingCondition[8][3][2] = 1
				end
			else
				if 0 >= self.mSanxingCondition[8][1] then
					self.mSanxingCondition[8][3][2] = 1
				end
			end
		end

		for k,v in pairs(self.mSanxingCondition) do
			self.SanxingResult[v[3][1]] = v[3][2]
			if v[3][2] == 0 then
				globaldata.fubenstar = globaldata.fubenstar - 1
			end
		end
	end
end

function FubenManager:Result(_result)
	if self.mResult then return end
	FightSystem.mTouchPad.mResultTick = false
	self:onSanxingResult()
	self:FubenTongji(_result)

	if globaldata.PvpType == "fuben" then
		if not globaldata:isSectionVisited(1,2,1) and (globaldata.clickedchapter == 2 and globaldata.clickedsection == 1 and globaldata.clickedlevel == 1) and _result == "success" then
			if FightSystem.mTouchPad.mAutoTouchAttack then
				FightSystem:enableFubenAuto(true)
			end
		end
	end
	
	if not globaldata:isSectionVisited(1,1,1) and (globaldata.clickedchapter == 1 and globaldata.clickedsection == 1 and globaldata.clickedlevel == 1) and _result == "fail" and globaldata.PvpType == "fuben" then
		GUISystem:showLoading()
		globaldata:requestEnterBattle(true)
		return
	end
	self.mResult = _result
	if globaldata.PvpType == "blackMarket" then
		FightSystem.mTouchPad:setVisible(false)
		self:RegisterLoginBackResult(self.mResult)
		self:SendFubenResult(self.mResult)
		self:ShowResult()
		GUISystem:enableUserInput()
		return
	end	
	if _result == "success" and self.mBoardsData.Board_Finish_CGTrigger ~= 0 then
		GUISystem:enableUserInput()
		local function call()
			FightSystem.mTouchPad:ResultComplete()
			self:RegisterLoginBackResult(self.mResult)
			self:SendFubenResult(self.mResult)
			self:ShowResult()
		end
		local iscg = self:PlayCGById(self.mBoardsData.Board_Finish_CGTrigger,false,call,true)
		if not iscg then
			call()
		end
	else
		FightSystem.mTouchPad:ResultComplete()
		GUISystem:enableUserInput()
		self:RegisterLoginBackResult(self.mResult)
		self:SendFubenResult(self.mResult)
		self:ShowResult()
	end
end

function FubenManager:FubenTongji(_result)
	if globaldata.PvpType == "fuben" then
		local fubentype = "fb%d-%d"
		if globaldata.clickedlevel == 2 then
			fubentype = "fbjy%d-%d"
		end
		local key = string.format(fubentype,globaldata.clickedchapter,globaldata.clickedsection)
		if _result == "success" then
			AnySDKManager:td_fbSucc(key,globaldata.fubenstar)
		else
			if self.mCurTime <= 0 then
				AnySDKManager:td_task_fail(key, "timeout")
			else
				AnySDKManager:td_task_fail(key, "die")
			end
		end
	end

end

function FubenManager:KillAllfly()
	if self.mBoardsData.Board_FinishCondition == 4 then
		FightSystem.mRoleManager:removeAllFlyEnemy()
	end
end

-- 急速模式过关
function FubenManager:JisuSuccess()
	if self.mFubenModel == 5 then
		self.CurKillMonster = self.CurKillMonster + 1
		if self.mFubenModelParameter >= self.CurKillMonster then
			--FightSystem.mTouchPad:setPassText(string.format(getDictionaryText(self.mBoardsData.Name),self.mBoardMaxTime,self.CurKillMonster,self.mFubenModelParameter))
		end
		if self.mFubenModelParameter <= self.CurKillMonster and self.misArrive then
			self.misArrive = false
			self:ItemAllPickUp()
			self:KillAllfly()
			self:Result("success")
		end
	end
end


function FubenManager:autoNextBoard()
	if not self.mBoardsData then return end
	if self.mBoardsData.Board_NextBoardID == 0 then 
		--cclog("成功完成副本")
		if self.mFubenModel == 5 then
			if self.mFubenModelParameter <= self.CurKillMonster then
				self:ItemAllPickUp()
				self:KillAllfly()
				self:Result("success")
			else
				self.misArrive = true
			end
		else
			self:ItemAllPickUp()
			self:KillAllfly()
			self:Result("success")
		end
		return
	end
	FightSystem.mTouchPad:WaitDoublehitNum()
	self.misAutoNextBoard = true
	self.misTickBornMonster = false
	self.mCurControllerKill = 0
	self:ItemAllPickUp()
	self:NextBoardById()
	FightSystem.mRoleManager:SetFriendFollowKeyRole(true)
	self.mGoTime = 8
	FightSystem.mTouchPad:ShowgoNext()
	if self.mBoardsData.Board_CGTrigger ~= 0 then
		local function call()
			self:SceneRun()
			if FightSystem.mTouchPad.mBossWarning then
				FightSystem.mTouchPad.mBossWarning:resume()
			end
		end
		local iscg = self:PlayCGById(self.mBoardsData.Board_CGTrigger,false,call)
		if not iscg then
			self:SceneRun()
		else
			if FightSystem.mTouchPad.mBossWarning then
				FightSystem.mTouchPad.mBossWarning:pause()
			end
		end	
	else
		self:SceneRun()
	end
end

function FubenManager:NextBoardById()
	self:setInitBoardData(self.mBoardsData.Board_NextBoardID)
end

function FubenManager:IsautoNextBoard()
	return self.misAutoNextBoard
end

function FubenManager:RoleMovePos(_nextX,Role)
	local _sceneW = FightSystem.mSceneManager.mSceneView:GetSceneWidth()
	local Left_margin = 0.0
	local Right_margin = _sceneW
	local _boradW = 0.0
	local _keyRolewidth = FightSystem:GetKeyRole().mSize.width/2
	if StorySystem.mCGManager.mCGRuning then return end
	if self:IsautoNextBoard() then
		--不能走动的距离是跑出去的地图

		if  self:SceneRun() then
			return true
		end
		return  self:BoardFighting(_nextX,Role)
	else
		if self.mCount ~= 0 then
			return self:BoardFighting(_nextX,Role)
		end	
	end
	return true
end

function FubenManager:BoardFighting(_nextX,Role)
	local _keyRolewidth = Role.mSize.width/2
	local isLeft = true
	if _nextX < Role:getPosition_pos().x then
		isLeft = false
	end
	if _nextX - _keyRolewidth <= self:GetLeftLineX() then
		if not isLeft then
			return false
		end
	end
	if _nextX + _keyRolewidth >= self:GetRightLineX() then
		if isLeft then
			return false
		end
	end
	return true
end

function FubenManager:GetLeftCameraLineX()
	if self.mCurBoardNum == 1 then
		return self.mLeftLineX
	else
		local Leftx = self.mLeftLineX - FightConfig.MAP_EDGE
		if Leftx <= 0 then
			Leftx = 0
		end
		return Leftx
	end
end

function FubenManager:GetRightCameraLineX()
	if self.mCurBoardNum == self.mCount then
		return self.mRightLineX
	else
		local Rightx = self.mRightLineX + FightConfig.MAP_EDGE
		return Rightx
	end
end

function FubenManager:GetLeftLineX()
	if self.mCurLineNum == 1 then 
		return self.mLeftLineX + FightConfig.MAP_EDGE
	else
		return self.mLeftLineX
	end
end

function FubenManager:GetRightLineX()
	if self.mCurLineNum == self.mCount then
		return self.mRightLineX - FightConfig.MAP_EDGE	
	else
		return self.mRightLineX
	end
end

function FubenManager:InformNextBoard()
	if self.IsGuideStep6_1 then
		self.IsGuideStep6_1 = nil
		self:GuideStep6_1()
	elseif self.IsGuideStep10_1 then
		self.IsGuideStep10_1 = nil
		self:GuideStep10_1()
	end
end

function FubenManager:UpDateBoardLine()
	self.mCurLineNum = self.mCurBoardNum
	FightSystem.mRoleManager:setAllMonsterInvincible(false)
	if self.mLengthAdd ~= 0 then
		local _sceneW = FightSystem.mSceneManager.mSceneView:GetSceneWidth()
		if self.mCount == 1 then
			self.mLeftLineX = self.mStartBoardX
			self.mRightLineX = self.mCurBoardMaxX
		else
			local left_roll = - 1140* FubenConfig.FUBEN_BOARDMOVE
			local right_roll = 1140* FubenConfig.FUBEN_BOARDMOVE
			if self.mCurBoardNum == self.mCount then
				self.mLeftLineX = self.mCurBoardMinX + left_roll
				self.mRightLineX = self.mCurBoardMaxX + right_roll
			elseif self.mCurBoardNum == 1 then
				self.mLeftLineX = self.mStartBoardX
				self.mRightLineX = self.mCurBoardMaxX + right_roll 
			else
				self.mLeftLineX = self.mCurBoardMinX + left_roll
				self.mRightLineX = self.mCurBoardMaxX + right_roll
			end
		end
		if self.mRightLineX >= _sceneW then
			self.mRightLineX = _sceneW
		end	
	elseif self.mStartBoardX ~= 0 then
			local _sceneW = FightSystem.mSceneManager.mSceneView:GetSceneWidth()
			local _boradW = (_sceneW - self.mStartBoardX) / self.mCount
			if self.mCount == 1 then
				self.mLeftLineX = self.mStartBoardX 
				self.mRightLineX = self.mStartBoardX + _boradW
			else
				local left_roll = - _boradW* FubenConfig.FUBEN_BOARDMOVE
				local right_roll = _boradW* FubenConfig.FUBEN_BOARDMOVE

				if self.mCurBoardNum == self.mCount then
					right_roll = 0	
				elseif self.mCurBoardNum == 1 then
					left_roll = 0
				end

				self.mLeftLineX = _boradW*(self.mCurBoardNum - 1) + left_roll + self.mStartBoardX
				self.mRightLineX = _boradW*self.mCurBoardNum + right_roll + self.mStartBoardX

			end

			if self.mRightLineX >= _sceneW then
				self.mRightLineX = _sceneW
			end	
	else
		local _sceneW = FightSystem.mSceneManager.mSceneView:GetSceneWidth()
		local right_roll = 0
		local left_roll = 0
		local _boradW = _sceneW/self.mCount
		if self.mCount == 1 then
			right_roll = 0
			left_roll = 0
		else
			right_roll =  _boradW* FubenConfig.FUBEN_BOARDMOVE
			left_roll = -_boradW*FubenConfig.FUBEN_BOARDMOVE
			if self.mCurBoardNum == self.mCount then
				right_roll = 0	
			elseif self.mCurBoardNum == 1 then
				left_roll = 0
			end
		end
		self.mLeftLineX = _boradW*(self.mCurBoardNum - 1) + left_roll 
		self.mRightLineX = _boradW*self.mCurBoardNum + right_roll
	end

	if self.mBoardsData.Board_BGM ~= 0 then
		CommonAnimation.ChangeBGM(self.mBoardsData.Board_BGM)
	end
end

-- 求生模式
function FubenManager:Seeklive()
	if self.mFubenModel == 2 then
		return true
	end
end

function FubenManager:KofKillMonster(_pos,isup)
	if self.mFubenModel == 4 then
		self:AddKOFMonster(_pos,isup)
	end
end

-- 友方阵亡计算3星奖励
function FubenManager:OnRoleFriendDead()
	if globaldata.PvpType == "fuben" then 
		if self.mSanxingCondition[2] then
			self.mFriendDeadCount = self.mFriendDeadCount + 1
		end
		if self.mSanxingCondition[5] then
			self.mSanxingCondition[5][3][2] = 0
		end
	end
end

-- 有人被击杀通知
function FubenManager:OnRoleKilled(_group, _pos, _monsterID)
	if self.mIsFightGuide then
		if _group == "monster" then
			self.mMonsterCount = self.mMonsterCount + 1
			if self.mMonsterCount == 4 then
				self:autoNextBoard()
			elseif self.mMonsterCount == 8 then
				self:Result("success")
			-- elseif self.mMonsterCount == 5 then
			-- 	self:GuideStep8_1()
			-- elseif self.mMonsterCount == 9 then
			-- 	self:GuideStep10()
			-- elseif self.mMonsterCount == 10 then
			-- 	self:Result("success")
			end
		end
		return
	end
	if _group == "friend" then
		-- if #FightSystem.mRoleManager.mFriendRoles == 0 then
		-- 	self:Result("fail")
		-- end
		self:OnRoleFriendDead()
		self.mCurKillFriend = self.mCurKillFriend + 1
		if globaldata.PvpType == "blackMarket" and self.mCurKillFriend == 1 then
			FightSystem.mAISceneIDlist[1] = 2
			FightSystem.mRoleManager:setAllRoleSceneListId(1)
		end
	elseif _group == "monster"  then
		self.mDropController:DropItem(_monsterID,_pos)
		if self.mResult then
			self:ItemAllPickUp()
		end
		self:JisuSuccess()
		self:KofKillMonster(_pos,true)
		self:TickBornConType3(_group, _pos, _monsterID)
		if self.mBoardsData.Board_FinishCondition == 1 then
			self.mCurControllerKill = self.mCurControllerKill + 1 
			if self.mCurControllerKill ==  self.mCurBoardMonster then
				--local function doSomething()
               		 self:autoNextBoard()
            	--end
				--nextTick(doSomething)
			end
		elseif 	self.mBoardsData.Board_FinishCondition == 2 then
			for k,v in pairs(self.mFinishConditionTable) do
				if v == _monsterID then
					table.remove(self.mFinishConditionTable,k)
				end
			end
			if #self.mFinishConditionTable == 0 then
				self:ItemAllPickUp()
				self:Result("success")
				return
			end
		end
		--cclog("一个怪被干掉了====")
	elseif _group == "sceneani" then
		if self.mFubenModel == 7 then
			if self.mFubenModelParameter == _monsterID then
				FightSystem.mRoleManager:removeAllFlyFriend()
				self:Result("fail")
			end
		end
		if self.mSanxingCondition[7] then
			if self.mDeadscenelist[_monsterID] then
				self.mDeadscenelist[_monsterID] = self.mDeadscenelist[_monsterID] + 1
			else
				self.mDeadscenelist[_monsterID] = 1
			end
		end
	elseif _group == "enemyplayer" then
		if globaldata.PvpType == "wealth" then
			self.mCurControllerKill = self.mCurControllerKill + 1 
			if self.mCurControllerKill ==  self.mPlunderPlayerCount then
				self:Result("success")
				return 
			end
		elseif globaldata.PvpType == "blackMarket" then
			self.mCurControllerKill = self.mCurControllerKill + 1 
			if self.mCurControllerKill == 1 then
				FightSystem.mAISceneIDlist[2] = 2
				FightSystem.mRoleManager:setAllRoleSceneListId(2)
			end
			if self.mCurControllerKill ==  self.mPlunderPlayerCount then
				FightSystem.mAISceneIDlist[3] = 2
				FightSystem.mRoleManager:setAllRoleSceneListId(3)
				return 
			end
		elseif globaldata.PvpType == "tower" then
			self.mCurControllerKill = self.mCurControllerKill + 1 
			if self.mCurControllerKill ==  self.mPlunderPlayerCount then
				self:Result("success")
				return 
			end
		end
	end
end

function FubenManager:LoginBackSuccess()
	if GUISystem.Windows["BattleResult_WinWindow"].mRootNode and not globaldata.isFubenBalance then
		self:SendFubenResult("success")
		GUISystem:showLoading()
	end
end

function FubenManager:RegisterLoginBackResult(_result)
	if _result == "success" then
		NetSystem:addGSReLoginFunc("Fubenresult",handler(self,self.LoginBackSuccess))
	end
end

function FubenManager:SendFubenResult(_result)
	globaldata.isFubenBalance = nil
	if globaldata.PvpType == "wealth" then 
		local packet = NetSystem.mNetManager:GetSPacket()
		packet:SetType(PacketTyper._PTYPE_CS_REQUEST_WEALTH_RESULT_)
		local win = 0
		if _result == "fail" then
			win = 1
		else
			globaldata.wait = true
		end
		packet:PushInt(globaldata.fightresultkey)
		packet:PushChar(win)
		packet:PushUShort(globaldata.wealthType)
		packet:PushChar(globaldata.clickedlevel)

		packet:Send()
		self.mSendresult = "send"
	elseif globaldata.PvpType == "blackMarket" then
		local packet = NetSystem.mNetManager:GetSPacket()
		packet:SetType(PacketTyper._PTYPE_CS_BEGIN_ROB_RESULT_REQUEST)
		local win = 0
		if _result == "fail" then
			win = 1
		else
			globaldata.wait = true
		end
		packet:PushInt(globaldata.fightresultkey)
		packet:PushChar(globaldata.mplunderindex)
		packet:PushInt(globaldata.mplundertaskid)
		packet:PushString(globaldata.mplunderPlayerid)
		packet:PushChar(win)
		packet:Send()
		if _result ~= "fail" then
			GUISystem:showLoading()
		end
		self.mSendresult = "send"
	elseif globaldata.PvpType == "tower" then 
		local packet = NetSystem.mNetManager:GetSPacket()
		packet:SetType(PacketTyper._PTYPE_CS_TOWEREX_RESULT_REQUEST)
		local win = 0
		if _result == "fail" then
			win = 1
		else
			globaldata.wait = true
		end
		packet:PushInt(globaldata.fightresultkey)
		packet:PushChar(win)
		packet:Send()
		if _result ~= "fail" then
			GUISystem:showLoading()
		end
		self.mSendresult = "send"
	else
		local packet = NetSystem.mNetManager:GetSPacket()
		packet:SetType(PacketTyper._PTYPE_CS_REQUEST_FUBEN_BALANCE_)
		local win = 0
		if _result == "fail" then
			win = 1
		else
			globaldata.wait = true
		end
		packet:PushInt(globaldata.fightresultkey)
		packet:PushChar(win)
		packet:PushChar(globaldata.mapType)
		packet:PushInt(globaldata.mapId)
		packet:PushInt(globaldata.stageId)
		if globaldata.fubenstar < 1 then
			globaldata.fubenstar = 1
		end
		packet:PushChar(globaldata.fubenstar)
		packet:PushUShort(0)
		packet:Send()
		self.mSendresult = "send"
	end


end

function FubenManager:BackFubenResult()
	local result = self.mResult
	self.mSendresult = "back"
	self.isTick = false
	FightSystem.mTouchPad:setVisible(false)
	if result == "success" then
		GUISystem.Windows["BattleResult_WinWindow"]:ServerBackresult()
	elseif  result == "fail" then
		GUISystem:hideLoading()
	end
end

function FubenManager:SceneRun()
		--进入下一个版本
	if self.misAutoNextBoard then
		if self.mLengthAdd ~= 0 then
			if not FightSystem:GetKeyRole() then return end
			local keyrolepos = FightSystem:GetKeyRole():getShadowPos()
			for k,v in pairs(FightSystem.mRoleManager:GetFriendTable()) do
				if not v.IsKeyRole then
					local leng = cc.pGetDistance(keyrolepos,v:getShadowPos())
					if leng > 140 then
						return false
					end
				end
			end
			local xguide = 0
			if self.mIsFightGuide then
				xguide = 300
			end
			local a = FightSystem:GetKeyRole():getPositionX() - xguide
			local huitui_X = a - (self.mCurBoardMinX - FubenConfig.FUBEN_BOARDMOVE*1140 ) -- (self.mCurBoardNum -2 + (1-FubenConfig.FUBEN_BOARDMOVE)) *_boradW
			--cclog("self.mCurBoardNum===========" .. self.mCurBoardNum)
			if huitui_X > 0 then
				local  mPosTiled = math.abs(FightSystem:GetFightTiledLayer():getPositionX())
				huitui_X = math.abs(self.mCurBoardMinX - FubenConfig.FUBEN_BOARDMOVE*1140 - mPosTiled)
			end

			if huitui_X > 0 then
				self.mIshuitui = true
				self.mHuitui_X = huitui_X
				self.mAspeed_x = 0.5
				self.mSpeedX = 30
				self:UpDateBoardLine()
				self:InformNextBoard()
				self.misAutoNextBoard = false
				self.misTickBornMonster = true
				FightSystem.mRoleManager:SetFriendFollowKeyRole(false)
				if self.mIsFightGuide then
					self:GuideStep7()
				end
				return true
			end	
		else
			local _sceneW = FightSystem.mSceneManager.mSceneView:GetSceneWidth() - self.mStartBoardX
			_boradW = _sceneW/self.mCount
			if not FightSystem:GetKeyRole() then return end
			local keyrolepos = FightSystem:GetKeyRole():getShadowPos()
			for k,v in pairs(FightSystem.mRoleManager:GetFriendTable()) do
				if not v.IsKeyRole then
					local leng = cc.pGetDistance(keyrolepos,v:getShadowPos())
					if leng > 140 then
						return false
					end
				end
			end
			local xguide = 0
			if self.mIsFightGuide then
				xguide = 300
			end
			local a = FightSystem:GetKeyRole():getPositionX() - xguide
			local huitui_X = a - (self.mCurBoardNum -2 + (1-FubenConfig.FUBEN_BOARDMOVE)) *_boradW - self.mStartBoardX
			--cclog("self.mCurBoardNum===========" .. self.mCurBoardNum)
			if huitui_X > 0 then
				local  mPosTiled = math.abs(FightSystem:GetFightTiledLayer():getPositionX())
				huitui_X = math.abs((self.mCurBoardNum -1 - FubenConfig.FUBEN_BOARDMOVE) * _boradW - mPosTiled)
			end
			if huitui_X > 0 then
				self.mIshuitui = true
				self.mHuitui_X = huitui_X
				self.mAspeed_x = 0.5
				self.mSpeedX = 30
				self:UpDateBoardLine()
				self:InformNextBoard()
				self.misAutoNextBoard = false
				self.misTickBornMonster = true
				FightSystem.mRoleManager:SetFriendFollowKeyRole(false)
				if self.mIsFightGuide then
					self:GuideStep7()
				end
				return true
			end	
		end	
	end
	return false
end

--副本跳转下一个版人物操作
function FubenManager:KeyRoleLeftRunScene(role,curpos_X,nextpos_X)
	--[[
	if  role.IsKeyRole then
		if self.mHuitui_X > 0 then
			local value = nextpos_X - curpos_X
			--向左走
			if value < 0  then
				local posleftx = 0
				if self.mHuitui_X > 0 then
					local a = self.mHuitui_X + value
					if a > 0 then
						self.mHuitui_X = a
						posleftx = -value
					else
						posleftx = self.mHuitui_X
						self.mHuitui_X = 0
					end
					FightSystem.mSceneManager.mSceneView:MoveAllLayersLeft(posleftx)
				end	
			end
		end
	end
	]]
end


function FubenManager:GetMixandMaxPosBy()
	local _sceneW = FightSystem.mSceneManager.mSceneView:GetSceneWidth()

	local _boradW = _sceneW/self.mCount

	local Left_margin = _boradW*(self.mCurBoardNum - 1)
	local Right_margin = _boradW*self.mCurBoardNum

	return cc.p(Left_margin,Right_margin)
end

function FubenManager:GetSlowmotion(_role)
	if _role.mGroup == "monster" or _role.mGroup == "enemyplayer" then
		return self:GetLastBoardMonsterCount(_role)
	elseif _role.mGroup == "friend" then
		return self:GetLastFriendCount(_role)
	end
end

function FubenManager:GetLastFriendCount(_role)
	if self.mFubenModel == 2 then
		return 1
	else
		if #FightSystem.mRoleManager.mFriendRoles == 1 and FightSystem.mTouchPad.mSubstitutionCount == 0 then 
			return 1
		end
	end
	return nil
end

function FubenManager:GetLastBoardMonsterCount(_role)
	if self.mBoardsData.Board_FinishCondition == 1 then
		if self.mBoardsData.Board_NextBoardID == 0 then

			return self.mCurBoardMonster - self.mCurControllerKill
		end
	elseif self.mBoardsData.Board_FinishCondition == 2	then
		if #self.mFinishConditionTable == 1 then
			if self.mFinishConditionTable[1] == _role.mRoleData.mMonsterID then
				return 1
			end
		end
	end
	return nil
end

function FubenManager:FubenTime(delta)
	if self.IsShowGuanqia then
		self.mShowPveController:Tick(delta)
		return 
	end
	if self.misAutoNextBoard then
		self.mGoTime = self.mGoTime - delta
		if self.mGoTime <= 0 then
			self.mGoTime = 8
			FightSystem.mTouchPad:ShowgoNext()
		end
	end
	if self.mtick >= 1 then
		self.mtick = self.mtick - 1
		self.mCurTime = self.mCurTime - 1
		FightSystem.mTouchPad:SetTime(self.mCurTime)
		if self.mCurTime <= 0 then
			self:CasttoTime()
		end
	else     	  
		self.mtick = self.mtick + delta	
	end
end

function FubenManager:CasttoTime(CurTime)
	if self.mFubenModel == 2 then
		self:ItemAllPickUp()
		FightSystem.mRoleManager:removeAllFlyEnemy()
		self:Result("success")
	elseif  self.mFubenModel == 7 then
		--[[
		self:ItemAllPickUp()
		FightSystem.mRoleManager:removeAllFlyEnemy()
		FightSystem.mRoleManager:playVictory()
		self:Result("success")
		]]
		FightSystem.mRoleManager:removeAllFlyFriend()
		self:Result("fail")
	else
		FightSystem.mRoleManager:removeAllFlyFriend()
		self:Result("fail")
	end
end

function FubenManager:TickDropItem(delta)
	for k,v in pairs(self.mBaoxiangtable) do
		v.mBornTime = v.mBornTime - delta
		if v.mBornTime <= 0 then
			v:PickItems()
			v:removeFromParent(true)
			self.mBaoxiangtable[k] = nil
		else
			if v:CheckKeyRoleInPickRange() then
				v:removeFromParent(true)
				self.mBaoxiangtable[k] = nil
			end
		end	
	end
end

function FubenManager:ItemAllPickUp()
	for k,v in pairs(self.mBaoxiangtable) do
		v:PickItems()
		v:removeFromParent(true)
		self.mBaoxiangtable[k] = nil
	end
	FightSystem.mRoleManager:AllPickUpJinbi()
end

function FubenManager:PlayCGById(_id,_first,callback,_end)
	if _id ~= 0 and globaldata.clickedlevel == 1 then
		if not FightConfig.__DEBUG_PLAYCG_ then
		 if globaldata:isSectionVisited(globaldata.clickedlevel,globaldata.clickedchapter,globaldata.clickedsection) then
		 	return false
		 end
		end
		--cclog("self.mBoardsData.Board_CGTrigger ===" .. self.mBoardsData.Board_CGTrigger)
		StorySystem.mCGManager:ShowCG(_id,callback,_end)
		if _first then
			StorySystem.mCGManager.misFubenInit = true
		end
		return true
	else
		return false
	end
end

function FubenManager:ShowSchool(type)
	if not type then
		CommonAnimation.BlackScreenForFuben(FightSystem.mSceneManager.mSceneView,3)
	end
	if not self.IsShowGuanqia then
		local res_ID = DB_ResourceList.getDataById(self.mBoardsData.Board_ModelPic)
		CommonAnimation.ScreenMiddlelabelPic(FightSystem.mTouchPad,res_ID.Res_path1,3)
	end
end

-- 查找是否预先加载
function FubenManager:FindPreloadjson(_json)
	return self.mPreloadSpineList[_json]
end

function FubenManager:DetectAutoBtn()
	if FightSystem.mFightType == "fuben" and globaldata.PvpType == "fuben" and not globaldata:isSectionVisited(1,1,8) then
		 FightSystem.mTouchPad.mRootWidget:getChildByName("CheckBox_Auto"):setVisible(false)
	end
end

-- 添加光圈
function FubenManager:AddGuideaperture(node,Id,name)
	self:RemoveGuideaperture()
	self.ChibangNode = AnimManager:createAnimNode(Id)
	node:addChild(self.ChibangNode:getRootNode(), 100)
	self.ChibangNode:getRootNode():setPositionX(node:getContentSize().width/2)
	self.ChibangNode:getRootNode():setPositionY(node:getContentSize().height/2)
	self.ChibangNode:play(name,true)
end

-- 移除指引光圈
function FubenManager:RemoveGuideaperture()
	if self.ChibangNode then
		self.ChibangNode:destroy()
		self.ChibangNode = nil
	end
end

------------------------------------------------------------------------------------------

function FubenManager:Guide1_5Step1()
	if not self.mIsFightGuide_1_5 then return end
	FightSystem.mRoleManager:AllPlayerAiStop(false)
	self.isTick = false
	local panel = FightSystem.mTouchPad.mRD_Node:getChildByName("Panel_Skill_1_Cover")
	panel:setVisible(true)
	panel:getChildByName("Label_LevelOpen"):setVisible(true)
	panel:getChildByName("Label_LevelOpen"):setString("6级开启")
	

	self.girl = GuideSystem:createGuideGirl("点击开启#16ff04职业技能#")
	FightSystem.mTouchPad:addChild(self.girl,201)
	self.girl:setPosition(CanvasToScreen(550, 50))

	local panel = FightSystem.mTouchPad.mRD_Node:getChildByName("Panel_Skill_Jump_Cover")
	panel:setVisible(true)
	local size = panel:getContentSize()
	local pos = panel:getWorldPosition()
	local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
	self.mGuideLayer = GuideSystem:createGuideLayer(touchRect)
	FightSystem.mTouchPad:addChild(self.mGuideLayer,200)

	local function TouchEvent( ... )
		panel:setVisible(false)	
		if self.mGuideLayer then
			self.mGuideLayer:removeFromParent()
			self.mGuideLayer = nil
		end
		self.girl:removeFromParent()
		self:Guide1_5Step2()
	end
	registerWidgetReleaseUpEvent(panel,TouchEvent)
end

function FubenManager:Guide1_5Step2()
	local function CallBack()
		self.duibai:removeFromParent()
		self.duibai = nil
		self.isTick = true
		FightSystem.mRoleManager:AllPlayerAiStopForActivat(true)
	end
	self.duibai = GuideSystem:createGuideCGLayer(109, CallBack)
	FightSystem.mTouchPad:addChild(self.duibai,100)
end


------------------------------------------------------------------------------------------

function FubenManager:Guide1_4Step1()
	if not self.mIsFightGuide_1_4 then return end
	FightSystem.mRoleManager:AllPlayerAiStop(false)
	self.isTick = false
	local panel = FightSystem.mTouchPad.mRD_Node:getChildByName("Panel_Skill_Jump_Cover")
	panel:setVisible(true)
	panel:getChildByName("Label_LevelOpen"):setVisible(true)
	panel:getChildByName("Label_LevelOpen"):setString("5级开启")
	local function CallBack()
		self.duibai:removeFromParent()
		self.duibai = nil
		FightSystem.mRoleManager:AllPlayerAiStop(true)
		self.isTick = true
	end
	self.duibai = GuideSystem:createGuideCGLayer(108, CallBack)
	FightSystem.mTouchPad:addChild(self.duibai,100)

	--[[
	FightSystem.mRoleManager:AllPlayerAiStop(false)
	self.isTick = false
	self.mEnergyBlacklayout1 = ccui.Layout:create()
    self.mEnergyBlacklayout1:setContentSize(cc.size(1140, 770))
 	self.mEnergyBlacklayout1:setAnchorPoint(cc.p(0,0))
    FightSystem.mTouchPad:addChild(self.mEnergyBlacklayout1, 101)
    
    FightSystem.mTouchPad.mMD_Node:getChildByName("Image_TimeBg"):setVisible(false)
	FightSystem.mTouchPad.mMD_Node:setVisible(true)
	self.mMDShowText = GUIWidgetPool:createWidget("Guide_FightWindow")
	FightSystem.mTouchPad.mMD_Node:addChild(self.mMDShowText,100)
	self.mMDShowText:setPositionY(50)
	self.mMDShowText:setVisible(true)
	richTextCreateWithFont(self.mMDShowText:getChildByName("Panel_Text"),getDictionaryCGText(2117) , true,self.mMidTextSize)

    local function Touchlayout( ... )
    	self.mEnergyBlacklayout1:removeFromParent()
    	FightSystem.mRoleManager:AllPlayerAiStop(true)
		self.isTick = true
		self.mMDShowText:removeFromParent()
    end
    self.mEnergyBlacklayout1:setTouchEnabled(true)
    registerWidgetReleaseUpEvent(self.mEnergyBlacklayout1,Touchlayout)
    ]]
end


------------------------------------------------------------------------------------------

function FubenManager:Guide1_2Step1()
	if not self.mIsFightGuide_1_2 then return end

	local panel = FightSystem.mTouchPad.mRD_Node:getChildByName("Panel_Skill_3_Cover")
	panel:setVisible(true)
	panel:getChildByName("Label_LevelOpen"):setVisible(true)
	panel:getChildByName("Label_LevelOpen"):setString("3级开启")


	FightSystem.mRoleManager:AllPlayerAiStop(false)
	self.isTick = false
	self.mEnergyBlacklayout1 = ccui.Layout:create()
    self.mEnergyBlacklayout1:setContentSize(cc.size(1140, 770))
 	self.mEnergyBlacklayout1:setAnchorPoint(cc.p(0,0))
    FightSystem.mTouchPad:addChild(self.mEnergyBlacklayout1, 101)
    local drawNode = cc.Sprite:create("guide_area_black.png")
    drawNode:setAnchorPoint(cc.p(0.5, 0.5))
    drawNode:setScale(4)
    self.mEnergyBlacklayout1:addChild(drawNode,190)
    local deltaPos = FightSystem:getCurrentViewOffset()
    local posx = FightSystem:GetKeyRole():getPosition_pos().x + deltaPos.x
    local posy = FightSystem:GetKeyRole():getPosition_pos().y + deltaPos.y
    local SpineSize = FightSystem:GetKeyRole().mArmature:getSize()
    drawNode:setPosition(posx +getGoldFightPosition_LD().x, posy + SpineSize.height/2)
    local function Touchlayout( ... )
    	self.mEnergyBlacklayout1:removeFromParent()
    	self:Guide1_2Step2()
    end
    self.mEnergyBlacklayout1:setTouchEnabled(true)
    registerWidgetReleaseUpEvent(self.mEnergyBlacklayout1,Touchlayout)

    local girl = GuideSystem:createGuideGirl("病毒陷阱关卡中，学员深陷不良气体，#16ff04血量#会#16ff04持续下降#")
	self.mEnergyBlacklayout1:addChild(girl,200)
	girl:setPosition(cc.p(400, 200))
end

function FubenManager:Guide1_2Step2()
	if not self.mIsFightGuide_1_2 then return end
	self.mEnergyBlacklayout1 = ccui.Layout:create()
    self.mEnergyBlacklayout1:setContentSize(cc.size(1140, 770))
 	self.mEnergyBlacklayout1:setAnchorPoint(cc.p(0,0))
    FightSystem.mTouchPad:addChild(self.mEnergyBlacklayout1, 101)
    local drawNode = cc.Sprite:create("guide_area_black.png")
    drawNode:setAnchorPoint(cc.p(0.5, 0.5))
    drawNode:setScale(4)
    self.mEnergyBlacklayout1:addChild(drawNode,190)

    local panel = FightSystem.mTouchPad.mLU_Node:getChildByName("Panel_Hero_1")
	local size = panel:getContentSize()
	local pos = panel:getWorldPosition()
    drawNode:setPosition(cc.p(pos.x + size.width/2, pos.y + size.height/2)) 

    local function Touchlayout( ... )
    	self.mEnergyBlacklayout1:removeFromParent()
    	self.isTick = true
    	FightSystem.mRoleManager:AllPlayerAiStop(true)

    end
    self.mEnergyBlacklayout1:setTouchEnabled(true)
    registerWidgetReleaseUpEvent(self.mEnergyBlacklayout1,Touchlayout)

    local girl = GuideSystem:createGuideGirl("通过学员头像查看当前血量，注意#16ff04躲避#敌人攻击，及时通关")
	self.mEnergyBlacklayout1:addChild(girl,200)
	girl:setPosition(cc.p(200, 450))
end

------------------------------------------------------------------------------------------
-- 战斗1——6战斗指引
function FubenManager:Guide1_6Step1()
	if not self.mIsFightGuide_1_6 then return end
	if 5 == FightSystem:GetKeyRole().mRoleData.mInfoDB.ID then
		-- 男
		self.TalkSetp1 = 110
		self.TalkSetp4 = 111
		self.TalkSetp6 = 112
	else
		self.TalkSetp1 = 110
		self.TalkSetp4 = 111
		self.TalkSetp6 = 113
	end

	FightSystem.mRoleManager:AllPlayerAiStop(false)
	self.isTick = false
	local function CallBack()
		self.duibai:removeFromParent()
		self.duibai = nil
		self:Guide1_6Step2()
	end
	self.duibai = GuideSystem:createGuideCGLayer(self.TalkSetp1, CallBack)
	FightSystem.mTouchPad:addChild(self.duibai,100)
end

function FubenManager:Guide1_6Step2()
	if not self.mIsFightGuide_1_6 then return end
	self.mEnergyBlacklayout1 = ccui.Layout:create()
    self.mEnergyBlacklayout1:setContentSize(cc.size(1140, 770))
 	self.mEnergyBlacklayout1:setAnchorPoint(cc.p(0,0))
    FightSystem.mTouchPad:addChild(self.mEnergyBlacklayout1, 101)


    local drawNode = cc.Sprite:create("guide_area_black.png")
    drawNode:setAnchorPoint(cc.p(0.5, 0.5))
    drawNode:setScale(4)
    self.mEnergyBlacklayout1:addChild(drawNode,300)
    local deltaPos = FightSystem:getCurrentViewOffset()
    local posx = self.mProtectScene:getPosition_pos().x + deltaPos.x
    local posy = self.mProtectScene:getPosition_pos().y + deltaPos.y
    drawNode:setPosition(posx+getGoldFightPosition_LD().x, posy + 100)

    local function Touchlayout( ... )
    	self.mEnergyBlacklayout1:removeFromParent()
    	self.girl:removeFromParent()
    	self:Guide1_6Step3()
    end
    self.mEnergyBlacklayout1:setTouchEnabled(true)
    registerWidgetReleaseUpEvent(self.mEnergyBlacklayout1,Touchlayout)

    self.girl = GuideSystem:createGuideGirl("#16ff04守护目标#的头顶有特殊提示")
	FightSystem.mTouchPad:addChild(self.girl,200)
	self.girl:setPosition(cc.p(350, 70))
end

function FubenManager:Guide1_6Step3()
	if not self.mIsFightGuide_1_6 then return end
	self.mEnergyBlacklayout1 = ccui.Layout:create()
	self.mEnergyBlacklayout1:setBackGroundColor(G_COLOR_C3B.BLACK)
    self.mEnergyBlacklayout1:setContentSize(cc.size(1140, 770))
 	self.mEnergyBlacklayout1:setOpacity(125)
 	self.mEnergyBlacklayout1:setAnchorPoint(cc.p(0,0))
 	self.mEnergyBlacklayout1:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
    FightSystem.mTouchPad:addChild(self.mEnergyBlacklayout1, 101)
    self.mEnergy = cc.Sprite:create("guide_fight_flagblood_bg.png")
    FightSystem.mTouchPad:addChild(self.mEnergy,150)
    self.mEnergy:setAnchorPoint(cc.p(0,0))
    local Pos1 = cc.p(FightSystem.mTouchPad.mRootWidget:getChildByName("Panel_FlagKeeping"):getWorldPosition())
    local size = FightSystem.mTouchPad.mRootWidget:getChildByName("Panel_FlagKeeping"):getContentSize()
    self.mEnergy:setPosition(Pos1)
    local function Touchlayout( ... )
    	self.mEnergyBlacklayout1:removeFromParent()
    	self.mEnergy:removeFromParent()
    	self.girl:removeFromParent()
    	self:Guide1_6Step4()
    end
    self.mEnergyBlacklayout1:setTouchEnabled(true)
    registerWidgetReleaseUpEvent(self.mEnergyBlacklayout1,Touchlayout)


    self.girl = GuideSystem:createGuideGirl("战斗过程中请时刻关注#16ff04守护目标#的#16ff04血量#")
	FightSystem.mTouchPad:addChild(self.girl,200)
	self.girl:setPosition(cc.p(200, 480))
end

function FubenManager:Guide1_6Step4()
	if not self.mIsFightGuide_1_6 then return end
	local function CallBack()
		self.duibai:removeFromParent()
		self.duibai = nil
		self:Guide1_6Step5()
	end
	self.duibai = GuideSystem:createGuideCGLayer(self.TalkSetp4, CallBack)
	FightSystem.mTouchPad:addChild(self.duibai,100)
end

function FubenManager:Guide1_6Step5()
	if not self.mIsFightGuide_1_6 then return end
	local panel = FightSystem.mTouchPad.mRD_Node:getChildByName("Panel_Skill_1_Cover")
	panel:setVisible(true)
	local size = panel:getContentSize()
	local pos = panel:getWorldPosition()
	local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
	self.mGuideLayer = GuideSystem:createGuideLayer(touchRect)
	FightSystem.mTouchPad:addChild(self.mGuideLayer,200)

	self.girl = GuideSystem:createGuideGirl("点击开启#16ff04必杀技能#")
	FightSystem.mTouchPad:addChild(self.girl,200)
	self.girl:setPosition(cc.p(450, 150))

	local function TouchEvent( ... )
		panel:setVisible(false)	
		if self.mGuideLayer then
			self.mGuideLayer:removeFromParent()
			self.mGuideLayer = nil
		end
		self.girl:removeFromParent()
		self:Guide1_6Step6()
	end
	registerWidgetReleaseUpEvent(panel,TouchEvent)
end

function FubenManager:Guide1_6Step6()
	if not self.mIsFightGuide_1_6 then return end
	local function CallBack()
		self.duibai:removeFromParent()
		self.duibai = nil
		self:Guide1_6Step7()
	end
	self.duibai = GuideSystem:createGuideCGLayer(self.TalkSetp6, CallBack)
	FightSystem.mTouchPad:addChild(self.duibai,100)
end

function FubenManager:Guide1_6Step7()
	if not self.mIsFightGuide_1_6 then return end
	self.mEnergyBlacklayout1 = ccui.Layout:create()
	self.mEnergyBlacklayout1:setBackGroundColor(G_COLOR_C3B.BLACK)
    self.mEnergyBlacklayout1:setContentSize(cc.size(1140, 770))
 	self.mEnergyBlacklayout1:setOpacity(125)
 	self.mEnergyBlacklayout1:setAnchorPoint(cc.p(0,0))
 	self.mEnergyBlacklayout1:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
    FightSystem.mTouchPad:addChild(self.mEnergyBlacklayout1, 101)
    self.mEnergy = cc.Sprite:create("guide_fight_hero_energy.png")
    FightSystem.mTouchPad:addChild(self.mEnergy,150)
    self.mEnergy:setPosition(cc.p(FightSystem.mTouchPad.mHeadBtnList[1].mProgressBar_HeroEnergy:getWorldPosition()))

    self.girl = GuideSystem:createGuideGirl("学员头像下方的#16ff04黄色进度条#代表#16ff04当前能量状况#")
	FightSystem.mTouchPad:addChild(self.girl,200)
	self.girl:setPosition(cc.p(250, 480))

    local function Touchlayout( ... )
    	self.mEnergyBlacklayout1:removeFromParent()
    	self.mEnergy:removeFromParent()
    	self.girl:removeFromParent()
    	self.girl = nil
	    FightSystem.mRoleManager:AllPlayerAiStop(true)
		self.isTick = true
    end
    self.mEnergyBlacklayout1:setTouchEnabled(true)
    registerWidgetReleaseUpEvent(self.mEnergyBlacklayout1,Touchlayout)
end

------------------------------------------------------------------------------------------



-- 战斗1——8战斗指引
function FubenManager:Guide1_8Step1()
	if not self.mIsFightGuide_1_8 then return end
	if #FightSystem.mRoleManager:GetFriendTable() < 2 then
		self.mSelectCount = nil
		self.mIsFightGuide_1_8 = false
		return
	end
	self.isTick = false
	local panel = FightSystem.mTouchPad.mLU_Node:getChildByName("Panel_Hero_2")
	local size = panel:getContentSize()
	local pos = panel:getWorldPosition()
	local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
	self.mGuideLayer = GuideSystem:createGuideLayer(touchRect)
	FightSystem.mTouchPad:addChild(self.mGuideLayer,200)
	self.girl = GuideSystem:createGuideGirl("#16ff04点击头像#可以#16ff04切换#当前正在控制的学员")
	self.mGuideLayer:addChild(self.girl)
	self.girl:setPosition(cc.p(180, 350))

end

function FubenManager:Guide1_8Step2()
	if not self.mIsFightGuide_1_8 then return end
	if self.mGuideLayer then
		self.girl:removeFromParent()
		self.girl = nil
		self.mGuideLayer:removeFromParent()
		self.mGuideLayer = nil
	end
	self.isTick = true
end


--[[
-- 战斗1——8战斗指引
function FubenManager:Guide1_8Step1()
	if not self.mIsFightGuide_1_8 then return end
	self.isTick = false
	local panel = FightSystem.mTouchPad.mRootWidget:getChildByName("CheckBox_Auto")
	local size = panel:getContentSize()
	local pos = panel:getWorldPosition()
	pos.x = pos.x - size.width/2
	pos.y = pos.y - size.height/2
	local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
	self.mGuideLayer = GuideSystem:createGuideLayerForcircle(touchRect)
	local girl = GuideSystem:createGuideGirl("使用#16ff04自动战斗#，更轻松的游戏体验")
	self.mGuideLayer:addChild(girl)
	girl:setPosition(cc.p(200, 300))
	FightSystem.mTouchPad:addChild(self.mGuideLayer,200)
end

function FubenManager:Guide1_8Step2()
	if not self.mIsFightGuide_1_8 then return end
	self.isTick = true
	if self.mGuideLayer then
		self.mGuideLayer:removeFromParent()
		self.mGuideLayer = nil
	end
end
]]
---------------------------------------------------------------------------------------------------
-- 战斗1——3战斗指引
function FubenManager:Guide1_3Step1()
	if not self.mIsFightGuide_1_3 then return end

	if 5 == FightSystem:GetKeyRole().mRoleData.mInfoDB.ID then
		-- 男
		self.TalkSetp2 = 106
	else
		self.TalkSetp2 = 107
	end

	self.girl = GuideSystem:createGuideGirl("点击开启#16ff04新技能#")
	FightSystem.mTouchPad:addChild(self.girl,201)
	self.girl:setPosition(CanvasToScreen(600, 150))

	local panel = FightSystem.mTouchPad.mRD_Node:getChildByName("Panel_Skill_3_Cover")
	panel:setVisible(true)
	local size = panel:getContentSize()
	local pos = panel:getWorldPosition()
	local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
	self.mGuideLayer = GuideSystem:createGuideLayer(touchRect)
	FightSystem.mTouchPad:addChild(self.mGuideLayer,200)

	local function TouchEvent( ... )
		panel:setVisible(false)	
		if self.mGuideLayer then
			self.mGuideLayer:removeFromParent()
			self.mGuideLayer = nil
		end
		self.girl:removeFromParent()
		self:Guide1_3Step2()
	end
	registerWidgetReleaseUpEvent(panel,TouchEvent)



	--[[
	if #FightSystem.mRoleManager:GetFriendTable() < 2 then
		self.mSelectCount = nil
		self.mIsFightGuide_1_3 = false
		return
	end
	self.isTick = false
	if 5 == FightSystem:GetKeyRole().mRoleData.mInfoDB.ID then
		-- 男
		self.TalkSetp1 = 108
	else
		self.TalkSetp1 = 109
	end
	self.TextSetp2 = 2109
	self.TalkSetp3 = 110
	self.TextSetp4 = 2110
	self.TextSetp5 = 2111
	self.TalkSetp6 = 111

	local function CallBack()
		self.duibai:removeFromParent()
		self.duibai = nil
		self:Guide1_3Step2()
	end
	self.mMDShowText = GUIWidgetPool:createWidget("Guide_FightWindow")
	FightSystem.mTouchPad.mMD_Node:getWorldPosition()
	FightSystem.mTouchPad:addChild(self.mMDShowText,210)
	self.mMDShowText:setPosition(cc.p(FightSystem.mTouchPad.mMD_Node:getWorldPosition()))
	self.mMDShowText:setPositionY(self.mMDShowText:getPositionY()+50)
	self.mMDShowText:setVisible(false)
	self:RemoveGuideaperture()
	self.duibai = GuideSystem:createGuideCGLayer(self.TalkSetp1, CallBack)
	FightSystem.mTouchPad:addChild(self.duibai,200)
	]]

end

function FubenManager:Guide1_3Step2()
	if not self.mIsFightGuide_1_3 then return end

	local function CallBack()
		self.duibai:removeFromParent()
		self.duibai = nil
		self.isTick = true
		FightSystem.mRoleManager:AllPlayerAiStopForActivat(true)
	end
	self.duibai = GuideSystem:createGuideCGLayer(self.TalkSetp2, CallBack)
	FightSystem.mTouchPad:addChild(self.duibai,100)
	--[[
	local panel = FightSystem.mTouchPad.mLU_Node:getChildByName("Panel_Hero_2")
	local size = panel:getContentSize()
	local pos = panel:getWorldPosition()
	local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
	self.mGuideLayer = GuideSystem:createGuideLayer(touchRect)
	FightSystem.mTouchPad:addChild(self.mGuideLayer,200)
	self.mMDShowText:setVisible(true)
	richTextCreateWithFont(self.mMDShowText:getChildByName("Panel_Text"),getDictionaryCGText(self.TextSetp2) , true,self.mMidTextSize)
	]]
end

--[[
function FubenManager:Guide1_3Step3()
	if not self.mIsFightGuide_1_3 then return end
	if self.mGuideLayer then
		self.mGuideLayer:removeFromParent()
		self.mGuideLayer = nil
	end
	local function CallBack()
		self.duibai:removeFromParent()
		self.duibai = nil
		self:Guide1_3Step4()
	end
	self:RemoveGuideaperture()
	self.mMDShowText:setVisible(false)
	self.duibai = GuideSystem:createGuideCGLayer(self.TalkSetp2, CallBack)
	FightSystem.mTouchPad:addChild(self.duibai,100)
end

function FubenManager:Guide1_3Step4()
	if not self.mIsFightGuide_1_3 then return end
	self:AddGuideaperture(FightSystem.mTouchPad.mRD_Node:getChildByName("Button_Skill_1"),8049)
	self.mMDShowText:setVisible(true)
	richTextCreateWithFont(self.mMDShowText:getChildByName("Panel_Text"),getDictionaryCGText(self.TextSetp4) , true,self.mMidTextSize)
	self.mSkilllayout = ccui.Layout:create()
    self.mSkilllayout:setContentSize(cc.size(1140, 770))
 	self.mSkilllayout:setOpacity(0)
 	self.mSkilllayout:setAnchorPoint(cc.p(0,0))
    FightSystem.mTouchPad:addChild(self.mSkilllayout, 100)
    local function Touchlayout( ... )
    	self.mSkilllayout:removeFromParent()
    	self:RemoveGuideaperture()
    	self:Guide1_3Step5()
    end
    self.mSkilllayout:setTouchEnabled(true)
    registerWidgetReleaseUpEvent(self.mSkilllayout,Touchlayout)
end

function FubenManager:Guide1_3Step5()
	if not self.mIsFightGuide_1_3 then return end
	self.mMDShowText:setVisible(true)
	richTextCreateWithFont(self.mMDShowText:getChildByName("Panel_Text"),getDictionaryCGText(self.TextSetp5) , true,self.mMidTextSize)
	self.mEnergyBlacklayout1 = ccui.Layout:create()
	self.mEnergyBlacklayout1:setBackGroundColor(G_COLOR_C3B.BLACK)
    self.mEnergyBlacklayout1:setContentSize(cc.size(1140, 770))
 	self.mEnergyBlacklayout1:setOpacity(125)
 	self.mEnergyBlacklayout1:setAnchorPoint(cc.p(0,0))
 	self.mEnergyBlacklayout1:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
    FightSystem.mTouchPad:addChild(self.mEnergyBlacklayout1, 101)
    self.mEnergy = cc.Sprite:create("guide_fight_hero_energy.png")
    FightSystem.mTouchPad:addChild(self.mEnergy,150)
    self.mEnergy:setPosition(cc.p(FightSystem.mTouchPad.mHeadBtnList[2].mProgressBar_HeroEnergy:getWorldPosition()))
    local function Touchlayout( ... )
    	self:RemoveGuideaperture()
    	self:Guide1_3Step6()
    	self.mEnergyBlacklayout1:removeFromParent()
    	self.mEnergy:removeFromParent()
    end
    self.mEnergyBlacklayout1:setTouchEnabled(true)
    registerWidgetReleaseUpEvent(self.mEnergyBlacklayout1,Touchlayout)
end

function FubenManager:Guide1_3Step6()
	if not self.mIsFightGuide_1_3 then return end
	self.mMDShowText:setVisible(false)
	local function CallBack()
		self.duibai:removeFromParent()
		self.duibai = nil
		self.isTick = true
		FightSystem.mRoleManager:AllPlayerAiStopForActivat(true)
	end
	self.duibai = GuideSystem:createGuideCGLayer(self.TalkSetp6, CallBack)
	FightSystem.mTouchPad:addChild(self.duibai,100)
end
]]
----------------------------------------------------------------------------------------------

function FubenManager:Guide2_1Step1()
	if not self.mIsFightGuide_2_1 then return end
	self.isTick = false
	local panel = FightSystem.mTouchPad.mRootWidget:getChildByName("CheckBox_Auto")
	local size = panel:getContentSize()
	local pos = panel:getWorldPosition()
	pos.x = pos.x - size.width/2
	pos.y = pos.y - size.height/2
	local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
	self.mGuideLayer = GuideSystem:createGuideLayerForcircle(touchRect)
	FightSystem.mTouchPad:addChild(self.mGuideLayer,200)
	self.girl = GuideSystem:createGuideGirl("点击可开启#16ff04自动战斗#")
	self.mGuideLayer:addChild(self.girl)
	self.girl:setPosition(cc.p(180, 230))

end

function FubenManager:Guide2_1Step2()
	if not self.mIsFightGuide_2_1 then return end
	self.isTick = true
	if self.mGuideLayer then
		self.girl:removeFromParent()
		self.girl = nil
		self.mGuideLayer:removeFromParent()
		self.mGuideLayer = nil
	end
end


----------------------------------------------------------------------------------------------
-- 战斗新手指引 第一步显示控制
function FubenManager:GuideStep1()
	if not self.mIsFightGuide then return end
	if 5 == FightSystem:GetKeyRole().mRoleData.mInfoDB.ID then
		-- 男
		self.TalkSetp5 = 101
		self.TalkSetp9 = 104
		self.TextSetp10 = 2004
	else
		self.TalkSetp5 = 102
		self.TalkSetp9 = 105
		self.TextSetp10 = 2005
	end
	self.TextSetp2 = 2001
	self.TextSetp4 = 2002
	self.TextSetp6 = 2003
	self.TalkSetp3 = 100
	self.TalkSetp7 = 103

	--  第一批小怪X
	self.MonsterFristX = 1400
	self.MonsterSecondX = 1700
	self.MonsterThirdX = 2000
	self.MonsterFourthX = 2200
	self.BossX = 3200
	FightSystem.mTouchPad.mRootWidget:getChildByName("CheckBox_Auto"):setVisible(false)
	FightSystem.mTouchPad.mRootWidget:getChildByName("CheckBox_Weapon"):setVisible(false)
	FightSystem.mTouchPad.mRD_Node:getChildByName("Button_Attack"):setVisible(false)
	FightSystem.mTouchPad.mRD_Node:getChildByName("Button_Jump"):setVisible(false)
	FightSystem.mTouchPad.mRD_Node:getChildByName("Button_Skill_1"):setVisible(false)
	FightSystem.mTouchPad.mRD_Node:getChildByName("Button_Skill_2"):setVisible(false)
	FightSystem.mTouchPad.mRD_Node:getChildByName("Button_Skill_3"):setVisible(false)
	FightSystem.mTouchPad.mRD_Node:getChildByName("Button_Skill_4"):setVisible(false)
	FightSystem.mTouchPad.mRD_Node:getChildByName("Image_Fight_Skill_BG1"):setVisible(false)
	FightSystem.mTouchPad.mRD_Node:getChildByName("Image_Fight_Skill_BG2"):setVisible(false)
	FightSystem.mTouchPad.mRD_Node:getChildByName("Image_Fight_Skill_BG3"):setVisible(false)
	FightSystem.mTouchPad.mRD_Node:getChildByName("Image_Fight_Skill_BG4"):setVisible(false)
	FightSystem.mTouchPad.mRD_Node:getChildByName("Image_Fight_Skill_BG5"):setVisible(false)
	FightSystem.mTouchPad.mLU_Node:getChildByName("Button_Timeout"):setVisible(false)

	FightSystem.mTouchPad.mMD_Node:getChildByName("Image_TimeBg"):setVisible(false)
	FightSystem.mTouchPad.mMD_Node:setVisible(true)
	self.mMDShowText = GUIWidgetPool:createWidget("Guide_FightWindow")
	FightSystem.mTouchPad.mMD_Node:addChild(self.mMDShowText,100)
	self.mMDShowText:setPositionY(50)
	self.mMDShowText:setVisible(false)
	local function closeChoose()
		self.mMoveControl:removeFromParent()
		if self.mChooseIndex == 2 then
			FightSystem:enableAdvancedJoystick(false)
			FightSystem.mTouchPad:InitLeftPad_FIX()
		else
			FightSystem:enableAdvancedJoystick(true)
			FightSystem.mTouchPad:InitLeftPad_MOVE()
		end
		self:GuideStep2()
	end
	self.mChooseIndex = 1
	self.mMoveControl = GUIWidgetPool:createWidget("Guide_MoveTeaching")
	FightSystem.mTouchPad:addChild(self.mMoveControl,200)
	self.mMoveControl:getChildByName("Panel_Left"):getChildByName("Image_Bg"):loadTexture("guide_moveteaching_bg2.png")

	
	
	local Anim1 = AnimManager:createAnimNode(8056)
	self.mMoveControl:getChildByName("Panel_Left"):getChildByName("Panel_Animation"):addChild(Anim1:getRootNode(), 100)
	Anim1:play("guide_fightmove",true)
	self.mMoveControl:getChildByName("Panel_Left"):getChildByName("Panel_Animation"):setVisible(true)
	local Anim2 = AnimManager:createAnimNode(8056)
	self.mMoveControl:getChildByName("Panel_Right"):getChildByName("Panel_Animation"):addChild(Anim2:getRootNode(), 100)
	Anim2 :play("guide_fightmove",true)
	self.mMoveControl:getChildByName("Panel_Right"):getChildByName("Panel_Animation"):setVisible(false)
	local function ChooseLeft()
		if self.mChooseIndex == 1 then return end
		self.mChooseIndex = 1
		self.mMoveControl:getChildByName("Panel_Left"):getChildByName("Image_Bg"):loadTexture("guide_moveteaching_bg2.png")
		self.mMoveControl:getChildByName("Panel_Right"):getChildByName("Image_Bg"):loadTexture("guide_moveteaching_bg1.png")
		self.mMoveControl:getChildByName("Panel_Left"):getChildByName("Panel_Animation"):setVisible(true)
		self.mMoveControl:getChildByName("Panel_Right"):getChildByName("Panel_Animation"):setVisible(false)
	end

	local function ChooseRight()
		if self.mChooseIndex == 2 then return end
		self.mChooseIndex = 2
		self.mMoveControl:getChildByName("Panel_Right"):getChildByName("Image_Bg"):loadTexture("guide_moveteaching_bg2.png")
		self.mMoveControl:getChildByName("Panel_Left"):getChildByName("Image_Bg"):loadTexture("guide_moveteaching_bg1.png")
		self.mMoveControl:getChildByName("Panel_Left"):getChildByName("Panel_Animation"):setVisible(false)
		self.mMoveControl:getChildByName("Panel_Right"):getChildByName("Panel_Animation"):setVisible(true)
	end
	registerWidgetReleaseUpEvent(self.mMoveControl:getChildByName("Button_OK"),closeChoose)
	registerWidgetReleaseUpEvent(self.mMoveControl:getChildByName("Panel_Left"),ChooseLeft)
	registerWidgetReleaseUpEvent(self.mMoveControl:getChildByName("Panel_Right"),ChooseRight)
end

-- 战斗新手指引 第二步拖动控制
function FubenManager:GuideStep2()

	self.mMDShowText:setVisible(true)

	richTextCreateWithFont(self.mMDShowText:getChildByName("Panel_Text"),getDictionaryCGText(self.TextSetp2) , true,self.mMidTextSize)

	self:AddGuideaperture(FightSystem.mTouchPad.mWidgetPadMovenode,8024,"guide_hand_slide_right")
	local role = FightSystem:GetKeyRole()
	self.Step2Pos = role:getPosition_pos()
	self.IsExamineDis = true
end


-- 对白并且出光圈
function FubenManager:GuideStep3()
	local function CallBack()
		self.duibai:removeFromParent()
		self.duibai = nil
		FightSystem.mTouchPad:setCancelledTouchMove(false)
	end
	self:RemoveGuideaperture()
	self.mMDShowText:setVisible(false)
	self.duibai = GuideSystem:createGuideCGLayer(self.TalkSetp3, CallBack)
	FightSystem.mTouchPad:addChild(self.duibai,100)
	self:GuideStep4()
end

-- 战斗新手指引4 走到目标建筑
function FubenManager:GuideStep4()
	if self.mIsFightGuide then
		local scene = FightSystem.mRoleManager:LoadSceneAnimation(17,cc.p(700,200))
		scene:setFindGuideRole()

		self.mMDShowText:setVisible(true)
		richTextCreateWithFont(self.mMDShowText:getChildByName("Panel_Text"),getDictionaryCGText(self.TextSetp4) , true,self.mMidTextSize)
	end
end

-- 战斗新手指引5 放闪
function FubenManager:GuideStep5()
	if self.mIsFightGuide then
		local function CallBack()
			self.duibai:removeFromParent()
			self.duibai = nil
			FightSystem.mTouchPad:setCancelledTouchMove(false)
			self:GuideStep6()
		end
		self:RemoveGuideaperture()
		self.mMDShowText:setVisible(false)
		self.duibai = GuideSystem:createGuideCGLayer(self.TalkSetp5, CallBack)
		FightSystem.mTouchPad:addChild(self.duibai,100)
		FightSystem.mTouchPad:setCancelledTouchMove(true)
	end
	
	--[[
	if self.mIsFightGuide then
		FightSystem.mTouchPad.mRD_Node:getChildByName("Button_Jump"):setVisible(true)
		self:AddGuideaperture(FightSystem.mTouchPad.mRD_Node:getChildByName("Button_Jump"),8049)
		self.mMDShowText:setVisible(true)

		richTextCreateWithFont(self.mMDShowText:getChildByName("Panel_Text"),getDictionaryCGText(self.TextSetp5) , true,self.mMidTextSize)
	end
	]]
end

-- 战斗新手指引6 过第二个版
function FubenManager:GuideStep6()
	if self.mIsFightGuide then
		self.mMDShowText:setVisible(true)
		richTextCreateWithFont(self.mMDShowText:getChildByName("Panel_Text"),getDictionaryCGText(self.TextSetp6) , true,self.mMidTextSize)

		local role1 = FightSystem.mRoleManager:LoadMonster(1101,cc.p(850,280))
		local role2 = FightSystem.mRoleManager:LoadMonster(1101,cc.p(900,270))
		local role3 = FightSystem.mRoleManager:LoadMonster(1101,cc.p(930,250))
		local role4 = FightSystem.mRoleManager:LoadMonster(1101,cc.p(860,200))
		role1.mAI:setOpenAI(false)
		role1.mAI.mActionOpen = false
		role2.mAI:setOpenAI(false)
		role2.mAI.mActionOpen = false
		role3.mAI:setOpenAI(false)
		role3.mAI.mActionOpen = false
		role4.mAI:setOpenAI(false)
		role4.mAI.mActionOpen = false

		local keyrole = FightSystem:GetKeyRole()
		if keyrole.mFSM:IsAttacking() then
			keyrole.mSkillCon:FinishCurSkill()
			keyrole.mFSM:ForceChangeToState("idle")
		end
		FightSystem.mTouchPad.mRD_Node:getChildByName("Button_Attack"):setVisible(true)

	end
	--[[
	if self.mIsFightGuide then
		self.IsGuideStep6_1 = true
		self:RemoveGuideaperture()
		self.mMDShowText:setVisible(false)
		self:autoNextBoard()
	end
	]]
end

function FubenManager:GuideStep6_1()
	if self.mIsFightGuide then
		self.mMDShowText:setVisible(true)
		richTextCreateWithFont(self.mMDShowText:getChildByName("Panel_Text"),getDictionaryCGText(self.TextSetp6) , true,self.mMidTextSize)
		FightSystem.mTouchPad.mRD_Node:getChildByName("Button_Attack"):setVisible(true)
		self:AddGuideaperture(FightSystem.mTouchPad.mRD_Node:getChildByName("Button_Attack"),8049)
		local role = FightSystem.mRoleManager:LoadMonster(1101,cc.p(self.MonsterFristX,200))
		role.mAI:setOpenAI(false)
		role.mAI.mActionOpen = false
	end
end

-- 战斗新手指引7 过第二个版
function FubenManager:GuideStep7()
	if self.mIsFightGuide then
		local function CallBack()
			self.duibai:removeFromParent()
			self.duibai = nil
			FightSystem.mTouchPad:setCancelledTouchMove(false)
			self:GuideStep8()
		end
		self:RemoveGuideaperture()
		self.mMDShowText:setVisible(false)
		self.duibai = GuideSystem:createGuideCGLayer(self.TalkSetp7, CallBack)
		FightSystem.mTouchPad:addChild(self.duibai,200)
		FightSystem.mTouchPad:setCancelledTouchMove(true)
	end
	--[[
	if self.mIsFightGuide then
		local function CallBack()
			self.mMDShowText:setVisible(true)
			richTextCreateWithFont(self.mMDShowText:getChildByName("Panel_Text"),getDictionaryCGText(self.TextSetp7) , true,self.mMidTextSize)
			self.duibai:removeFromParent()
			self.duibai = nil
			FightSystem.mTouchPad.mRD_Node:getChildByName("Button_Skill_2"):setVisible(true)
			self:AddGuideaperture(FightSystem.mTouchPad.mRD_Node:getChildByName("Button_Skill_2"),8049)
			FightSystem.mTouchPad:setCancelledTouchMove(false)
		end
		self:RemoveGuideaperture()

		self.mMDShowText:setVisible(false)
		self.duibai = GuideSystem:createGuideCGLayer(self.TalkSetp7, CallBack)
		FightSystem.mTouchPad:addChild(self.duibai,200)
		local role = FightSystem.mRoleManager:LoadMonster(1101,cc.p(self.MonsterSecondX,250))
		role.mAI:setOpenAI(false)
		role.mAI.mActionOpen = false
		local role1 = FightSystem.mRoleManager:LoadMonster(1101,cc.p(self.MonsterSecondX,150))
		role1.mAI:setOpenAI(false)
		role1.mAI.mActionOpen = false

		local keyrole = FightSystem:GetKeyRole()
		if keyrole.mFSM:IsAttacking() then
			keyrole.mSkillCon:FinishCurSkill()
			keyrole.mFSM:ForceChangeToState("idle")
		end
		FightSystem.mTouchPad:setCancelledTouchMove(true)
	end
	]]
end

-- 战斗新手指引8 过第二个版
function FubenManager:GuideStep8()
	if self.mIsFightGuide then

		self.girl = GuideSystem:createGuideGirl("点击开启#16ff04新技能#")
		FightSystem.mTouchPad:addChild(self.girl,201)
		self.girl:setPosition(CanvasToScreen(400, 70))
	

		FightSystem.mTouchPad.mRD_Node:getChildByName("Button_Skill_2"):setVisible(true)
		FightSystem.mTouchPad.mRD_Node:getChildByName("Image_Fight_Skill_BG2"):setVisible(true)

		local panel = FightSystem.mTouchPad.mRD_Node:getChildByName("Panel_Skill_2_Cover")
		panel:setVisible(true)
		local size = panel:getContentSize()
		local pos = panel:getWorldPosition()
		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		self.mGuideLayer = GuideSystem:createGuideLayer(touchRect)
		FightSystem.mTouchPad:addChild(self.mGuideLayer,200)

		local function TouchEvent( ... )
			panel:setVisible(false)	
			if self.mGuideLayer then
				self.mGuideLayer:removeFromParent()
				self.mGuideLayer = nil
			end
			self.girl:removeFromParent()
			self:GuideStep9()
		end
		registerWidgetReleaseUpEvent(panel,TouchEvent)
	end
	--[[
	if self.mIsFightGuide then
		local function CallBack()
			self.mMDShowText:setVisible(true)

			richTextCreateWithFont(self.mMDShowText:getChildByName("Panel_Text"),getDictionaryCGText(self.TextSetp8) , true,self.mMidTextSize)
			self.duibai:removeFromParent()
			self.duibai = nil
			FightSystem.mTouchPad.mRD_Node:getChildByName("Button_Skill_3"):setVisible(true)
			self:AddGuideaperture(FightSystem.mTouchPad.mRD_Node:getChildByName("Button_Skill_3"),8049)
			FightSystem.mTouchPad.mRD_Node:getChildByName("Panel_Skill_2_Cover"):setVisible(true)
			FightSystem.mTouchPad:setCancelledTouchMove(false)
		end

		
		self.mMDShowText:setVisible(false)
		self.duibai = GuideSystem:createGuideCGLayer(self.TalkSetp8, CallBack)
		FightSystem.mTouchPad:addChild(self.duibai,200)
		local role = FightSystem.mRoleManager:LoadMonster(1101,cc.p(self.MonsterThirdX,250))
		role.mAI:setOpenAI(false)
		role.mAI.mActionOpen = false
		local role1 = FightSystem.mRoleManager:LoadMonster(1101,cc.p(self.MonsterThirdX,150))
		role1.mAI:setOpenAI(false)
		role1.mAI.mActionOpen = false

		local keyrole = FightSystem:GetKeyRole()
		if keyrole.mFSM:IsAttacking() then
			keyrole.mSkillCon:FinishCurSkill()
			keyrole.mFSM:ForceChangeToState("idle")
		end
		FightSystem.mTouchPad:setCancelledTouchMove(true)
	end
	]]
end

-- 战斗新手指引8 技能3打死小怪后
function FubenManager:GuideStep8_1()
	if self.mIsFightGuide then
		local function CallBack()
			self.mMDShowText:setVisible(false)
			self.duibai:removeFromParent()
			self.duibai = nil
			FightSystem.mTouchPad:setCancelledTouchMove(false)
			self:GuideStep9()

		end
		self:RemoveGuideaperture()
		self.mMDShowText:setVisible(false)
		self.duibai = GuideSystem:createGuideCGLayer(self.TalkSetp8_1, CallBack)
		FightSystem.mTouchPad:addChild(self.duibai,200)
		local keyrole = FightSystem:GetKeyRole()
		if keyrole.mFSM:IsAttacking() then
			keyrole.mSkillCon:FinishCurSkill()
			keyrole.mFSM:ForceChangeToState("idle")
		end
		FightSystem.mTouchPad:setCancelledTouchMove(true)
	end
end

-- 战斗新手指引8 过第二个版
function FubenManager:GuideStep9()
	if self.mIsFightGuide then
		local function CallBack()
			self.mMDShowText:setVisible(false)
			self.duibai:removeFromParent()
			self.duibai = nil
			FightSystem.mTouchPad:setCancelledTouchMove(false)
			self:GuideStep10()

		end
		self:RemoveGuideaperture()
		self.mMDShowText:setVisible(false)
		self.duibai = GuideSystem:createGuideCGLayer(self.TalkSetp9, CallBack)
		FightSystem.mTouchPad:addChild(self.duibai,200)
		local keyrole = FightSystem:GetKeyRole()
		if keyrole.mFSM:IsAttacking() then
			keyrole.mSkillCon:FinishCurSkill()
			keyrole.mFSM:ForceChangeToState("idle")
		end
		FightSystem.mTouchPad:setCancelledTouchMove(true)
	end

	--[[
	if self.mIsFightGuide then
		self:RemoveGuideaperture()
		self.mMDShowText:setVisible(false)
		FightSystem.mTouchPad.mRD_Node:getChildByName("Panel_Skill_2_Cover"):setVisible(false)
		FightSystem.mRoleManager:LoadMonster(1101,cc.p(self.MonsterFourthX,250))
		FightSystem.mRoleManager:LoadMonster(1101,cc.p(self.MonsterFourthX,150))
		FightSystem.mRoleManager:LoadMonster(1101,cc.p(self.MonsterFourthX+200,250))
		FightSystem.mRoleManager:LoadMonster(1101,cc.p(self.MonsterFourthX+200,150))
	end
	]]
end

function FubenManager:GuideStep10()
	if self.mIsFightGuide then

		self.mMDShowText:setVisible(true)
		richTextCreateWithFont(self.mMDShowText:getChildByName("Panel_Text"),getDictionaryCGText(self.TextSetp10) , true,self.mMidTextSize)

		local role1 = FightSystem.mRoleManager:LoadMonster(1101,cc.p(1700-320,250))
		local role2 = FightSystem.mRoleManager:LoadMonster(1101,cc.p(1700+100-320,220))
		local role3 = FightSystem.mRoleManager:LoadMonster(1101,cc.p(1700+100-320,200))
		local role4 = FightSystem.mRoleManager:LoadMonster(1101,cc.p(1700-320,180))
		role1.mAI:setOpenAI(false)
		role1.mAI.mActionOpen = false
		role2.mAI:setOpenAI(false)
		role2.mAI.mActionOpen = false
		role3.mAI:setOpenAI(false)
		role3.mAI.mActionOpen = false
		role4.mAI:setOpenAI(false)
		role4.mAI.mActionOpen = false
		self:RemoveGuideaperture()
	end
end

function FubenManager:GuideStep10_1()
	if self.mIsFightGuide then
		local function CallBack()
			self.duibai:removeFromParent()
			self.duibai = nil
			self.Guideboss.mAI:setOpenAI(true)
			self.Guideboss.mAI.mActionOpen = true
			FightSystem.mTouchPad:setCancelledTouchMove(false)
		end
		self.duibai = GuideSystem:createGuideCGLayer(self.TalkSetp10, CallBack)
		FightSystem.mTouchPad:addChild(self.duibai,200)
		self.Guideboss = FightSystem.mRoleManager:LoadMonster(1106,cc.p(self.BossX,250))
		self.Guideboss.mAI:setOpenAI(false)
		self.Guideboss.mAI.mActionOpen = false
		FightSystem.mTouchPad:InitBossBar(self.Guideboss)
		if FightSystem.mFightType == "fuben" and globaldata.PvpType == "fuben" then
			FightSystem.mTouchPad:BossWarning()
		end
		local keyrole = FightSystem:GetKeyRole()
		if keyrole.mFSM:IsAttacking() then
			keyrole.mSkillCon:FinishCurSkill()
			keyrole.mFSM:ForceChangeToState("idle")
		end
		FightSystem.mTouchPad:setCancelledTouchMove(true)


	end
end

----------------回调--------------------------
-- 加载
function FubenManager:OnEnterShowPve()
	-----------------------------
	self.IsShowGuanqia = true
	local fubenId = globaldata.boardIDforShowGq
	local _level = globaldata.ShowGqhard
	self.mDropController = FubenDropController.new()
	self.mDropController:Init(fubenId,_level,true)

	self.mShowPveController = FubenShowPveController.new()

	local function _enterPVE()
		local _data = {}
		_data.mType = "fuben"
		_data.mHard = fubenId 
		_data.mPveLevel = _level
		Event.GUISYSTEM_SHOW_FIGHTWINDOW.mData = _data
		EventSystem:PushEvent(Event.GUISYSTEM_SHOW_FIGHTWINDOW)
		-- 给予渲染时间，延迟1秒消失loading窗口
		hideLoadingWindow()
	end
	-- 预加载角色
	local function _loadRoles()
		_co2 = coroutine.create(function()
			-- myteam
			local _count = globaldata:getBattleFormationCount()
			for i = 1, _count do
				local _json, _atlas, _scale, _soundList, _skillList = globaldata:getMyFightTeamSpineData(i)
				CommonAnimation.preloadSoundList(_soundList)
				coroutine.yield()
				CommonAnimation.preloadSkillSoundAndEffect(_skillList)
				coroutine.yield()
				CommonAnimation.preloadSpine_common(_json, _atlas, _scale)
				coroutine.yield()
			end
			-- monster
			local _count1 = globaldata:getBattleEnemyFormationCount()
			for i = 1, _count1 do
				local _json, _atlas, _scale, _soundList, _skillList = globaldata:getEnemyFightTeamSpineData(i)
				CommonAnimation.preloadSpine_common(_json, _atlas, _scale)
				coroutine.yield()
				CommonAnimation.preloadSkillSoundAndEffect(_skillList)
				coroutine.yield()
				CommonAnimation.preloadSpine_common(_json, _atlas, _scale)
				coroutine.yield()
			end
			-- 场景道具
			for k,_id in pairs(self.mDropController.SceneList) do
				local _dbScene = DB_SceneAnimationConfig.getDataById(_id)
				CommonAnimation.preloadSpine_commonByResID(_dbScene.Animation_ResID)
				coroutine.yield()
			end
		end)
	end
	---------------------------
	if FightSystem.mIsReFight then
		_enterPVE()
	else
		_loadRoles()
		----- 开始协同
		local _handler = 0
		local function xxx()
			coroutine.resume(_co2)
			if coroutine.status(_co2) == "dead" then
				_enterPVE()
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_handler)
			end
		end
		_handler = nextTick_eachSecond(xxx, _INTERVAL_LOAD_FIGHT_CORUTINE_)
	end
end


-- 回包了，准备进入副本
function FubenManager:OnPreEnterPve(_chapter, _section, _level)
	if FightSystem.mIsReFight then
	else
		self.mPreloadSpineList = {}
	end
	local fubentype = "fb%d-%d"
	if globaldata.clickedlevel == 2 then
		fubentype = "fbjy%d-%d"
	end
	local key = string.format(fubentype,globaldata.clickedchapter,globaldata.clickedsection)
	AnySDKManager:td_task_begin(key)
	local sections = nil
	if 1 == _level then
		sections = DB_MapUIConfig.getArrDataByField("MapUI_ChapterID", _chapter)
	elseif 2 == _level then
		sections = DB_MapUIConfigNormal.getArrDataByField("MapUI_ChapterID", _chapter)
	end

	local function sortFunc(section1, section2)
		return section1.ID < section2.ID
	end
	table.sort(sections, sortFunc)

	for i = 1, #sections do
		if 0 == sections[i].MapUI_SectionID then
			table.remove(sections, i)
			break
		end
	end

	-----------------------------
	local fubenId = sections[_section].MapUI_BoardConfigID
	self.mDropController = FubenDropController.new()
	self.mDropController:Init(fubenId,_level)
	local function _enterPVE()
		local _data = {}
		_data.mType = "fuben"
		_data.mHard = fubenId 
		_data.mPveLevel = _level
		Event.GUISYSTEM_SHOW_FIGHTWINDOW.mData = _data
		EventSystem:PushEvent(Event.GUISYSTEM_SHOW_FIGHTWINDOW)
		-- 给予渲染时间，延迟1秒消失loading窗口
		hideLoadingWindow()

	end
	-- 预加载角色
	local function _loadRoles(_section, _level)
		_co2 = coroutine.create(function()
			-- myteam
			local _count = globaldata:getBattleFormationCount()
			local _battlecount = self:LoadBattleFriendCount(fubenId,_count)
			for i = 1, _battlecount do
				local _json, _atlas, _scale, _soundList, _skillList = globaldata:getMyFightTeamSpineData(i)
				CommonAnimation.preloadSoundList(_soundList)
				CommonAnimation.preloadSkillSoundAndEffect(_skillList)
				CommonAnimation.preloadSpine_common(_json, _atlas, _scale)
				self.mPreloadSpineList[_json] = true
				coroutine.yield()
			end
			-- monster
			for _monsterId,v in pairs(self.mDropController.MonsterList) do
				local _db = DB_MonsterConfig.getDataById(_monsterId)
				-- cclog("aaa ===" .. _monsterId)
				CommonAnimation.preloadSoundList(_db.SoundList)
				local _skillList = {_db.Monster_NormalSkill1, _db.Monster_NormalSkill2, _db.Monster_NormalSkill3, _db.Monster_NormalSkill4,
									_db.Monster_SpecialSkill1, _db.Monster_SpecialSkill2, _db.Monster_SpecialSkill3, _db.Monster_SpecialSkill4}
				CommonAnimation.preloadSkillSoundAndEffect(_skillList)
				CommonAnimation.preloadSpine_commonByResID(_db.Monster_Model)
				local _resDB = DB_ResourceList.getDataById(_db.Monster_Model)
				self.mPreloadSpineList[_resDB.Res_path2] = true
				coroutine.yield()
			end
			-- 场景道具
			for k,_id in pairs(self.mDropController.SceneList) do
				local _dbScene = DB_SceneAnimationConfig.getDataById(_id)
				CommonAnimation.preloadSpine_commonByResID(_dbScene.Animation_ResID)
				coroutine.yield()
			end
		end)
	end
	---------------------------
	if FightSystem.mIsReFight then
		_enterPVE()
	else
		_loadRoles(_section, _level)
		----- 开始协同
		local _handler = 0
		local function xxx()
			coroutine.resume(_co2)
			if coroutine.status(_co2) == "dead" then
				_enterPVE()
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_handler)
			end
		end
		_handler = nextTick_eachSecond(xxx, _INTERVAL_LOAD_FIGHT_CORUTINE_)
	end
end

-- 财富山战斗进入
function FubenManager:OnPreEnterPveWealth()

	self.mDropController = FubenDropController.new()
	self.mDropController:Init(globaldata.boardIDforWealth,globaldata.Wealthhard)
	local function _enterPVE()
		local _data = {}
		_data.mType = "fuben"
		_data.mHard = globaldata.boardIDforWealth
		_data.mPveLevel = globaldata.Wealthhard
		Event.GUISYSTEM_SHOW_FIGHTWINDOW.mData = _data
		EventSystem:PushEvent(Event.GUISYSTEM_SHOW_FIGHTWINDOW)
		-- 给予渲染时间，延迟1秒消失loading窗口
		hideLoadingWindow()
	end
	-- 预加载角色
	local function _loadRoles()
		_co2 = coroutine.create(function()
			-- myteam
			local _count = globaldata:getBattleFormationCount()
			local _battlecount = self:LoadBattleFriendCount(globaldata.boardIDforWealth,_count)
			for i = 1, _battlecount do
				local _json, _atlas, _scale, _soundList, _skillList = globaldata:getMyFightTeamSpineData(i)
				-- CommonAnimation.preloadSoundList(_soundList)
				-- CommonAnimation.preloadSkillSoundAndEffect(_skillList)
				CommonAnimation.preloadSpine_common(_json, _atlas, _scale)
				coroutine.yield()
			end
			-- monster
			for _monsterId,v in pairs(self.mDropController.MonsterList) do
				local _db = DB_MonsterConfig.getDataById(_monsterId)
				-- local _skillList = {_db.Monster_NormalSkill1, _db.Monster_NormalSkill2, _db.Monster_NormalSkill3, _db.Monster_NormalSkill4,
					-- _db.Monster_SpecialSkill1, _db.Monster_SpecialSkill2, _db.Monster_SpecialSkill3, _db.Monster_SpecialSkill4}
				-- CommonAnimation.preloadSoundList(_db.SoundList)
				-- CommonAnimation.preloadSkillSoundAndEffect(_skillList)
				CommonAnimation.preloadSpine_commonByResID(_db.Monster_Model)
				coroutine.yield()
			end
			-- 场景道具
			for k,_id in pairs(self.mDropController.SceneList) do
				local _dbScene = DB_SceneAnimationConfig.getDataById(_id)
				CommonAnimation.preloadSpine_commonByResID(_dbScene.Animation_ResID)
				coroutine.yield()
			end
		end)
	end
	---------------------------
	if FightSystem.mIsReFight then
		_enterPVE()
	else
		_loadRoles()
		----- 开始协同
		local _handler = 0
		local function xxx()
			coroutine.resume(_co2)
			if coroutine.status(_co2) == "dead" then
				_enterPVE()
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_handler)
			end
		end
		_handler = nextTick_eachSecond(xxx, _INTERVAL_LOAD_FIGHT_CORUTINE_)
	end
end

-- 爬塔战斗进入
function FubenManager:OnPreEnterPveTower()

	self.mDropController = FubenDropController.new()
	self.mDropController:Init(globaldata.boardIDforTower,globaldata.Towerhard)
	local function _enterPVE()
		local _data = {}
		_data.mType = "fuben"
		_data.mHard = globaldata.boardIDforTower
		_data.mPveLevel = globaldata.Towerhard
		Event.GUISYSTEM_SHOW_FIGHTWINDOW.mData = _data
		EventSystem:PushEvent(Event.GUISYSTEM_SHOW_FIGHTWINDOW)
		-- 给予渲染时间，延迟1秒消失loading窗口
		hideLoadingWindow()
	end
	-- 预加载角色
	local function _loadRoles()
		_co2 = coroutine.create(function()
			-- myteam
			local _count = globaldata:getBattleFormationCount()
			local _battlecount = self:LoadBattleFriendCount(globaldata.boardIDforWealth,_count)
			for i = 1, _battlecount do
				local _json, _atlas, _scale, _soundList, _skillList = globaldata:getMyFightTeamSpineData(i)
				-- CommonAnimation.preloadSoundList(_soundList)
				-- CommonAnimation.preloadSkillSoundAndEffect(_skillList)
				CommonAnimation.preloadSpine_common(_json, _atlas, _scale)
				coroutine.yield()
			end
			-- monster
			for _monsterId,v in pairs(self.mDropController.MonsterList) do
				local _db = DB_MonsterConfig.getDataById(_monsterId)
				-- local _skillList = {_db.Monster_NormalSkill1, _db.Monster_NormalSkill2, _db.Monster_NormalSkill3, _db.Monster_NormalSkill4,
					-- _db.Monster_SpecialSkill1, _db.Monster_SpecialSkill2, _db.Monster_SpecialSkill3, _db.Monster_SpecialSkill4}
				-- CommonAnimation.preloadSoundList(_db.SoundList)
				-- CommonAnimation.preloadSkillSoundAndEffect(_skillList)
				CommonAnimation.preloadSpine_commonByResID(_db.Monster_Model)
				coroutine.yield()
			end
			-- 场景道具
			for k,_id in pairs(self.mDropController.SceneList) do
				local _dbScene = DB_SceneAnimationConfig.getDataById(_id)
				CommonAnimation.preloadSpine_commonByResID(_dbScene.Animation_ResID)
				coroutine.yield()
			end
		end)
	end
	---------------------------
	if FightSystem.mIsReFight then
		_enterPVE()
	else
		_loadRoles()
		----- 开始协同
		local _handler = 0
		local function xxx()
			coroutine.resume(_co2)
			if coroutine.status(_co2) == "dead" then
				_enterPVE()
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_handler)
			end
		end
		_handler = nextTick_eachSecond(xxx, _INTERVAL_LOAD_FIGHT_CORUTINE_)
	end
end

function FubenManager:CountFinish()
	FightSystem.mRoleManager:AllPlayerAiStop(true)
	if globaldata.PvpType == "blackMarket" then
		if FightSystem:isEnabledHeishiAuto() then
			FightSystem.mTouchPad:setCheckAuto(true)
		end
	end
end

-- 掠夺战斗进入
function FubenManager:OnPreEnterPvePlunder()
	self.mDropController = FubenDropController.new()
	self.mDropController:Init(globaldata.mboardIDforPlunder,globaldata.PlunderhardId,true)

	local function _enterPVE()
		local _data = {}
		_data.mType = "fuben"
		_data.mHard = globaldata.mboardIDforPlunder
		_data.mPveLevel = globaldata.PlunderhardId
		Event.GUISYSTEM_SHOW_FIGHTWINDOW.mData = _data
		EventSystem:PushEvent(Event.GUISYSTEM_SHOW_FIGHTWINDOW)
		-- 给予渲染时间，延迟1秒消失loading窗口
		hideLoadingWindow()
		GUISystem:FightBeginlayout(handler(self,self.CountFinish))
	end
	-- 预加载角色
	local function _loadRoles()
		_co2 = coroutine.create(function()
			-- myteam
			local _count = globaldata:getBattleFormationCount()
			local _battlecount = self:LoadBattleFriendCount(globaldata.mboardIDforPlunder,_count)
			for i = 1, _battlecount do
				local _json, _atlas, _scale, _soundList, _skillList = globaldata:getMyFightTeamSpineData(i)
				-- CommonAnimation.preloadSoundList(_soundList)
				-- CommonAnimation.preloadSkillSoundAndEffect(_skillList)
				CommonAnimation.preloadSpine_common(_json, _atlas, _scale)
				coroutine.yield()
			end
			-- monster
			for _monsterId,v in pairs(self.mDropController.MonsterList) do
				local _db = DB_MonsterConfig.getDataById(_monsterId)
				-- local _skillList = {_db.Monster_NormalSkill1, _db.Monster_NormalSkill2, _db.Monster_NormalSkill3, _db.Monster_NormalSkill4,
					-- _db.Monster_SpecialSkill1, _db.Monster_SpecialSkill2, _db.Monster_SpecialSkill3, _db.Monster_SpecialSkill4}
				-- CommonAnimation.preloadSoundList(_db.SoundList)
				-- CommonAnimation.preloadSkillSoundAndEffect(_skillList)
				CommonAnimation.preloadSpine_commonByResID(_db.Monster_Model)
				coroutine.yield()
			end
			-- monsterPlayers
			_count = globaldata:getBattleEnemyFormationCount()
			for i = 1, _count do
				local _json, _atlas, _scale, _soundList, _skillList = globaldata:getEnemyFightTeamSpineData(i)
				-- CommonAnimation.preloadSoundList(_soundList)
				-- CommonAnimation.preloadSkillSoundAndEffect(_skillList)
				CommonAnimation.preloadSpine_common(_json, _atlas, _scale)
				coroutine.yield()
			end
			-- 场景道具
			for k,_id in pairs(self.mDropController.SceneList) do
				local _dbScene = DB_SceneAnimationConfig.getDataById(_id)
				CommonAnimation.preloadSpine_commonByResID(_dbScene.Animation_ResID)
				coroutine.yield()
			end
		end)
	end
	---------------------------
	if FightSystem.mIsReFight then
		_enterPVE()
	else
		_loadRoles()
		----- 开始协同
		local _handler = 0
		local function xxx()
			coroutine.resume(_co2)
			if coroutine.status(_co2) == "dead" then
				_enterPVE()
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_handler)
			end
		end
		_handler = nextTick_eachSecond(xxx, _INTERVAL_LOAD_FIGHT_CORUTINE_)
	end
end
