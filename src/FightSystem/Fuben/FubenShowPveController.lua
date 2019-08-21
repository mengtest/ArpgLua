
FubenShowPveController = class("FubenShowPveController")

function FubenShowPveController:ctor()
    self.mCurEventIndex = 1
    self.mShowPveEventList = {
      {0.5,"Step1001"},
      {2.8,"Step1011"},
      {2,"Step1012"},
      {2,"Step1013"},
      {2,"Step1014"},
      {2.5,"Step1015"},
      {0.5,"Step1016"},
      {1.5,"Step1017"},
      {2,"Step1018"},
      -- {3,"Step1101"},
      -- {3,"Step1201"},
      -- {3,"Step1301"},
      -- {3,"Step1401"},
      -- {3,"Step1501"},
      -- {1,"Step1601"},
      -- {3,"Step1701"},
      {1,"Step1801"},
      {1,"Step1802"},
      -- {0.5,"Step1901"},
      {2,"Step2001"},
      {3,"Step2002"},
      {1,"Step2101"},
      {1,"Step2201"},
      {3,"Step2301"},
      {1.5,"Step2401"},
      {3,"Step2402"},
      {5,"Step2501"},
      {0.5,"Step2601"},
      {1.5,"Step2602"},
      {1.5,"Step2701"},
      {3,"Step2801"},
      {1.5,"Step2802"},
      {1.5,"Step2901"},
      {1.5,"Step3001"},
      {8.5,"Step3101"},
      {1.5,"Step3301"},
      {1.5,"Step3401"},
      {1.5,"Step3402"},
      {1,"Step3403"},
      {1,"Step3404"},
      {2,"Step3501"},
      {1.5,"Step3502"},
      {1.5,"Step3503"},
      {2,"Step3601"},
      {7.5,"Step3701"},
      {3,"Step3801"},
      {10,"Step3901"},
    }
    self.mCurShowPveTime = 0
    self.mCurShowTotleTime = 0
end

function FubenShowPveController:InitRoles()
     self.mFRole1 = FightSystem.mRoleManager:GetFriendTable()[1]
     self.mFRole2 = FightSystem.mRoleManager:GetFriendTable()[2]
     self.mFRole3 = FightSystem.mRoleManager:GetFriendTable()[3]

     self.mERole1 = FightSystem.mRoleManager:GetEnemyTable()[1]
     self.mERole2 = FightSystem.mRoleManager:GetEnemyTable()[2]
     self.mERole3 = FightSystem.mRoleManager:GetEnemyTable()[3]

     self.mFRole1.mPropertyCon.mMaxHP = 5000000
     self.mFRole1.mPropertyCon.mCurHP = 5000000
     self.mFRole2.mPropertyCon.mMaxHP = 5000000
     self.mFRole2.mPropertyCon.mCurHP = 5000000
     self.mFRole3.mPropertyCon.mMaxHP = 5000000
     self.mFRole3.mPropertyCon.mCurHP = 5000000

     self.mERole1.mPropertyCon.mMaxHP = 5000000
     self.mERole1.mPropertyCon.mCurHP = 5000000
     self.mERole2.mPropertyCon.mMaxHP = 5000000
     self.mERole2.mPropertyCon.mCurHP = 5000000
     self.mERole3.mPropertyCon.mMaxHP = 5000000
     self.mERole3.mPropertyCon.mCurHP = 5000000
     



     self.mFRole1.mPropertyCon.mHarm  = 99999
     self.mFRole2.mPropertyCon.mHarm  = 99999
     self.mFRole3.mPropertyCon.mHarm  = 99999

     self.mERole1.mPropertyCon.mHarm  = 99999
     self.mERole2.mPropertyCon.mHarm  = 99999
     self.mERole3.mPropertyCon.mHarm  = 99999
end

function FubenShowPveController:Tick(delta)
  if self.IsStop then return end
  self.mCurShowPveTime = self.mCurShowPveTime + 1
  if self.mShowPveEventList[self.mCurEventIndex] and (self.mCurShowTotleTime) <= self.mCurShowPveTime then
    if self[self.mShowPveEventList[self.mCurEventIndex][2]] then
      local fun = handler(self,self[self.mShowPveEventList[self.mCurEventIndex][2]])
      fun()
    end
    self.mCurShowTotleTime = self.mCurShowTotleTime + self.mShowPveEventList[self.mCurEventIndex][1]*30
    self.mCurEventIndex = self.mCurEventIndex + 1
    
  end
