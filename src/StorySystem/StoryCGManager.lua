-- Name: StoryCGManager
-- Func: 剧情系统，CG管理器
-- Author: Johny

--require "experimentalConstants"

local StoryCGManager = class("StoryCGManager")


function StoryCGManager:ctor()
	-- self.mVideoPlayer = nil
    self.mCGRuning = false
    self.CanNext = 0
    self.mActionList = {}
    self.mDialogTable = {}
    --
    self.mDate = nil
    self.mStagetime = 0
    self.mNextId = -1
    --
    self.misFubenInit = false
    --
    self.mCGListFriend = {}
    self.mCGListMonster = {}

    self.Callback = nil

    self.mFocusId = 0

    self.CGPlaySpeed = 0.03
end

function StoryCGManager:Tick(delta)
    if not self.mCGRuning then return end
	if self.mStagetime <= 0 then
        self.mStagetime = 0
        if self.mNextId ~= -1 then
            local id = self.mNextId
            self.mNextId = -1
            self:NextStageById(id)
        end
    else
        self.mStagetime = self.mStagetime - delta
    end
end

function StoryCGManager:Release()
	
	--
	_G["StoryCGManager"] = nil
 	package.loaded["StoryCGManager"] = nil
 	package.loaded["StorySystem/StoryCGManager"] = nil
end


function StoryCGManager:ShowCG(id,callback,_end)
    self.mIsFinishBoardEnd = _end
    self.Callback = callback
    self:ShowCGById(id)
end

function StoryCGManager:ShowCGById(id)
    cclog("StoryCGManager:ShowCGById ==" .. id)
    self.mStep = 1
    self.mDate = nil
    self.mDate = DB_CGStageConfig.getDataById(id)
    self.mStagetime = self.mDate.CG_StageTime

    if self.mDate.CG_StageType == 1 then
        self:StartStageCG()
        return
    end
    self:StageCG()
end

function StoryCGManager:PlayCG()
	self.mVideoPlayer:play()
end

function StoryCGManager:PauseCG()
	self.mVideoPlayer:pause()
end

function StoryCGManager:ResumeCG()
	self.mVideoPlayer:resume()
end

function StoryCGManager:StopCG()
	self.mVideoPlayer:stop()
end

-- 退出CG界面处理
function StoryCGManager:CGEnd()
     if self.mCGRuning then
        self.mCGRuning = false
        if self.Posescheduler then 
            local scheduler = cc.Director:getInstance():getScheduler()
            scheduler:unscheduleScriptEntry(self.Posescheduler)
            self.Posescheduler = nil
        end
        self.mCGListFriend = {}
        self.mCGListMonster = {}
        self.mStagetime = 0
        self.mNextId = -1
        self.CanNext = 0
        self.mRunLabel = false
     end
     self.mCGRuning = nil
end

function StoryCGManager:StartStageCG()
    -- 当前第一个进入版面
    self.mCGRuning = true
    FightSystem.mTouchPad:disabled(true)
    self.mRootNode = cc.Node:create()
    self.mRootNode:setLocalZOrder(FightConfig.FIGHTWINDOW_Z_CGSCENE)
    GUISystem.Windows["FightWindow"].mRootNode:addChild(self.mRootNode)

    self.mRootBlack = cc.Node:create()
    self.mRootBlack:setLocalZOrder(FightConfig.FIGHTWINDOW_Z_CGSCENE+1)
    GUISystem.Windows["FightWindow"].mRootNode:addChild(self.mRootBlack)

    self:CreateAllDialog()
    --self:CreatePose()

    CommonAnimation.BlackScreenForFCG(self.mRootBlack,0.5,0.5,handler(self,self.InBlackScreen),handler(self,self.OutBlackScreen))
end

function StoryCGManager:InBlackScreen()
    -- 进入黑色
    -- 隐藏touchpad
    FightSystem.mTouchPad:setVisible(not self.mCGRuning)
    -- 隐藏人物
    if self.mCGRuning then
        FightSystem.mRoleManager:hideAllRoles()
        if FightSystem:GetFightManager().mFubenModel == 7 then
            FightSystem.mRoleManager:hideAllSceneAni(true)
        end
        self:StageCG()
    else
        if self.Callback then
            self.Callback()
            self.Callback = nil
        end
        FightSystem.mRoleManager:showAllRoles()
        if FightSystem:GetFightManager().mFubenModel == 7 then
            FightSystem.mRoleManager:hideAllSceneAni(false)
        end
       -- FightSystem.mRoleManager:showBornRoles()
        self.mRootNode:removeFromParent(true)
    end
end

