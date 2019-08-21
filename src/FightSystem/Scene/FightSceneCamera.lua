-- Name: FightSceneCamera
-- Func: 战斗场景摄像机
-- Author: lvyunlong

require "FightSystem/Scene/FightSceneView"

FightSceneCamera = {}
FightSceneCamera.mSceneView = nil

function FightSceneCamera:Init()

    self.KeyRolePosition = nil

    self.CameraScreenWidth = getGoldFightScreenWidth()

    self.isChangeSpeed = false
end

function FightSceneCamera:Release()
	_G["FightSceneCamera"] = nil
  	package.loaded["FightSceneCamera"] = nil
  	package.loaded["FightSceneManager/Scene/FightSceneCamera"] = nil
end

function FightSceneCamera:Tick(delta)
      if self.IsStopTick then return end
      local role = FightSystem:GetKeyRole(true)
      if role and not role.mFSM:IsBeGriped() then
          if not self.KeyRolePosition then
              self:BeginCamera(role:getShadowPos(),role.IsFaceLeft)
              FightSystem:GetFightSceneView():setPositionY(math.abs(getGoldFightPosition_LD().y))
              --FightSystem:GetFightSceneView():setPosOnSceneDirectly(self.KeyRolePosition)
              return
          end
          if self.isChangeSpeed  then
              self:ChangeRole(role:getShadowPos(),role.IsFaceLeft,true)
              self.isChangeSpeed = false
          else
              self:ChangeRole(role:getShadowPos(),role.IsFaceLeft)
          end
      end 
end

function FightSceneCamera:Destroy()
    self.IsStopTick = nil
    self.KeyRolePosition = nil
end

function FightSceneCamera:setStopTick(flag)
    self.IsStopTick = flag
end