end

function FubenShowPveController:ShowPveOver()
    FightSystem:enableShowGuanqia(true)
    self.IsStop = true
    globaldata.showguanqialayer = true
    local function gotoCity( ... )
      GUISystem:HideAllWindow()
      local _cityid = globaldata:getCityHallData("cityid")
      FightSystem.mHallManager:OnPreEnterCity(_cityid)
    end
    GUISystem:BlackShowPvelayout(gotoCity)
end

function FubenShowPveController:Step1001()
  FightSystem.mTouchPad:ChooseRoleIndex(2,true)
  FightSystem.mSceneManager.mCamera:UpdateCameraForOLPvp(cc.p(450,200),false,0.3)
end

function FubenShowPveController:Step1011()
  self.mFRole2:WalkingByPosByShowPve(cc.p(1650,120))
  FightSystem.mSceneManager.mCamera:UpdateCameraForOLPvp(cc.p(1650,200),false,2.78)
end

--薰说话
function FubenShowPveController:Step1012()
  self.mERole2:WalkingByPosByShowPve(cc.p(1920,120))
  self.mERole2.mArmature:SpeakPao(4016,2)
end

--口罩妹说话
function FubenShowPveController:Step1013()
  self.mFRole2.mArmature:SpeakPao(4003,2)
end

--薰说话
function FubenShowPveController:Step1014()
  self.mERole2:WalkingByPosByShowPve(cc.p(1820,120))
  self.mERole2.mArmature:SpeakPao(4004,2,10)
  shakeNode(FightSystem.mSceneManager:GetSceneView(),10,0.2,2)
end

--薰攻击
function FubenShowPveController:Step1015()
  self.mERole2:PlaySkillByID(380)
  self.mERole2:PlaySkillByID(381)
  self.mERole2:PlaySkillByID(382)
end

--镜头移动，大壮出现
function FubenShowPveController:Step1016()
  self.mFRole1:ForcesetPosandShadow(cc.p(952,190))
  FightSystem.mTouchPad:ChooseRoleIndex(1,true)
  FightSystem.mSceneManager.mCamera:UpdateCameraForOLPvp(cc.p(952,200),false)
end

--大壮跑至口罩妹
function FubenShowPveController:Step1017()
  self.mFRole1:WalkingByPosByShowPve(cc.p(1600,190))
  FightSystem.mSceneManager.mCamera:UpdateCameraForOLPvp(cc.p(1600,200),false,1.5)
end

--大壮说话
function FubenShowPveController:Step1018()
  self.mFRole1.mArmature:SpeakPao(4017,2)
end

--大壮跑中间
function FubenShowPveController:Step1801()
  self.mFRole1:WalkingByPosByShowPve(cc.p(1870,120))
end

--大壮说话
function FubenShowPveController:Step1802()
  self.mFRole1.mArmature:SpeakPao(4005,2,10)
  shakeNode(FightSystem.mSceneManager:GetSceneView(),10,0.2,2)
end

--大壮嘲讽
function FubenShowPveController:Step2001()
  self.mFRole1:PlaySkillByID(566)
end

--大壮说话
function FubenShowPveController:Step2002()
  self.mFRole1.mArmature:SpeakPao(4018,2)
end

--皮衣男说话
function FubenShowPveController:Step2101()
  self.mERole1:FaceLeft()
  self.mERole2:FaceLeft()
  self.mERole3.mArmature:SpeakPao(4006,2)
end

--皮衣男移动
function FubenShowPveController:Step2201()
  self.mFRole1:WalkingByPosByShowPve(cc.p(1700,120))
  self.mERole3:WalkingByPosByShowPve(cc.p(1800,120))
end

--皮衣男放旋风腿
function FubenShowPveController:Step2301()
  self.mERole3:FaceLeft()
  self.mERole3:PlaySkillByID(360)
  self.mERole3:PlaySkillByID(361)
  self.mERole3:PlaySkillByID(362)
  self.mERole3:PlaySkillByID(373)
end

--中分大叔喊话
function FubenShowPveController:Step2401()
  self.mERole1.mArmature:SpeakPao(4019,2)
end

--中分大叔放技能
function FubenShowPveController:Step2402()
  self.mERole1:PlaySkillByID(424)
  self.mERole3:WalkingByPosByShowPve(cc.p(1960,50))
end

--皮衣男转向
function FubenShowPveController:Step2501()
  FightSystem.mSceneManager.mCamera:UpdateCameraForOLPvp(cc.p(1450,200),false,2)
  self.mERole3:FaceLeft()