function StoryCGManager:OutBlackScreen()
    -- 淡出黑色
    if not self.mIsFinishBoardEnd then
        FightSystem.mTouchPad:setVisible(not self.mCGRuning)
    end
    if not self.mCGRuning then
        if self.misFubenInit then
            FightSystem.mFubenManager:ShowSchool(true)
            self.misFubenInit = false
        end 
        self.mRootBlack:removeFromParent(true)
    else
        self.Tiaobtn:setVisible(true)
    end
end

function StoryCGManager:EndedStageCGResult()
     -- 当前结束
    self:CGEnd()
    self.mCGRuning = true
    if self.Callback then
        self.Callback()
        self.Callback = nil
    end
end

function StoryCGManager:EndedStageCG()
    -- 当前结束
    if not self.mCGRuning then return end
    self.mCGRuning = false
    if self.mSpinePose then
        self.mSpinePose:removeFromParent()
        self.mSpinePose = nil
    end
    FightSystem.mRoleManager:StopEachSpineTickForCg(false)
    if self.Posescheduler then 
        local scheduler = cc.Director:getInstance():getScheduler()
        scheduler:unscheduleScriptEntry(self.Posescheduler)
        self.Posescheduler = nil
    end
    --FightSystem.mRoleManager:setActionOpenRoles()
    FightSystem.mTouchPad:disabled(false)
    CommonAnimation.BlackScreenForFCG(self.mRootBlack,0.5,0.5,handler(self,self.InBlackScreen),handler(self,self.OutBlackScreen))
    FightSystem.mSceneManager.mCamera:ChangeRole(FightSystem.mRoleManager:GetKeyRole():getShadowPos(),true)
    self:RemoveAllDialog()
    self:RemoveCGAll()
    self.mCGListFriend = {}
    self.mCGListMonster = {}
    self.mStagetime = 0
    self.mNextId = -1
    self.CanNext = 0
    self.mRunLabel = false
end

--执行各个Action
function StoryCGManager:StageCG()
    if not self.mCGRuning then return end
    if self.mStep == 5 then
        if self.CanNext ~= 0 then return end
        if self.mStagetime ~= 0 then 
            self.mNextId = self.mDate.CG_NextStage
            cclog("No1==="..self.mNextId)
            return 
        end
        self:NextStageById(self.mDate.CG_NextStage)
        return
    end
    local key = "CG_Action" .. self.mStep .. "Type"
    local key_Objectid = "CG_Action" .. self.mStep .. "Object"
    local key_Param1 = "CG_Action" .. self.mStep .. "Param1"
    local key_Param2 = "CG_Action" .. self.mStep .. "Param2"
    local key_Param3 = "CG_Action" .. self.mStep .. "Param3"

    local id = self.mDate[key_Objectid]
    local param1 = self.mDate[key_Param1]
    local param2 = self.mDate[key_Param2]
    local param3 = self.mDate[key_Param3]

    self.mStep = self.mStep + 1

    cclog("selfSTEP=========" .. self.mStep)
    cclog("self.mDate[key]=======" .. self.mDate[key])

    cclog("id===" ..id)
    cclog("param1===" ..param1)
    cclog("param2===" ..param2)
    cclog("param3===" ..param3)


    if self.mDate[key] ==  0 then
        if self.CanNext ~= 0 then return end
        if self.mStagetime ~= 0 then
            cclog("TIME============"..self.mStagetime) 
            cclog("NEEEEEEE====="..self.mDate.CG_NextStage)
            self.mNextId = self.mDate.CG_NextStage
             cclog("No2==="..self.mNextId)
            return 
        end
        self:NextStageById(self.mDate.CG_NextStage)
    elseif self.mDate[key] == 1 then
        self:Move(id,param1,param2,param3)
    elseif self.mDate[key] == 2 then
        self:PlayAction(id,param1,param2,param3)
    elseif self.mDate[key] == 3 then
        self:PlayTalk(id,param1,param2,param3)
    elseif self.mDate[key] == 4 then
        self:Object(id,param1,param2,param3)
    elseif self.mDate[key] == 5 then
        self:ScreenEffect(id,param1,param2,param3)
    elseif self.mDate[key] == 6 then
        self:Focus(id,param1,param2,param3)
    elseif self.mDate[key] == 7 then
        self:PlayPicture(id,param1,param2,param3)
    elseif self.mDate[key] == 8 then
        self:CloseTalk(id,param1,param2,param3)
    elseif self.mDate[key] == 9 then
        self:MakePose(id,param1,param2,param3)
    end

    
end