function FightSceneCamera:ChangeRole(curpos,face,typechange,runTime)
    local  mPosTiled = math.abs(FightSystem:GetFightTiledLayer():getPositionX())
    local FaceRightDis = self.CameraScreenWidth*0.618
    local FaceLeftDis = self.CameraScreenWidth*0.382

    local FaceRightDis1 = self.CameraScreenWidth*0.55
    local FaceLeftDis1 = self.CameraScreenWidth*0.45

    local CAMERASPEEDFINDMAP = FightConfig.CAMERA_SPEED_FIND
    if runTime then
      CAMERASPEEDFINDMAP = runTime
    end
    -- FaceDis = self.CameraScreenWidth / 2
    local changface = nil
    if not typechange and (self.KeyRoleFace ~= face ) then
      changface = true
    end

      if self.KeyRolePosition.y ~= curpos.y then
         local pery = curpos.y - self.KeyRolePosition.y
         local dis  = curpos.y 
         if  pery < 0 then
            --向下
             if typechange then
                if dis < FightSystem:GetFightSceneView().mScrollLine_U then 
                    self:KeyRoleRunDown(math.abs(dis - FightSystem:GetFightSceneView().mScrollLine_U),FightConfig.CAMERA_SPEED)
                end
             else
                if dis < FightSystem:GetFightSceneView().mScrollLine_U then --+ getGoldFightPosition_LD().y*2    then
                    self:KeyRoleRunDown(math.abs(pery))
                end
             end
         else
            --向上
             if typechange then
                if dis > FightSystem:GetFightSceneView().mScrollLine_D then 
                    self:KeyRoleRunUp(math.abs(dis - FightSystem:GetFightSceneView().mScrollLine_D),FightConfig.CAMERA_SPEED)
                end
             else
                 if dis > FightSystem:GetFightSceneView().mScrollLine_D then
                      self:KeyRoleRunUp(math.abs(pery))
                 end  
             end
         end
         self.KeyRolePosition.y = curpos.y
     end

    if changface then
      local dis = curpos.x - mPosTiled
      if face then
        -- 面朝左
          if dis < FaceRightDis then
            self:KeyRoleRunLayerLeft(math.abs(dis -(FaceRightDis)),FightConfig.CAMERA_SPEED)
          end
      else
        -- 面朝右
          if dis > FaceLeftDis then
              _disright = math.abs(dis -FaceLeftDis)
              self:KeyRoleRunLayerRight(_disright,FightConfig.CAMERA_SPEED)
          end
      end
      self.KeyRolePosition.x = curpos.x
      self.KeyRoleFace = face
      self.XXX = false
    else
      if self.KeyRolePosition.x ~= curpos.x  then
        self.XXX = false
        local dis = curpos.x - mPosTiled
        local per = curpos.x - self.KeyRolePosition.x
        if per < 0 then
            --人物向左走
            local _disleft = nil
            if FightSystem.mFightType == "fuben" then
                if FightSystem:GetFightManager().mHuitui_X and FightSystem:GetFightManager().mHuitui_X ~= 0 then
                    return
                end
            end
            if typechange then
                if face then
                  if dis < FaceRightDis then
                      self:KeyRoleRunLayerLeft(math.abs(dis -FaceRightDis),CAMERASPEEDFINDMAP)
                  else
                      self:KeyRoleRunLayerRight(math.abs(FaceRightDis -dis),CAMERASPEEDFINDMAP)
                  end
                else
                  if dis < FaceLeftDis then
                      self:KeyRoleRunLayerLeft(math.abs(dis -FaceLeftDis),CAMERASPEEDFINDMAP)
                  else
                      self:KeyRoleRunLayerRight(math.abs(FaceLeftDis -dis),CAMERASPEEDFINDMAP)
                  end
                end
            else
                if dis < FaceRightDis then
                  _disleft = math.abs(per)
                  if face then
                    local t = math.abs(dis -(FaceRightDis))
                    if t > _disleft then
                      _disleft = (t - _disleft)*0.08 + _disleft
                    end
                  end
                  self:KeyRoleRunLayerLeft(_disleft) 
                 end
              
            end
            self.KeyRolePosition.x = curpos.x
            self.KeyRoleFace = face
        else
            --人物向右走
            local _disright = nil
             if FightSystem.mFightType == "fuben" then
                if FightSystem:GetFightManager().mHuitui_X and FightSystem:GetFightManager().mHuitui_X ~= 0 then
                  self.KeyRolePosition.x = curpos.x
                  self.KeyRoleFace = face
                  return
                end
            end
            if typechange then
                if face then
                  if dis < FaceRightDis then
                      self:KeyRoleRunLayerLeft(math.abs(dis -FaceRightDis),CAMERASPEEDFINDMAP)
                  else
                      self:KeyRoleRunLayerRight(math.abs(FaceRightDis -dis),CAMERASPEEDFINDMAP)
                  end
                else
                  if dis < FaceLeftDis then
                      self:KeyRoleRunLayerLeft(math.abs(dis -FaceLeftDis),CAMERASPEEDFINDMAP)
                  else
                      self:KeyRoleRunLayerRight(math.abs(FaceLeftDis -dis),CAMERASPEEDFINDMAP)
                  end
                end
            else

                if dis > FaceLeftDis then
                  _disright = math.abs(per)
                  if not face then
                    local t = dis - FaceLeftDis
                    if t > _disright then
                      _disright = (t-_disright)*0.08 + _disright
                    end
                  end
                   self:KeyRoleRunLayerRight(_disright)
                end
                
            end
            self.KeyRolePosition.x = curpos.x
            self.KeyRoleFace = face         
        end    
      else
        if not self.XXX then
          --检测
           local dis = curpos.x - mPosTiled
            if face then
              -- 面朝左
                if dis < FaceRightDis then
                  self:KeyRoleRunLayerLeft(math.abs(dis -(FaceRightDis)),FightConfig.CAMERA_SPEED_STOP)
                end
            else
              -- 面朝右
                if dis > FaceLeftDis then
                    _disright = math.abs(dis -FaceLeftDis)
                    self:KeyRoleRunLayerRight(_disright,FightConfig.CAMERA_SPEED_STOP)
                end
            end
            self.KeyRolePosition.x = curpos.x
            self.KeyRoleFace = face
            self.XXX = true
        end

      end
    end
end

function FightSceneCamera:BeginCamera(_pos,face)
    self.KeyRolePosition = _pos
    self.KeyRoleFace = face
    FightSystem:GetFightSceneView():setPosOnSceneDirectly(_pos.x)

    local  mPosTiled = math.abs(FightSystem:GetFightTiledLayer():getPositionX())

    local dis = _pos.x - mPosTiled
    local FaceRightDis = self.CameraScreenWidth*0.618
    local FaceLeftDis = self.CameraScreenWidth*0.382
     if dis > self.CameraScreenWidth / 2 then
        self:KeyRoleRunLayerRight(math.abs(dis -(self.CameraScreenWidth / 2)))
    elseif dis < self.CameraScreenWidth / 2 then
        self:KeyRoleRunLayerLeft(math.abs(dis -(self.CameraScreenWidth / 2)))
    end
    self.KeyRoleFace = face
      --[[
    if dis > self.CameraScreenWidth / 2 then
        self:KeyRoleRunLayerRight(math.abs(dis -(self.CameraScreenWidth / 2)))
    elseif dis < self.CameraScreenWidth / 2 then
        self:KeyRoleRunLayerLeft(math.abs(dis -(self.CameraScreenWidth / 2)))
    end
    ]]