end

--牧师出现
function FubenShowPveController:Step2601()
  self.mFRole3:ForcesetPosandShadow(cc.p(802,190))
  self.mFRole2:WalkingByPosByShowPve(cc.p(1500,120))
  FightSystem.mSceneManager.mCamera:UpdateCameraForOLPvp(cc.p(802,200),false)
end

--牧师跑至口罩妹
function FubenShowPveController:Step2602()
  self.mFRole3:WalkingByPosByShowPve(cc.p(1400,50))
  FightSystem.mSceneManager.mCamera:UpdateCameraForOLPvp(cc.p(1500,200),false,1.5)
end

--牧师说话
function FubenShowPveController:Step2701()
  self.mFRole3.mArmature:SpeakPao(4020,2)
end

--牧师使用治疗
function FubenShowPveController:Step2801()
  self.mFRole3:PlaySkillByID(226)
end

--双刀妹说话
function FubenShowPveController:Step2802()
  self.mERole2.mArmature:SpeakPao(4021,2)
  self.mERole2:WalkingByPosByShowPve(cc.p(1550,85))
end

--口罩妹说话
function FubenShowPveController:Step2901()
  self.mFRole2.mArmature:SpeakPao(4008,2)
end

--薰说话
function FubenShowPveController:Step3001()
  self.mERole2.mArmature:SpeakPao(4009,2,10)
  shakeNode(FightSystem.mSceneManager:GetSceneView(),10,0.2,2)
end

--薰放技能
function FubenShowPveController:Step3101()
  self.mERole2:PlaySkillByID(384)
end

--大家复位
function FubenShowPveController:Step3301()
  
  self.mFRole1.mFSM:ForceChangeToState("idea")
  self.mFRole2.mFSM:ForceChangeToState("idea")
  self.mFRole3.mFSM:ForceChangeToState("idea")

  self.mFRole1.mArmature:ActionNow("weak",true)
  self.mFRole2.mArmature:ActionNow("weak",true)
  self.mFRole3.mArmature:ActionNow("weak",true)
  self.mFRole1.mArmature:SpeakPao(4011,2)
end

--牧师说话
function FubenShowPveController:Step3401()
  self.mFRole3.mArmature:SpeakPao(4012,2)
end

--双刀妹说话
function FubenShowPveController:Step3402()
  self.mERole2.mArmature:SpeakPao(4022,2)
end

--转身准备走
function FubenShowPveController:Step3403()
  self.mERole2:WalkingByPosByShowPve(cc.p(1800,110))
end

--所有人转身
function FubenShowPveController:Step3404()
  self.mERole1:FaceRight()
  self.mERole3:FaceRight()
end

--口罩妹说话1
function FubenShowPveController:Step3501()
  FightSystem.mTouchPad:ChooseRoleIndex(2,true)
  self.mFRole2.mArmature:SpeakPao(4023,2,10)
  shakeNode(FightSystem.mSceneManager:GetSceneView(),10,0.2,2)
end

--口罩妹向前跑
function FubenShowPveController:Step3502()
  self.mERole1:FaceLeft()
  self.mERole2:FaceLeft()
  self.mERole3:FaceLeft()
  self.mERole2.mArmature:SpeakPao(4024,2)
  FightSystem.mSceneManager.mCamera:UpdateCameraForOLPvp(cc.p(1600,200),false,1)
  self.mFRole2:WalkingByPosByShowPve(cc.p(1650,110))
end

--口罩妹说话2
function FubenShowPveController:Step3503()
  self.mFRole2.mArmature:SpeakPao(4013,1.5)
end

--口罩妹说话3
function FubenShowPveController:Step3601()
  self.mFRole2.mArmature:SpeakPao(4014,2)
end

--口罩妹放大招
function FubenShowPveController:Step3701()
  self.mFRole2:PlaySkillByID(124)
  self.mERole1.mBeatCon.mFalldownCon:setNoStandUp(true)
  self.mERole2.mBeatCon.mFalldownCon:setNoStandUp(true)
  self.mERole3.mBeatCon.mFalldownCon:setNoStandUp(true)
end

--双刀妹说话
function FubenShowPveController:Step3801()
  self.mFRole2.mArmature:ActionNow("victory",false)
  self.mERole2.mArmature:SpeakPao(4015,2)
end

function FubenShowPveController:Step3901()
  self:ShowPveOver()
end