-- 下一个舞台
function StoryCGManager:NextStageById(id)
    if id == 0 then
        if self.mIsFinishBoardEnd then
            self:EndedStageCGResult()
        else
            self:EndedStageCG()
        end
    else
        self:ShowCGById(id)
    end
end

-- 发现CG ID对应的Role
function StoryCGManager:FindCGRoleById(id)
     if id == -1 then
        local _id = globaldata:getBattleFormationInfoByIndexAndKey(1, "id")
        return FightSystem.mRoleManager:FindCGRoleByIdx("friend",_id)
   elseif id == 0 then
         local _id = globaldata.registerHeroId
        return FightSystem.mRoleManager:FindCGRoleByIdx("friend",_id)
    else
        return FightSystem.mRoleManager:FindCGRoleByIdx("monster",id)
    end 
end

-- 移动之后回调
function StoryCGManager:OnStopGoalPos()
    self.CanNext = self.CanNext - 1 
    if self.CanNext == 0 then
        self:NextStepStage()
    end
end

function StoryCGManager:NextStepStage()
    local function doSomething()
        self:StageCG()
    end
    nextTick(doSomething)
end
-- 播放Action 完成
function StoryCGManager:OnActionFinish(_action)
    for i,v in ipairs(self.mActionList) do
        if _action == v then
            table.remove(self.mActionList,i)  
            self.CanNext = self.CanNext - 1 
            if self.CanNext == 0 then
               self:NextStepStage()
            end
        end
    end
end

--移动
function StoryCGManager:Move(id,Param1,Param2,Param3)
   local role = self:FindCGRoleById(id)
   if role then
        if Param1 ~= 0 then
            role.mPropertyCon.mSpeed = Param1 * MathExt._game_frame
        end
        role:WalkingByPos(cc.p(Param2,Param3),handler(self,self.OnStopGoalPos))
   end
    self.CanNext = self.CanNext + 1
end

--播放动作
function StoryCGManager:PlayAction(id,Param1,Param2,Param3)
    --
    local role = self:FindCGRoleById(id)
    if role then
        role.mArmature:ActionNow(Param1)
        table.insert(self.mActionList,Param1)
        role.mArmature:RegisterActionEnd("StoryCGManager",handler(self, self.OnActionFinish))
        self.CanNext = self.CanNext + 1
    end
end