end

function FightSceneCamera:BeginCameraForFight(_pos,face)

    self.KeyRolePosition = _pos
    self.KeyRoleFace = face
      --[[
    if dis > self.CameraScreenWidth / 2 then
        self:KeyRoleRunLayerRight(math.abs(dis -(self.CameraScreenWidth / 2)))
    elseif dis < self.CameraScreenWidth / 2 then
        self:KeyRoleRunLayerLeft(math.abs(dis -(self.CameraScreenWidth / 2)))
    end
    ]]
end

function FightSceneCamera:KeyRoleRunLayerLeft(_disX,time)
    local dis = _disX
    local LEFTLine = 0
    if StorySystem.mCGManager.mCGRuning then
        LEFTLine = 0
    elseif FightSystem:isInCityHall() then
        LEFTLine = 0
    elseif FightSystem.mFightType == "arena" then
        LEFTLine = 0
    elseif FightSystem.mFightType == "olpvp" then
        LEFTLine = 0
    else
        LEFTLine = FightSystem.mFubenManager:GetLeftCameraLineX()
    end

    local  mPosTiled = math.abs(FightSystem:GetFightTiledLayer():getPositionX())

    if mPosTiled <=  LEFTLine then
      return
    end
    if  math.abs(FightSystem:GetFightTiledLayer():getPositionX()) - _disX <= LEFTLine then
        dis = math.abs( LEFTLine - mPosTiled)
    end 
    FightSystem:GetFightSceneView():MoveAllLayersRight(dis,time)
end

function FightSceneCamera:KeyRoleRunLayerRight(_disX,time)
      local dis = _disX
      local RIGHTLine = 0
      if StorySystem.mCGManager.mCGRuning then
          RIGHTLine = FightSystem.mFubenManager.mRightMAXLineX
      elseif FightSystem:isInCityHall() then
          RIGHTLine = FightSystem:GetFightTiledLayer().mCameraMaxOffX
      elseif FightSystem.mFightType == "arena" then
          RIGHTLine = FightSystem:GetFightTiledLayer().mCameraMaxOffX
      elseif FightSystem.mFightType == "olpvp" then
           RIGHTLine = FightSystem:GetFightTiledLayer().mCameraMaxOffX
      else
         if FightSystem:GetFightTiledLayer().mCameraMaxOffX <= FightSystem.mFubenManager.mRightLineX then
           RIGHTLine = FightSystem:GetFightTiledLayer().mCameraMaxOffX
         else
           RIGHTLine = FightSystem.mFubenManager:GetRightCameraLineX()
         end
      end

      local  mPosTiled = math.abs(FightSystem:GetFightTiledLayer():getPositionX())
      if mPosTiled + self.CameraScreenWidth  >=  RIGHTLine then
        return
      end
      if  _disX + mPosTiled + self.CameraScreenWidth >= RIGHTLine then
          dis = math.abs( RIGHTLine - mPosTiled- self.CameraScreenWidth)
      end
      FightSystem:GetFightSceneView():MoveAllLayersLeft(dis,time)
end

function FightSceneCamera:KeyRoleRunDown(_disY,time)
      local dis = _disY
      if FightSystem:GetFightSceneView():getPositionY() + dis > getGoldFightPosition_LD().y then
          dis = getGoldFightPosition_LD().y
      else
          dis = dis + FightSystem:GetFightSceneView():getPositionY()
      end
      local yyy = dis - FightSystem:GetFightSceneView():getPositionY()
      FightSystem:GetFightSceneView():MoveAllLayersVer(dis)
      FightSystem:GetFightSceneView():setSyncmSunshine(dis)
end

function FightSceneCamera:KeyRoleRunUp(_disY,time)
      local dis = _disY
      if FightSystem:GetFightSceneView():getPositionY() - dis < -getGoldFightPosition_LD().y then
          dis = -getGoldFightPosition_LD().y
      else
          dis = -dis + FightSystem:GetFightSceneView():getPositionY()
      end
      local yyy = dis - FightSystem:GetFightSceneView():getPositionY()
      FightSystem:GetFightSceneView():MoveAllLayersVer(dis)
      FightSystem:GetFightSceneView():setSyncmSunshine(dis)