--播放对话
function StoryCGManager:PlayTalk(id,Param1,Param2,Param3)
    if not self.mCGRuning then return end
    self.Curplace = Param2 + 1
    local _resDB = nil
    local heroName = nil
    if id == -1 then
        local _heroID = globaldata:getBattleFormationInfoByIndexAndKey(1, "id")
        local _infoDB = DB_HeroConfig.getDataById(_heroID)
        heroName = getDictionaryText(_infoDB.Name)
        _resDB = DB_ResourceList.getDataById(_infoDB.IconCG)
    elseif id == 0 then
        local _heroID = globaldata.registerHeroId
        local _infoDB = DB_HeroConfig.getDataById(_heroID)
        heroName = getDictionaryText(_infoDB.Name)
        _resDB = DB_ResourceList.getDataById(_infoDB.IconCG)
    else
        local _infoDB = DB_MonsterConfig.getDataById(id)
        heroName = getDictionaryText(_infoDB.Name)
        _resDB = DB_ResourceList.getDataById(_infoDB.IconCG)
    end
    local head = self.mDialogTable[self.Curplace]["head"]

    self.mLabel = self.mDialogTable[self.Curplace]["labeltalk"]

    self.Strtext = getDictionaryCGText(Param3)
    self.Strtext = TextParseManager:parseText(self.Strtext)
    
    self.tableText = splitChineseString( self.Strtext)

    self.index = 0

    self.mRunLabel = true
    self.mLabel:stopAllActions()
    self.mLabel:removeAllChildren()

    local function ShowBoxFinish()
            local function doSomthing()
            if self.index == #self.tableText then
                self.mLabel:stopAllActions()
                richTextCreateWithFont(self.mLabel,self.Strtext , true,25)
                CommonAnimation.PlayEffectId(35)
                self.mRunLabel = false
            else
                self.index = self.index + 1
                --self.mLabel:setString(self.tableText[self.index])
                richTextCreateWithFont(self.mLabel,self.tableText[self.index] , true,25)
                if self.index%2 == 1 then
                    CommonAnimation.PlayEffectId(35)
                end
            end
          end

            local headfun = cc.CallFunc:create(doSomthing)
            local DelayTime = cc.DelayTime:create(self.CGPlaySpeed)
            self.mLabel:runAction(cc.RepeatForever:create(cc.Sequence:create(headfun, DelayTime)))

    end 
    head:setVisible(true)
    head:loadTexture(_resDB.Res_path1)--"skill_22_1.png"
    local width = 0--head:getBoundingBox().width/2
    local height = 0--head:getBoundingBox().height/2
    local Flag = false
    if not self.mTalkBoxLeft:isVisible() and not self.mTalkBoxRight:isVisible() then
        self.mArrow_l:setVisible(true)
        self.mArrow_l:setOpacity(0)
        local actionTo1 = cc.FadeIn:create(0.2)
        self.mArrow_l:runAction(actionTo1)
    end

    if self.Curplace == 1 then
        self.mDialogTable[1]["labelname"]:setString(heroName)
        self.Movepos1 = cc.p(0,0)
        local time = 0
        if self.mTalkBoxRight:isVisible() then
            local act1 = cc.FadeOut:create(0.2)
            local act2 = cc.Hide:create()
            local action1 = cc.Sequence:create(act1,act2)
            self.mTalkBoxRight:runAction(action1)
            local player = self.mDialogTable[2]["head"]
            local pos = cc.p(player:getPosition())
            local move = cc.MoveTo:create(0.2,cc.p(self.CurHeadpos2.x+player:getBoundingBox().width,self.CurHeadpos2.y))
            local act1 = cc.FadeOut:create(0.2)
            local acthide = cc.Hide:create()
            local act3 = cc.Spawn:create(move,act1)
            player:runAction(cc.Sequence:create(act3,acthide))
            time = 0.2
        end
        if  not self.mTalkBoxLeft:isVisible() then
            self.mTalkBoxLeft:setVisible(true)
            self.mTalkBoxLeft:setOpacity(0)
            local actionTo1 = cc.FadeIn:create(time+0.2)
            self.mTalkBoxLeft:runAction(actionTo1)

            head:setPositionX(self.CurHeadpos1.x - head:getBoundingBox().width)
            local DelayTime = cc.DelayTime:create(time+0.2)
            local function Func()
                head:setOpacity(0) 
            end
            local headfun = cc.CallFunc:create(Func)
            local act1 = cc.FadeIn:create(0.2)
            local move = cc.MoveTo:create(0.2,self.CurHeadpos1)
            local act2 = cc.Spawn:create(move,act1)
            local call1 = cc.CallFunc:create(ShowBoxFinish)
            local action1 = cc.Sequence:create(DelayTime,headfun,act2,call1)
            head:runAction(action1)
            Flag = true
        end

    elseif self.Curplace == 2 then
        self.mDialogTable[2]["labelname"]:setString(heroName)
        local time = 0
        if self.mTalkBoxLeft:isVisible() then
            local act1 = cc.FadeOut:create(0.2)
            local act2 = cc.Hide:create()
            local action1 = cc.Sequence:create(act1,act2)
            self.mTalkBoxLeft:runAction(action1)
            local player = self.mDialogTable[1]["head"]
            local pos = cc.p(player:getPosition())
            local move = cc.MoveTo:create(0.2,cc.p(self.CurHeadpos1.x-player:getBoundingBox().width,self.CurHeadpos1.y))
            local act1 = cc.FadeOut:create(0.2)
            local acthide = cc.Hide:create()
            local act3 = cc.Spawn:create(move,act1)
            player:runAction(cc.Sequence:create(act3,acthide))
            time = 0.2
        end
        if  not self.mTalkBoxRight:isVisible() then
            self.mTalkBoxRight:setVisible(true)
            self.mTalkBoxRight:setOpacity(0)
            head:setPositionX(self.CurHeadpos2.x + head:getBoundingBox().width)
            local actionTo1 = cc.FadeIn:create(time+0.2)
            self.mTalkBoxRight:runAction(actionTo1)
            head:setVisible(true)
            local DelayTime = cc.DelayTime:create(time+0.2)
            local function Func()
                head:setOpacity(0) 
            end
            local headfun = cc.CallFunc:create(Func)
            local act1 = cc.FadeIn:create(0.2)
            local move = cc.MoveTo:create(0.2,self.CurHeadpos2)
            local act2 = cc.Spawn:create(move,act1)
            local call1 = cc.CallFunc:create(ShowBoxFinish)
            local action1 = cc.Sequence:create(DelayTime,headfun,act2,call1)
            head:runAction(action1)
            Flag = true
        end
    end
    if not Flag  then
        local function doSomthing1()
            if self.index == #self.tableText then
                self.mLabel:stopAllActions()
                richTextCreateWithFont(self.mLabel,self.Strtext , true,25)
                CommonAnimation.PlayEffectId(35)
                self.mRunLabel = false
            else
                self.index = self.index + 1
                --self.mLabel:setString(self.tableText[self.index])
                richTextCreateWithFont(self.mLabel,self.tableText[self.index] , true,25)
                if self.index%2 == 1 then
                    CommonAnimation.PlayEffectId(35)
                end
            end
        end
        local headfun = cc.CallFunc:create(doSomthing1)
        local DelayTime = cc.DelayTime:create(self.CGPlaySpeed)
        self.mLabel:runAction(cc.RepeatForever:create(cc.Sequence:create(headfun, DelayTime)))

    end
    self.layer:setEnabled(true)
end

--对象开关
function StoryCGManager:Object(id,Param1,Param2,Param3)
    -- 主角ID暂时
    if Param1 == 0 then
         if id == -1 then
           local _id = globaldata:getBattleFormationInfoByIndexAndKey(1, "id")
           local role = FightSystem.mRoleManager:LoadCGFriendRoles(_id,cc.p(Param2,Param3))
            table.insert(self.mCGListFriend,_id)
         elseif id == 0 then
            local _id = globaldata.registerHeroId
           local role = FightSystem.mRoleManager:LoadCGFriendRoles(_id,cc.p(Param2,Param3))
            table.insert(self.mCGListFriend,_id)
         else
            local role = FightSystem.mRoleManager:LoadCGEnemyRoles(id,cc.p(Param2,Param3))
            table.insert(self.mCGListMonster,id)
         end
    else
        if id == -1 then
            local _id = globaldata:getBattleFormationInfoByIndexAndKey(1, "id")
            local function doSomething()
                FightSystem.mRoleManager:RemoveCGRoleByIdx("friend",_id)
            end
             nextTick(doSomething)
        elseif id == 0 then
             local _id = globaldata.registerHeroId
            local function doSomething()
                FightSystem.mRoleManager:RemoveCGRoleByIdx("friend",_id)
            end
             nextTick(doSomething)
        else
            local function doSomething()
                FightSystem.mRoleManager:RemoveCGRoleByIdx("monster",id)
            end
            nextTick(doSomething)
        end
    end
    self:StageCG()
end

--屏幕效果
function StoryCGManager:ScreenEffect(id,Param1,Param2,Param3)
    --FightSystem.mSceneManager.mCamera:Zoomin()
    if Param1 == 1 then
        shakeNode(GUISystem.Windows["FightWindow"].mRootNode,10,0.5)
    elseif Param1 == 2 then
        FightSystem.mSceneManager.mCamera:Zoomin(0,0)
    end
    self:StageCG()
end

--镜头焦点
function StoryCGManager:Focus(id,Param1,Param2,Param3)
    self.mFocusId = id
    if FightSystem.mRoleManager:GetKeyRole() then
        FightSystem.mRoleManager:GetKeyRole().mIsCGKeyRole = false
    end
    local role = self:FindCGRoleById(id)
    if role then
        role.mIsCGKeyRole = true
    end
    FightSystem.mSceneManager.mCamera:ChangeRole(role:getShadowPos(),true)

    local function CallbackFocus()
        if not Param1 then return end
        self:StageCG()
    end

    local actionTo1 = cc.DelayTime:create(FightConfig.CAMERA_SPEED + 0.1)
    local call = cc.CallFunc:create(CallbackFocus)
    self.mRootNode:runAction(cc.Sequence:create(actionTo1,call))
end