end

function FightSceneCamera:UpdateCameraForKeyRole(cur,face)
    self:ChangeRole(cur,face,true)
end 

function FightSceneCamera:UpdateCameraForOLPvp(cur,face,time)
    if not time then
      time = 0.05
    end
    self:ChangeRole(cur,face,true,time)
end 


function FightSceneCamera:GetFriendRoleXMinAndMax()
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

function FightSceneCamera:IsRoleMaxRight(Role)
    for k,v in pairs(FightSystem.mRoleManager.mFriendRoles) do
          if v ~= Role then
             if  Role:getPositionX() < v:getPositionX() then
                  return false
             end
          end
     end 
     return true
end

function FightSceneCamera:IsRoleMaxLeft(Role)
    for k,v in pairs(FightSystem.mRoleManager.mFriendRoles) do
          if v ~= Role then
             if  Role:getPositionX() > v:getPositionX() then
                  return false
             end
          end
     end 
     return true
end

function FightSceneCamera:Zoomin(_x,_y,_delaytime)
    -- cclog("Width ==" .. FightSystem:GetFightSceneView():getContentSize().width)
    -- cclog("Height ==" .. FightSystem:GetFightSceneView():getContentSize().height)

    local height = getGoldFightPosition_LU().y - getGoldFightPosition_LD().y
    self.isZoomin = true
    local fightview = FightSystem:GetFightSceneView()
    fightview:setContentSize(cc.size(1140,770))
    local role = FightSystem:GetKeyRole(true)
    if not role then return end

    -- cclog("YYY ==" .. FightSystem:GetFightSceneView():getPositionY())

    -- cclog("XXXXXXXXXX==" .. FightSystem:GetFightTiledLayer():getPositionX()) 

    local xPiont = math.abs( (role:getShadowPos().x + _x )- math.abs(FightSystem:GetFightTiledLayer():getPositionX())) 

    local yy =  math.abs(getGoldFightPosition_LD().y) - fightview:getPositionY()

    local yPiont = (role:getShadowPos().y + _y)  - yy

    -- cclog("yPiont==" .. yPiont)

    self.mXX = fightview:getPositionX()
    self.mYY = fightview:getPositionY()

    -- cclog("mXX==" .. self.mXX)

    -- cclog("mYY==" .. self.mYY)

    fightview:setAnchorPoint(cc.p(xPiont/1140,(role:getShadowPos().y+_y)/770))

    fightview:setPositionY((role:getShadowPos().y+_y)+self.mYY)

    fightview:setPositionX(xPiont)

    local function CallBack()
        fightview:setPositionX(self.mXX)
        fightview:setPositionY(self.mYY)
        fightview:setAnchorPoint(0,0)
        fightview:setContentSize(cc.size(0,0))
        self.isZoomin = false
    end

    local actionTo =  cc.ScaleTo:create(0.1, 2,2)
    local time = 2
    if _delaytime then
      time = _delaytime
    end
    local actionTo1 = cc.DelayTime:create(time)
    local actionTo2 = cc.ScaleTo:create(0.1, 1.0,1.0)
    local call = cc.CallFunc:create(CallBack)

    fightview:runAction(cc.Sequence:create(actionTo ,actionTo1,actionTo2, call))
end