--亮相
function StoryCGManager:MakePose(id,Param1,Param2,Param3)
    if self.mFocusId ~= id then
        self:Focus(id,false)
    end
    FightSystem.mRoleManager:StopEachSpineTickForCg(true)
    local pos = nil
    if Param1 == 1 then
        --字左人右
         pos = cc.p(getGoldFightPosition_Middle().x-150,getGoldFightPosition_RU().y-470)
         FightSystem.mSceneManager.mCamera:ZoominPose(-500,0)
    else
         pos = cc.p(getGoldFightPosition_Middle().x+150,getGoldFightPosition_RU().y-470)
         FightSystem.mSceneManager.mCamera:ZoominPose(500,0)
    end
    self.PosePos:setPosition(cc.p(pos.x-150,pos.y+370))

    if FightSystem.mRoleManager:GetKeyRole() then
        self.Posetext1 = FightSystem.mRoleManager:GetKeyRole().mName
        self.Posetext2 = getDictionaryText(FightSystem.mRoleManager:GetKeyRole().mRoleData.mInfoDB.Title)
        self.Posetext3 = getDictionaryText(Param2)

        self.tablePoseText1 = splitChineseString(self.Posetext1)
        self.tablePoseText2 = splitChineseString(self.Posetext2)
        self.tablePoseText3 = splitChineseString(self.Posetext3)

        self.LabelPose1= self.PosePos:getChildByName("Label_Name_Stroke")
        self.LabelPose2= self.PosePos:getChildByName("Label_Nickname_Stroke")
        self.LabelPose3= self.PosePos:getChildByName("Label_Describe")
        self.LabelPose1:setVisible(false)
        self.LabelPose2:setVisible(false)
        self.LabelPose3:setVisible(false)

        CommonAnimation.PlayEffectId(35)
    end

    local scheduler = cc.Director:getInstance():getScheduler()
    local index = 0
    local row = 1
    local staytime = 0
    local function CallbackZoom()
        self.mSpinePose:setVisible(false)
        FightSystem.mRoleManager:StopEachSpineTickForCg(false)
        self:StageCG()
    end


   local function doShowPoseText()
        if staytime > 0 then
            staytime = staytime - 1
            if staytime == 0 and row == 4 then
                --退出
                self.LabelPose1:setVisible(false)
                self.LabelPose2:setVisible(false)
                self.LabelPose3:setVisible(false)
                scheduler:unscheduleScriptEntry(self.Posescheduler)
                FightSystem.mSceneManager.mCamera:ZoominPoseback(0.1)

                local actionTo1 = cc.DelayTime:create(0.15)
                local call = cc.CallFunc:create(CallbackZoom)
                self.mRootNode:runAction(cc.Sequence:create(actionTo1,call))
            end
            return
        end

        if row == 1 then
            if index == #self.tablePoseText1 then
                self.LabelPose1:setVisible(true)
                self.LabelPose1:setString( self.Posetext1 )
                row = 2
                index = 0
                staytime = 10
            else
                index = index + 1
                self.LabelPose1:setVisible(true)
                self.LabelPose1:setString(self.tablePoseText1[index])
            end
        elseif row == 2 then
            if index == #self.tablePoseText2 then
                self.LabelPose2:setVisible(true)
                self.LabelPose2:setString( self.Posetext2 )
                row = 3
                index = 0
                staytime = 10
            else
                index = index + 1
                self.LabelPose2:setVisible(true)
                self.LabelPose2:setString(self.tablePoseText2[index])
            end
        elseif row == 3 then
            if index == #self.tablePoseText3 then
                self.LabelPose3:setVisible(true)
                self.LabelPose3:setString( self.Posetext3 )
                row = 4
                staytime = 20
            else
                index = index + 1
                self.LabelPose3:setVisible(true)
                self.LabelPose3:setString(self.tablePoseText3[index])
            end
        end
   end

    self.mSpinePose:setPosition(cc.p(pos.x,pos.y))
    self.mSpinePose:setVisible(true)
    local function onAnimationEvent(event)
        if event.type == 'end' and event.animation == "start" then
             self.Posescheduler = scheduler:scheduleScriptFunc(doShowPoseText, 0.05, false)
        end
    end
    self.mSpinePose:setAnimation(0,"start",false)
    self.mSpinePose:registerSpineEventHandler(onAnimationEvent, 1)

end

--播放图片
function StoryCGManager:PlayPicture(id,Param1,Param2,Param3)
    local  function CallShow()
           self.shade:getChildByName("Panel_Cg_shade"):setTouchEnabled(true)
           self.jixu:setVisible(true)

    end 
    local function FinishShade()
        self.pic:setVisible(true)
        self.pic:setScale(0)
        local pic_actionTo = cc.ScaleTo:create(1, 1.0, 1.0)
        local pic_call = cc.CallFunc:create(CallShow)
        local pic_action = cc.Sequence:create(pic_actionTo,pic_call)
        self.pic:runAction(pic_action)
    end
    local Widget = GUIWidgetPool:createWidget("CGpicture")
    self.shade = Widget:getChildByName("Panel_Cg_shade"):clone()
    local next = self.shade:getChildByName("Panel_Cg_shade")
    next:setTouchEnabled(false)
    
    self.jixu = Widget:getChildByName("Image_Jixu"):clone()
    self.jixu:setVisible(false)
    registerWidgetReleaseUpEvent(next,handler(self,self.ClosePicture))
    self.pic = Widget:getChildByName("Image_Cg_showpicture"):clone()

    self.mPicRoot = cc.Node:create()
    
    self.mRootNode:addChild(self.mPicRoot)

    local notouch = Widget:getChildByName("Panel_Cg"):clone()

    self.mPicRoot:addChild(notouch)
    self.mPicRoot:addChild(self.shade)
    self.mPicRoot:addChild(self.pic)
    self.mPicRoot:addChild(self.jixu)
    

    self.mPicRoot:setPosition( getGoldFightPosition_Middle())
    local _resDB = DB_ResourceList.getDataById(Param1)
    self.pic:loadTexture(_resDB.Res_path1)
    self.pic:setVisible(false)
    self.shade:setScale(0)
    local actionTo2 = cc.ScaleTo:create(0.5, 1.0, 1.0)
    local call = cc.CallFunc:create(FinishShade)
    local action = cc.Sequence:create(actionTo2,call)
    self.shade:runAction(action)
end

--点击关闭对话框
function StoryCGManager:CloseTalk(id,Param1,Param2,Param3)
    -- local place = Param2+1
    -- if Param1 == 1 then
    --     self.mDialogTable[place]["head"]:setVisible(false)
    -- elseif Param1 == 2 then
    --     self.mDialogTable[place]["head"]:setVisible(false)
    --     if place == 1 then
    --         self.mTalkBoxLeft:setVisible(false)
    --     elseif place == 2 then
    --          self.mTalkBoxRight:setVisible(false)
    --     end
    -- end
    self.mDialogTable[1]["head"]:setVisible(false)
    self.mDialogTable[2]["head"]:setVisible(false)
    self.mTalkBoxLeft:setVisible(false)
    self.mTalkBoxRight:setVisible(false)
    self.mArrow_l:setVisible(false)
    self:StageCG()
end


--点击下一步
function StoryCGManager:ClosePicture(tag,sender)
    self.mPicRoot:removeFromParent(true)
    self:StageCG()
end

-- 当前舞台是否有对话
function StoryCGManager:IsStageTalk(data)
    for i=1,4 do
        local key = "CG_Action" .. i .. "Type"
        if data[key] == 0 then
            return false
        elseif  data[key] == 3 then
            return true
        end
    end
    return false
end

-- 隐藏当前所有对话框
function StoryCGManager:HideAllDialog()
    for i=1,2 do
        self.mDialogTable[i]["head"]:setVisible(false)
    end

end

-- 创建当前所有对话框
function StoryCGManager:CreateAllDialog()
   -- local Widget1 = GUIWidgetPool:createWidget("CGShade")
    local WidgetTalk = GUIWidgetPool:createWidget("CGTalkText")
    self.mTalkBoxLeft = WidgetTalk:getChildByName("Image_Talk_BoxLeft")
    self.mArrow_l = WidgetTalk:getChildByName("Panel_Arrow") 
    local _resDB = DB_ResourceList.getDataById(612)

    local animNode = AnimManager:createAnimNode(8022)
    self.mArrow_l:addChild(animNode:getRootNode(), 100)
    animNode:play("cg_arrow_next", true)

    self.mTalkBoxRight = WidgetTalk:getChildByName("Image_Talk_BoxRight")
   
    for i=1,2 do
        local  head = nil
        local point = nil
        local labeltalk = nil
        local labelname = nil
        if i == 1 then
            --point =  cc.p(getGoldFightPosition_LD().x+130,getGoldFightPosition_LD().y-200)
            labeltalk = self.mTalkBoxLeft:getChildByName("Label_CG_Talk")
            labelname = self.mTalkBoxLeft:getChildByName("Label_Name")
            head = WidgetTalk:getChildByName("Panel_Main_Left"):getChildByName("Image_CG_HalfHead")
            head:setVisible(false)
        elseif i == 2 then
            --point =  cc.p(getGoldFightPosition_RD().x-130,getGoldFightPosition_RD().y-200)
            labeltalk = self.mTalkBoxRight:getChildByName("Label_CG_Talk")
            labelname = self.mTalkBoxRight:getChildByName("Label_Name")
            head = WidgetTalk:getChildByName("Panel_Main_Right"):getChildByName("Image_CG_HalfHead")
            head:setVisible(false)
        end
        self.mDialogTable[i] = {["head"] = head,["labeltalk"] = labeltalk,["labelname"] = labelname}
        --head:setPosition(point)
    end
    self.CurHeadpos1 = cc.p(self.mDialogTable[1]["head"]:getPositionX()-150,self.mDialogTable[1]["head"]:getPositionY())
    self.CurHeadpos2 = cc.p(self.mDialogTable[2]["head"]:getPositionX()+150,self.mDialogTable[2]["head"]:getPositionY())

    self.mDialogTable[1]["head"]:setPosition(self.CurHeadpos1)
    self.mDialogTable[2]["head"]:setPosition(self.CurHeadpos2)

    self.mRootNode:addChild(WidgetTalk)
    --WidgetTalk:setPosition(cc.p(getGoldFightPosition_Middle().x,getGoldFightPosition_LD().y))
    local function doSomething()
        WidgetTalk:getChildByName("Panel_Main_Left"):setPosition(getGoldFightPosition_LD())
        WidgetTalk:getChildByName("Panel_Main_Right"):setPosition(getGoldFightPosition_RD())
        WidgetTalk:getChildByName("Panel_Next"):setPosition(getGoldFightPosition_RD())
    end 
    doSomething()
    self.Tiaobtn = WidgetTalk:getChildByName("Button_CG_tiaoguo")
    registerWidgetReleaseUpEvent(self.Tiaobtn,handler(self,self.OnTiaoguoClickEvent))
   
     self.Tiaobtn:setPosition(getGoldFightPosition_LU().x +100,getGoldFightPosition_LU().y-50)
     self.Tiaobtn:setVisible(false)

    self.layer = WidgetTalk:getChildByName("Panel_Shade_layer")
    registerWidgetReleaseUpEvent(self.layer,handler(self,self.TouchEventTalk))
    self.layer:setEnabled(false)