function FightSceneCamera:ZoominPose(_x,_y,_delaytime,call)
    -- cclog("Width ==" .. FightSystem:GetFightSceneView():getContentSize().width)
    -- cclog("Height ==" .. FightSystem:GetFightSceneView():getContentSize().height)

    local height = getGoldFightPosition_LU().y - getGoldFightPosition_LD().y

    self.isZoomin = true

    local fightview = FightSystem:GetFightSceneView()

    fightview:setContentSize(cc.size(1140,770))

    local role = FightSystem:GetKeyRole(true)
    if not role then return end

    -- cclog("YYY ==" .. FightSystem:GetFightSceneView():getPositionY())

    -- cclog("XXXXXXXXXX==" .. FightSystem:GetFightTiledLayer():getPositionX()) 

    local xPiont = math.abs( (role:getPositionX() + _x )- math.abs(FightSystem:GetFightTiledLayer():getPositionX())) 

    local yy =  math.abs(getGoldFightPosition_LD().y) - fightview:getPositionY()

    local yPiont = (role:getPositionY() + _y)  - yy

    -- cclog("yPiont==" .. yPiont)

    self.mXX = fightview:getPositionX()
    self.mYY = fightview:getPositionY()

    -- cclog("mXX==" .. self.mXX)

    -- cclog("mYY==" .. self.mYY)

    fightview:setAnchorPoint(cc.p(xPiont/1140,(role:getPositionY()+_y)/770))

    fightview:setPositionY((role:getPositionY()+_y)+self.mYY)

    fightview:setPositionX(xPiont)
    local actionTo =  cc.ScaleTo:create(0.1, 1.3,1.3)
    local tablelist = {}

    if _delaytime then
        local actionTo1 = cc.DelayTime:create(_delaytime)
        if call then
          local actionTo2 = cc.CallFunc:create(call)
          tablelist = {actionTo1,actionTo,actionTo2}
        else
          tablelist = {actionTo1,actionTo}
        end
    else
        if call then
          local actionTo2 = cc.CallFunc:create(call)
          tablelist = {actionTo,actionTo2}
        else
          tablelist = {actionTo}
        end
    end
    fightview:runAction(cc.Sequence:create(tablelist))
end

function FightSceneCamera:NoKeyZoominPose(_x,_y,_delaytime)
    --  cclog("Width ==" .. FightSystem:GetFightSceneView():getContentSize().width)
    -- cclog("Height ==" .. FightSystem:GetFightSceneView():getContentSize().height)

    local height = getGoldFightPosition_LU().y - getGoldFightPosition_LD().y

    local fightview = FightSystem:GetFightSceneView()

    fightview:setContentSize(cc.size(1140,770))

    -- cclog("YYY ==" .. FightSystem:GetFightSceneView():getPositionY())

    -- cclog("XXXXXXXXXX==" .. FightSystem:GetFightTiledLayer():getPositionX()) 

    local xPiont = math.abs( (_x )- math.abs(FightSystem:GetFightTiledLayer():getPositionX())) 

    local yy =  math.abs(getGoldFightPosition_LD().y) - fightview:getPositionY()

    local yPiont = (_y)  - yy

    -- cclog("yPiont==" .. yPiont)

    self.mXX = fightview:getPositionX()
    self.mYY = fightview:getPositionY()

    -- cclog("mXX==" .. self.mXX)

    -- cclog("mYY==" .. self.mYY)

    fightview:setAnchorPoint(cc.p(xPiont/1140,(_y)/770))

    fightview:setPositionY((_y)+self.mYY)

    fightview:setPositionX(xPiont)

    local function CallBack()
        fightview:setPositionX(self.mXX)
        fightview:setPositionY(self.mYY)
        fightview:setAnchorPoint(0,0)
        fightview:setContentSize(cc.size(0,0))
        self.isZoomin = false
    end

    local actionTo =  cc.ScaleTo:create(0.1, 2,2)
    local actionTo1 = cc.DelayTime:create(2)
    local actionTo2 = cc.ScaleTo:create(0.1, 1.0,1.0)
    local call = cc.CallFunc:create(CallBack)

    fightview:runAction(cc.Sequence:create(actionTo ,actionTo1,actionTo2, call))
end


function FightSceneCamera:ZoominPoseback(time)
    local function CallBack()
        FightSystem:GetFightSceneView():setPositionX(self.mXX)
        FightSystem:GetFightSceneView():setPositionY(self.mYY)
        FightSystem:GetFightSceneView():setAnchorPoint(0,0)
        FightSystem:GetFightSceneView():setContentSize(cc.size(0,0))
        self.isZoomin = false
    end
    local actionTo = cc.ScaleTo:create(time, 1.0,1.0)
    local call = cc.CallFunc:create(CallBack)
    FightSystem:GetFightSceneView():runAction(cc.Sequence:create(actionTo, call))
end

function FightSceneCamera:TiaoguoPoseback()
  if self.isZoomin then
    local fightview = FightSystem:GetFightSceneView()
    fightview:stopAllActions()
    fightview:setScaleX(1)
    fightview:setScaleY(1)
    fightview:setPositionX(self.mXX)
    fightview:setPositionY(self.mYY)
    fightview:setAnchorPoint(0,0)
    fightview:setContentSize(cc.size(0,0))
    self.isZoomin = false
  end
end


return FightSceneCamera