end

function StoryCGManager:CreatePose()
    local panel = GUIWidgetPool:createWidget("PoseText")
    self.PosePos = panel:getChildByName("Panel_Pos"):clone()
    self.mRootNode:addChild(self.PosePos,100)

    self.mSpinePose = CommonAnimation.createSpine_commonByResID(883)
    self.mRootNode:addChild(self.mSpinePose,99)
    self.mSpinePose:setVisible(false)
end


function StoryCGManager:OnTiaoguoClickEvent()
    self.Tiaobtn:setVisible(false)
    FightSystem.mSceneManager.mCamera:TiaoguoPoseback()
    self:EndedStageCG()
end

--对话点击
function StoryCGManager:TouchEventTalk()
    --
    if self.mRunLabel then
        self.mLabel:stopAllActions()
        richTextCreateWithFont(self.mLabel,self.Strtext , true,25)
        self.mRunLabel = false
        self:StopTalkAction(self.Curplace)
    else
        self.layer:setEnabled(false)
        self:StageCG()
    end
end

function StoryCGManager:StopTalkAction(index)
    local head1 = self.mDialogTable[1]["head"]
    local head2 = self.mDialogTable[2]["head"]
    if index == 1 then
        self.mTalkBoxLeft:stopAllActions()
        self.mTalkBoxRight:stopAllActions()
        head1:stopAllActions()
        head2:stopAllActions()
        self.mTalkBoxLeft:setVisible(true)
        self.mTalkBoxRight:setVisible(false)
        head1:setVisible(true)
        head1:setOpacity(255)
        head2:setVisible(false)
        self.mTalkBoxLeft:setOpacity(255)
        self.mTalkBoxRight:setOpacity(255)
        head1:setPosition(self.CurHeadpos1)
    elseif index == 2 then
        self.mTalkBoxLeft:stopAllActions()
        self.mTalkBoxRight:stopAllActions()
        head1:stopAllActions()
        head2:stopAllActions()
        self.mTalkBoxLeft:setVisible(false)
        self.mTalkBoxRight:setVisible(true)
        head1:setVisible(false)
        head2:setVisible(true)
        head2:setOpacity(255)
        self.mTalkBoxLeft:setOpacity(255)
        self.mTalkBoxRight:setOpacity(255)
        head2:setPosition(self.CurHeadpos2)
    end
end

-- 删掉对话框
function StoryCGManager:RemoveAllDialog()
    for i=1,2 do
        self.mDialogTable[i]["labeltalk"]:stopAllActions()
        self.mDialogTable[i]["head"]:setVisible(false)
    end
end

function StoryCGManager:RemoveCGAll()
    self.mRootNode:stopAllActions()
     for k,v in pairs(self.mCGListMonster) do
        FightSystem.mRoleManager:RemoveCGRoleByIdx("monster",v)
     end
     for k,v in pairs(self.mCGListFriend) do
        FightSystem.mRoleManager:RemoveCGRoleByIdx("friend",v)
     end     
end


--[[
	video事件回调
]]
function StoryCGManager:onVideoEventCallback(sener, eventType)
    if eventType == ccexp.VideoPlayerEvent.PLAYING then
        
    elseif eventType == ccexp.VideoPlayerEvent.PAUSED then
        
    elseif eventType == ccexp.VideoPlayerEvent.STOPPED then
        
    elseif eventType == ccexp.VideoPlayerEvent.COMPLETED then
        
    end
end


return StoryCGManager.new()