-- Name: FightArmature
-- Func: 战斗角色的骨骼
-- Author: Johny

-- 层级关系
-- 1: spine
-- 0: 
-- -1: 技能范围提示

require "FightSystem/Role/SpineBlood"

FightArmature = class("FightArmature", function()
   return cc.Node:create()
end)

-------------------【局部变量】-------------------
-- 避免停止动作的动作名列表
local _AVOID_STOPACTION_LIST_ = {"skill1","skill2","skill3","skill4","attack1","attack2","attack3","attack4","attack5","attack6"}
--------------------------------------------------

function FightArmature:ctor(_json, _altas, _scale, _holder)
	self.mRole = _holder
  self.mRoleData = self.mRole.mRoleData
  self.mActionStartTable = {}
  self.mActionEndTable = {}
  self.mActionCustomEventTable = {}
  self.mLastAction = "none"     -- 记录上一个动作
  --
  self.mDebug_skillrange_during = 0
  self.mDebug_beat_during = 0
  self.mJumpHeight = 0
  --
 	self:Init(_json, _altas, _scale)
  self:InitHitHeigth()
  self.mNoAction = false
  -- buff 链表
  self.mBuffeffect = {}
  -- ActionNowWithSpeedScale
  self.mWithSpeedScale = 1
end

function FightArmature:InitHitHeigth()
   local function Height()
      if not self.mSpine then
        return
      end
      local h = self.mSpine:getBonePosition("hit1")
      if h then
        self.mJumpHeight = h.y
      end
    end
    local act0 = cc.DelayTime:create(1/30)
    local act1 = cc.CallFunc:create(Height)
    self:runAction(cc.Sequence:create(act0, act1))
end

function FightArmature:getPlayskillHeigth()
    local h = self.mSpine:getBonePosition("hit1")
    if h then
      local skillheight = h.y - self.mJumpHeight
      if skillheight < 0 then
        return 0
      else
        return skillheight
      end
    end
    return 0
end
     
function FightArmature:Destroy()
    self.mJumpHeight = nil
    self.mActionStartTable = nil
    self.mActionEndTable = nil
    if self.mBlood then
      self.mBlood:Destroy()
      self.mBlood = nil
    end
    self.mBuffeffect = nil
    SpineDataCacheManager:collectFightSpineByAtlas(self.mSpine)
    SpineDataCacheManager:collectFightSpineByAtlas(self.mSpineSkillEffect)
    self.mSpineSkillEffect = nil
    self:removeFromParent(true)
    self.mRole = nil
    self.mSpineSize = nil
    self.mSpine = nil
    self.mHiter = nil
    self.mNoAction = nil
    self.mWithSpeedScale = nil
end

function FightArmature:Init(_json, _atlas, _scale)
  -- blood
  if self.mRole.mGroup == "monster" or self.mRole.mGroup == "summonmonster" then
     if self.mRole.mRoleData.mInfoDB.Monster_Grade ~= 4 and self.mRole.mRoleData.mInfoDB.HideBloodShadow == 0 then
       self.mBlood = SpineBlood.new(self.mRole.mRoleData.mInfoDB.Monster_Grade)
       self.mBlood:setPosition(cc.p(0,170))
       self.mBlood:setLocalZOrder(1)
       self:addChild(self.mBlood)
     end
  elseif self.mRole.mGroup == "summonfriend" then
       self.mBlood = SpineBlood.new(self.mRole.mRoleData.mInfoDB.Monster_Grade)
       self.mBlood:setPosition(cc.p(0,170))
       self.mBlood:setLocalZOrder(1)
       self:addChild(self.mBlood)
  end

  if self.mRole.mGroup == "enemyplayer" then
    if FightSystem.mFightType == "fuben" then
     self.mBlood = SpineBlood.new(1)
     self.mBlood:setPosition(cc.p(0,170))
     self.mBlood:setLocalZOrder(1)
     self:addChild(self.mBlood)
    end
  end

  -- spine
  local IsCache = false
  if self.mRole.mGroup == "friend" then
    local DB = nil
    if not FightSystem:isInCityHall() then
      if globaldata.fashionEquipList[2] then
        local HorseKey = string.format("FashionHorseID%d",globaldata.fashionEquipList[2][2]) 
        local HorseID = DB_FashionEquip.getDataById(globaldata.fashionEquipList[2][1])[HorseKey]
        DB = DB_HorseConfig.getDataById(HorseID)
      end
    end
    if DB then
        self.mSpine,IsCache = SpineDataCacheManager:getFightSpineByAtlasWeapon(_json, _atlas, DB.ID, _scale, self)
        self.mSpine:setSkeletonRenderType(cc.RENDER_TYPE_HERO_WEAPON)
       -- local FashionWeaponIndex = DB.FashionWeaponIndex
       -- self.mSpine = CommonAnimation.createSpine_weapon(_json, _atlas, FashionWeaponIndex, _scale)
        --self:addChild(self.mSpine) 
    else
      self.mSpine,IsCache = SpineDataCacheManager:getFightSpineByatlas(_json, _atlas, _scale, self)
      self.mSpine:setSkeletonRenderType(cc.RENDER_TYPE_HERO)
    end
    
  else
    self.mSpine,IsCache = SpineDataCacheManager:getFightSpineByatlas(_json, _atlas, _scale, self)
    if self.mRole.mGroup == "enemyplayer" or self.mRole.mGroup == "cgfriend" then
        self.mSpine:setSkeletonRenderType(cc.RENDER_TYPE_HERO)
    elseif self.mRole.mGroup == "monster" then
        self.mSpine:setSkeletonRenderType(cc.RENDER_TYPE_MONSTER)
    end
  end
  -- 缓存的spine下一帧做显示处理
  if IsCache then
    self.mSpine:setVisible(false)
    local function xxx()
      if self.mSpine then
        self.mSpine:setVisible(true)
      end
    end
    local act0 = cc.DelayTime:create(1/30)
    local act1 = cc.CallFunc:create(xxx)
    self:runAction(cc.Sequence:create(act0, act1))
  end
  local EffectID = nil
  local Scale = nil
  if self.mRole.mGroup == "hallrole" then
    if self.mRoleData.mSimpleModelEffectID and self.mRoleData.mSimpleModelEffectID ~= 0 then
      EffectID = self.mRoleData.mSimpleModelEffectID
      Scale = self.mRoleData.mSimpleModelScale
    end
  else
    if self.mRoleData.mModelEffectID and self.mRoleData.mModelEffectID ~= 0 then
      EffectID = self.mRoleData.mModelEffectID
      Scale = self.mRoleData.mModelScale
    end
  end
  self.mEffectID = EffectID
  self.mEffectScale = Scale
  if self.mRole.mGroup == "cgfriend" or self.mRole.mGroup == "cgmonster" then
      self.mEffectID = nil
      self.mEffectScale = nil
  end


  self.mJson = _json
  self.mAtlas = _atlas
  self.mScale = _scale
  self.mSpine:setLocalZOrder(1)
  local function getSpineSize()
    if not self.mSpine then return end
    self.mSpineSize = cc.size(self.mSpine:getBoundingBox().width, self.mSpine:getBoundingBox().height)
    self:setPosTitle()
  end
  local act0 = cc.DelayTime:create(1/30)
  local act1 = cc.CallFunc:create(getSpineSize)
  self:runAction(cc.Sequence:create(act0, act1))


  -- self:addChild(self.mSpine)
  -- title
  self:initTitle()


  -- 注册回调
  self.mSpine:registerSpineEventHandler(handler(self, self.onAnimationEvent),0)
  self.mSpine:registerSpineEventHandler(handler(self, self.onAnimationEvent),1)
  self.mSpine:registerSpineEventHandler(handler(self, self.onAnimationEvent),2)
  self.mSpine:registerSpineEventHandler(handler(self, self.onAnimationEvent),3)


  self:DrawPoint_Beat()
end

function FightArmature:Addroot(_root)
   if self.mEffectID then
    self.mSpineSkillEffect =  CommonAnimation.createCacheSpine_commonByResID(self.mEffectID,_root)
    self.mSpineSkillEffect:setLocalZOrder(self:getLocalZOrder()+50)
    self.mSpineSkillEffect:setScaleY(self.mEffectScale)
    local _flip = 1
    if self.mRole.IsFaceLeft then
      _flip = -1
    end
    self.mSpineSkillEffect:setScaleX(_flip*self.mEffectScale)
    self.mSpineSkillEffect:setPosition(self:getPosition())
    self.mSkillOffsetTick = true
    self.mSpineSkillEffect:registerSpineEventHandler(handler(self, self.onEffectSkillEvent),1)
    self.mSpineSkillEffect:registerSpineEventHandler(handler(self, self.onEffectSkillEvent),3)
  end
  --self:ChangeScaleByPosY(self:getPositionY())
end

-- 显示或隐藏小怪血条
function FightArmature:setVisiMonsterBlood(_isvisible)
  if self.mBlood then
     self.mBlood:setVisible(_isvisible)
  end
end

-----------------------------角色头上标签-----------------------
local _TITLE_STARTY_ = 210
function FightArmature:InitCityTitle()
      -- local height =  self.mRole.mRoleData.mInfoDB.Role_Height
      -- if self.mRole.mRoleData.mModelScale then
      --   height = height*self.mRole.mRoleData.mModelScale
      -- end
      local height = _TITLE_STARTY_ - 10
      local Imagemain = GUIWidgetPool:createWidget("NewHome_PlayerTopInfo"):getChildByName("Image_Main")
      self.mViptitle = Imagemain:clone()

      self:addChild(self.mViptitle,100)
      self.mViptitle:setPosition(cc.p(0, height))
end

function FightArmature:InitSpineHeight()
  if not self.mSpine then return end
  local ss = self.mSpine:getBonePosition("name")
  if ss.y ~= 0 then
    _TITLE_STARTY_ = ss.y*self.mScale
  end
end

function FightArmature:setPosTitle()
    self:InitSpineHeight()
    if FightConfig.__DEBUG_ROLE_STATUS then
    self.mName:setPositionY(_TITLE_STARTY_ )
    self.mAllian:setPositionY(_TITLE_STARTY_ )
    end
    if self.mBlood then
      self.mBlood:setPositionY(_TITLE_STARTY_)
    end
    if self.mViptitle then
      self.mViptitle:setPositionY(_TITLE_STARTY_ )
    end
    --[[
    if self._corner1 then
      self._corner1:setPositionY(_TITLE_STARTY_ )
    end
    if self._corner2 then
      self._corner2:setPositionY(_TITLE_STARTY_ )
    end
    ]]
    if self._CornerSpine then
      self._CornerSpine:setPositionY(_TITLE_STARTY_ )
    end
end

-- 初始化title
function FightArmature:initTitle()
    -- vip
    if self.mRole.mGroup == "hallrole" then
      self:InitCityTitle()
    end
    -- name
    if FightConfig.__DEBUG_ROLE_STATUS then
      local _lb = ccui.Text:create()
      _lb:setFontName("res/fonts/font_3.ttf")
      _lb:setFontSize(20)
      -- LabelManager:outline(_lb,cc.c4b(0, 0, 0, 255))
      _lb:setColor(G_COLOR_C3B.WHITE)
      _lb:setLocalZOrder(2)
      self:addChild(_lb)
      _lb:setAnchorPoint(cc.p(0.5, 0))
      _lb:setPosition(cc.p(0, _TITLE_STARTY_+30))
      self.mName = _lb
      _lb:setString(" ")
      -- allian
      local _lb1 = ccui.Text:create()
      _lb1:setFontName("res/fonts/font_3.ttf")
      _lb1:setLocalZOrder(2)
      self:addChild(_lb1)
      _lb1:setAnchorPoint(cc.p(0.5, 0))
      _lb1:setPosition(cc.p(0, _TITLE_STARTY_ +10 ))
      _lb1:setFontSize(18)
      self.mAllian = _lb1
      self.mAllian:setString(" ")
      self.mAllian:setColor(G_COLOR_C3B.BLACK)
    end
    -- LabelManager:outline(self.mAllian,G_COLOR_C4B.BLACK) 

    --self.mAllian:setVisible(false)
    -- 箭头
    if self.mRole.mGroup == "friend" then
      local num = math.fmod(self.mRole.mPosIndex,4)
      if num == 0 then
        num = 1
      end
      --[[
      self._corner1 = cc.Sprite:create(string.format("fight_p%d.png",num))
      self._corner1:setLocalZOrder(3)
      self._corner1:setPosition(cc.p(0, _TITLE_STARTY_ + 20))
      self:addChild(self._corner1)
      
      local con_sub1 = cc.Sprite:create("fight_corner_self.png")
      con_sub1:setAnchorPoint(cc.p(0.5,0.5))
      con_sub1:setPosition(cc.p(self._corner1:getBoundingBox().width/2,self._corner1:getBoundingBox().height+10))
      self._corner1:addChild(con_sub1)
      local _ac_1 = cc.MoveBy:create(0.3, cc.p(0,10))
      local _ac_2 = cc.MoveBy:create(0.3, cc.p(0,-10))
      local _ac_3 = cc.Sequence:create(_ac_1,_ac_2)
      local forever = cc.RepeatForever:create(_ac_3)
      con_sub1:runAction(forever)

      self._corner1:setVisible(false)
      -- 箭头
      self._corner2 = cc.Sprite:create(string.format("fight_p%d_1.png",num))
      self._corner2:setLocalZOrder(3)
      self._corner2:setPosition(cc.p(0, _TITLE_STARTY_ + 20))
      self:addChild(self._corner2)

      local con_sub2 = cc.Sprite:create("fight_corner_enemy.png")
      con_sub2:setAnchorPoint(cc.p(0.5,0.5))
      con_sub2:setPosition(cc.p(self._corner2:getBoundingBox().width/2,self._corner2:getBoundingBox().height+10))
      self._corner2:addChild(con_sub2)
      local _ac1_1 = cc.MoveBy:create(0.3, cc.p(0,10))
      local _ac1_2 = cc.MoveBy:create(0.3, cc.p(0,-10))
      local _ac1_3 = cc.Sequence:create(_ac1_1,_ac1_2)
      local forever1 = cc.RepeatForever:create(_ac1_3)
      con_sub2:runAction(forever1)
      self._corner2:setVisible(false)
      ]]

        self._CornerSpine =  CommonAnimation.createCacheSpine_commonByResID(8069,self)
        self._CornerSpine:setLocalZOrder(3)
        self._CornerSpine:setPosition(cc.p(0, _TITLE_STARTY_ + 20))
        local blueIndex = string.format("hero_position_blue_%d",num)
        local redIndex = string.format("hero_position_red_%d",num)
        self._CornerAction = {blueIndex,redIndex}
    end

    local function showhero()
        self.HeroID = ccui.Text:create()
        self.HeroID:setAnchorPoint(cc.p(0.5, 0.5))
        self.HeroID:setPosition(cc.p(0, _TITLE_STARTY_ + 90))
        self.HeroID:setFontSize(30)
        self.HeroID:setString(tostring(self.mRole.mRoleData.mInfoDB.ID))
        self:addChild(self.HeroID)
    end 
    local function debugAddActionName()
        local _y = _TITLE_STARTY_ + self.mAllian:getContentSize().height + self.mName:getContentSize().height
        local _lb = ccui.Text:create()
        _lb:setLocalZOrder(2)
        self:addChild(_lb)
        _lb:setAnchorPoint(cc.p(0.5, 0))
        _lb:setPosition(cc.p(0, _y))
        _lb:setFontSize(15)
        self.mDebugAction = _lb
    end
    if FightConfig.__DEBUG_ROLE_STATUS then 
       debugAddActionName()
    end
    
end

-- 获取size
function FightArmature:changeCornerByindex(index)
  if self._CornerSpine then
    self._CornerSpine:setAnimation(0,self._CornerAction[index], true)
  end
end

-- 获取size
function FightArmature:getSize()
   if self.mSpineSize then
    return self.mSpineSize
   else
    self.mSpineSize = cc.size(self.mSpine:getBoundingBox().width, self.mSpine:getBoundingBox().height)
    return self.mSpineSize
   end
end

-- 获取比例
function FightArmature:getModelScale()
   return self.mScale
end

-- 设置玩家泡泡
function FightArmature:SpeakPao(_speakid, _time, shakedis)
    if not self.mSpeakwidget then
      local widget = GUIWidgetPool:createWidget("Fight_BOSS_Say")
      self:addChild(widget,100)
      self.mSpeakwidget = widget
      if self.mRole.IsFaceLeft then
        self.mSpeakFlag = -1
        self.mSpeakwidget:getChildByName("Label_Say"):setScaleX(-1)
      else
        self.mSpeakFlag = 1
      end
    end
    self.mSpeakwidget:stopAllActions()
    if shakedis then
      local action_list = {}
      local posX = self.mSpeakwidget:getChildByName("Image_Bg"):getPositionX()
      local posY = self.mSpeakwidget:getChildByName("Image_Bg"):getPositionY()
      local leftTop     = cc.MoveTo:create(0.05, cc.p(posX-shakedis, posY+shakedis))
      local bottomLeft  = cc.MoveTo:create(0.05, cc.p(posX+shakedis, posY+shakedis))
      local bottomRight = cc.MoveTo:create(0.05, cc.p(posX-shakedis, posY-shakedis))
      local topRight    = cc.MoveTo:create(0.05, cc.p(posX+shakedis, posY-shakedis))
      local srcPos    = cc.MoveTo:create(0.05, cc.p(posX, posY))
      table.insert(action_list,leftTop)
      table.insert(action_list,bottomLeft)
      table.insert(action_list,bottomRight)
      table.insert(action_list,topRight)
      table.insert(action_list,srcPos)
      local act0 = cc.Sequence:create(action_list)
      self.mSpeakwidget:getChildByName("Image_Bg"):runAction(act0)
    end
    local descStr = getDictionaryCGText(_speakid)
    local contentSize = self.mSpeakwidget:getContentSize()
    --self.mSpeakwidget:getChildByName("Label_Say"):enableHeightFitable(true)

    --self.mSpeakwidget:getChildByName("Label_Say"):setTextAreaSize(cc.size(contentSize.width,45))

    self.mSpeakwidget:getChildByName("Label_Say"):setString(descStr)

    local contentLabelSize = self.mSpeakwidget:getChildByName("Label_Say"):getTextAreaSize()
    contentSize.height = contentLabelSize.height + 30
    contentSize.width = contentLabelSize.width + 30
    --self.mSpeakwidget:setContentSize(contentSize)
    --self.mSpeakwidget:getChildByName("Image_Bg"):setContentSize(contentSize)
    self.mSpeakwidget:setPosition(cc.p(0, _TITLE_STARTY_ - 40 ))
    if _time then
      local DelayTime = cc.DelayTime:create(_time)
      local headfun = cc.CallFunc:create(handler(self,self.HideSpeakPao))
      self.mSpeakwidget:runAction(cc.Sequence:create(DelayTime,headfun))
    end
end

function FightArmature:HideSpeakPao()
  if self.mSpeakwidget then
    self.mSpeakwidget:removeFromParent()
    self.mSpeakwidget = nil
  end
end

function FightArmature:setCityTitle(_name, _allian, _titleId)
    if self.mRole.mGroup == "hallrole" then
      self.mViptitle:getChildByName("Label_PlayerLevelName_Stroke"):setString(_name)
      if _titleId ~= 0 then
        self.mViptitle:getChildByName("Image_Title"):setVisible(true)
      else
        self.mViptitle:getChildByName("Image_Title"):setVisible(false)
      end
      if _allian == "" then
        --Panel_VIP_1
        self.mViptitle:getChildByName("Label_GuildName_Stroke"):setVisible(false)
      else
        self.mViptitle:getChildByName("Image_Title"):setPositionY(self.mViptitle:getChildByName("Image_Title"):getPositionY()+20)
        self.mViptitle:getChildByName("Label_GuildName_Stroke"):setVisible(true)
        self.mViptitle:getChildByName("Label_GuildName_Stroke"):setString(string.format("<%s>",_allian)) 
      end   
    end
end

-- 加载Vip
function FightArmature:setVipTitle(_lv)
    if self.mRole.mGroup == "hallrole" then
        local path_bg1 = string.format("vip_top_%d.png",getVipLevelBg(_lv))
        if _lv == 0 then
          self.mViptitle:getChildByName("Image_VIP"):setVisible(false)
          self.mViptitle:getChildByName("Label_VIP_Stroke"):setVisible(false)
        else
          self.mViptitle:getChildByName("Image_VIP"):setVisible(true)
          self.mViptitle:getChildByName("Label_VIP_Stroke"):setVisible(true)
          self.mViptitle:getChildByName("Image_VIP"):loadTexture(path_bg1)
          self.mViptitle:getChildByName("Label_VIP_Stroke"):setString(tostring(_lv))
        end
    end
end

-- 加载称号
function FightArmature:setTitleData(id)
    if id == 0 then
     self.mViptitle:getChildByName("Image_Title"):setVisible(false)
     return 
   end
    self.mViptitle:getChildByName("Image_Title"):setVisible(true)

    local data = DB_PlayerTitle.getDataById(id)
    if self.mRole.mGroup == "hallrole" then
        if data.DisplayMode == 1 then
          local _resDB = DB_ResourceList.getDataById(data.Picture)
          self.mViptitle:getChildByName("Image_Title"):loadTexture(_resDB.Res_path1)
          self.mViptitle:getChildByName("Image_Title"):removeAllChildren()
          --self.mViptitle:getChildByName("Panel_Title"):getChildByName("Image_Title"):setVisible(true)
        else
          local AniNode = AnimManager:createAnimNode(data.Picture)
          self.mViptitle:getChildByName("Image_Title"):loadTexture("public_nothing.png")
          self.mViptitle:getChildByName("Image_Title"):removeAllChildren()
          self.mViptitle:getChildByName("Image_Title"):addChild(AniNode:getRootNode(), 100)
          AniNode:play("player_title",true)
        end
    end
end

-- 转向title
function FightArmature:setTitleFlip(_flip)
   -- self.mName:setScaleX(_flip)
   -- self.mAllian:setScaleX(_flip)
   if self.mBlood then
    self.mBlood:setScaleX(_flip)
   end
   if self.mSpeakwidget then
    self.mSpeakwidget:setScaleX(_flip*self.mSpeakFlag)
   end
   if self.mViptitle then
    self.mViptitle:setScaleX(_flip)
   end
   if self._corner1 then
    self._corner1:setScaleX(_flip)
   end
   
   if self._corner2 then
    self._corner2:setScaleX(_flip)
   end

   if self._CornerSpine then
    self._CornerSpine:setScaleX(_flip)
   end

  if self.mSpineSkillEffect then
     self.mSpineSkillEffect:setScaleX(_flip*math.abs(self.mSpineSkillEffect:getScaleX()))
  end
  
   if FightConfig.__DEBUG_ROLE_STATUS then 
      self.mDebugAction:setScaleX(_flip)
   end
end

-- 动作不接收任何消息
function FightArmature:setNoReceiveAction(_flag)
    --self.mNoAction = _flag
end

-- 删除 buffeffect
function FightArmature:DeleteBuffect(buff)
    if self.mBuffeffect[buff] then
      self.mBuffeffect[buff] = nil
    end
end

-- 转向 buffect
function FightArmature:BuffectFlip()
  
end

-- 设置挂点光效
function FightArmature:setHangEffect(_file,_action,_time,_IsloopSkill)
    self.EffectName = _action
    if self.mEffectSpine then
      SpineDataCacheManager:collectFightSpineByAtlas(self.mEffectSpine)
      self.mEffectSpine = nil
    end
    -- 
    local effectSpinePos = self.mSpine:getBonePosition("guneffect")
    local _resDB = DB_ResourceList.getDataById(_file)
    self.mEffectSpine = CommonAnimation.createCacheSpine_commonByResID(_file, self)
    self.mEffectSpine:setScale(self.mScale)
    self.mEffectSpine:setLocalZOrder(1)
    self.mEffectSpine:setPosition(cc.p(effectSpinePos))
    self.mEffectSpine:registerSpineEventHandler(handler(self, self.onEffectAnimationEvent),0)
    self.mEffectSpine:registerSpineEventHandler(handler(self, self.onEffectAnimationEvent),1)
    self.mEffectSpine:registerSpineEventHandler(handler(self, self.onEffectAnimationEvent),2)
    self.mEffectSpine:registerSpineEventHandler(handler(self, self.onEffectAnimationEvent),3)
    local loop = false
    if _IsloopSkill then
      loop = true
    end
    self.mEffectSpine:setAnimationWithSpeedScale(0,_action, loop,_time)
end

-- 设置是否有死亡动作
function FightArmature:setHasDeadAction(_dead)
   self.mHasDeadAction = _dead
end

function FightArmature:Tick()
    self:hangPosEffect()
end

function FightArmature:hangPosEffect()
    if self.mSpine and self.mEffectSpine then
      local effectSpinePos = self.mSpine:getBonePosition("guneffect")
      self.mEffectSpine:setPosition(cc.p(effectSpinePos))
    end
    local ss = self.mSpine:getBonePosition("name")
    if ss.y ~= 0 then
     _TITLE_STARTY_ = ss.y*self.mScale
      if self.mBlood then
        self.mBlood:setPositionY(_TITLE_STARTY_)
      end
      -- if self._corner1 then
      --   self._corner1:setPositionY(_TITLE_STARTY_ )
      -- end
      -- if self._corner2 then
      --   self._corner2:setPositionY(_TITLE_STARTY_ )
      -- end
      if self._CornerSpine then
        self._CornerSpine:setPositionY(_TITLE_STARTY_ )
      end
    end
end

-- 用于外部注册指定动作完成回调
function FightArmature:RegisterActionStart(_key,_func)
    self.mActionStartTable[_key] = _func
end


-- 用于外部注册指定动作结束回调
function FightArmature:RegisterActionEnd(_key, _func)
    self.mActionEndTable[_key] = _func
end

-- 用于外部注册指定特殊事件回调
function FightArmature:RegisterActionCustomEvent(_key, _func)
    self.mActionCustomEventTable[_key] = _func
end

-- 解指定特殊事件回调
function FightArmature:UnRegisterActionCustom(_key)
    self.mActionCustomEventTable[_key] = nil
end

-- 解注册指定动作结束回调
function FightArmature:UnRegisterActionEnd(_key)
    self.mActionEndTable[_key] = nil
end

-- 死亡动作
function FightArmature:DeadAction(_hiter)
   if self.mSpine:getCurrentAniName() == "beBlowUpStand" then
      -- self:ActionNow("beBlowUpEnd")
      -- self.mRole:RemoveSelf()
   end
end

-- 当前播放的动作
function FightArmature:getCurAction()
   local _curAni = self.mSpine:getCurrentAniName()
   return _curAni
end

-- 设置当前骨骼的旋转角度
function FightArmature:setSpineRotation(_rotate)
    self.mSpine:setRotation(_rotate)
end

-- 切回初始动作
function FightArmature:setupToPose()
   self.mSpine:setToSetupPose()
end

--[[
	立刻执行动作
      参数：
           1. 动画名
           2. 是否循坏
           3. 事件名，事件回调函数 _eventTable = {event, eventCallBack}
]]
function FightArmature:ActionNow(_to, _loop, _eventTable, _forceAction ,_backplay)
    if self.mNoAction then return end
    local function needStopCurAction(_from, _to)
       if isValueInTable(_from, _AVOID_STOPACTION_LIST_) then
          --self:setupToPose()
       end
    end
    if not _loop then _loop = false end
    if self.mSpine:getCurrentAniName() == _to and _loop and not _forceAction then return end
    needStopCurAction(self.mLastAction, _to)
    self.mSpine:setTimeScale(1)
    local toAct = _to
    if _to == "stand" and (self.mRole.mGroup == "friend" or self.mRole.mGroup == "enemyplayer")then
        toAct = self.mRole.mRoleData.mInfoDB.FightStand
    end
    if _backplay then
      self.mSpine:setAnimation(0, toAct, _loop,_backplay)
    else
      self.mSpine:setAnimation(0, toAct, _loop)
    end
    self.mWithSpeedScale = 1
    self.mLastAction = _to
    -- 检测是否有自定义动作回调
    if _eventTable and #_eventTable == 2 then
       local function xxx(_action, _eventName)
          if _action == _to and _eventName == _eventTable[1] then
             _eventTable[2](_action, _eventName)
          end
       end
       self:RegisterActionCustomEvent(_eventTable[1], xxx)
    end
end

-- 执行动作但改变动画速度
function FightArmature:ActionNowWithSpeedScale(_ani, _speedScale, _loop, _eventTable)
    if self.mNoAction then return end
    local function needStopCurAction(_from, _to)
       if isValueInTable(_from, _AVOID_STOPACTION_LIST_) then
          --self:setupToPose()
       end
    end
    if not _loop then _loop = false end
    if self.mSpine:getCurrentAniName() == _ani and _loop then return end
    needStopCurAction(self.mLastAction, _to)
    self.mSpine:setTimeScale(1)
    self.mSpine:setAnimationWithSpeedScale(0, _ani, _loop, _speedScale)
    self:setWithSpeedScale(_speedScale)
    self.mLastAction = _ani
    -- 检测是否有自定义动作回调
    if _eventTable and #_eventTable == 2 then
       local function xxx(_action, _eventName)
          if _action == _to and _eventName == _eventTable[1] then
             _eventTable[2](_action, _eventName)
          end
       end
       self:RegisterActionCustomEvent(_eventTable[1], xxx)
    end
end

-- 执行技能特效改变动画速度
function FightArmature:ActionNowEffectSpeedScale(_ani, _speedScale, _loop)
    if self.mNoAction then return end
    if not self.mSpineSkillEffect then return end
    self.mSkillOffsetTick = true
    self.mSpineSkillEffect:setVisible(true)
    local function needStopCurAction(_from, _to)
       if isValueInTable(_from, _AVOID_STOPACTION_LIST_) then
          self:setupToPose()
       end
    end
    if not _loop then _loop = false end
    if self.mSpineSkillEffect:getCurrentAniName() == _ani and _loop then  return end
   -- needStopCurAction(self.mLastAction, _to)
    self.mSpineSkillEffect:setTimeScale(1)
    self.mSpineSkillEffect:setAnimationWithSpeedScale(0, _ani, _loop, _speedScale)
end

function FightArmature:setWithSpeedScale(_speedScale)
    self.mWithSpeedScale = _speedScale
end

function FightArmature:getWithSpeedScale(_speedScale)
    return self.mWithSpeedScale
end


function FightArmature:setLocalZOrder_Armature(_zorder)
    self:setLocalZOrder(_zorder)
    if self.mSpineSkillEffect and self.mSkillOffsetTick then
       self.mSpineSkillEffect:setLocalZOrder(_zorder+50)
    end
end

function FightArmature:setPosition_ArmatureX(_x)
    self:setPositionX(_x)
    if self.mSpineSkillEffect then
       self.mSpineSkillEffect:setPositionX(_x)
    end
end

function FightArmature:setPosition_ArmatureY(_y,_changescale)
    self:setPositionY(_y)
    if self.mSpineSkillEffect then
       self.mSpineSkillEffect:setPositionY(_y)
    end
end

function FightArmature:ChangeScaleByPosY(_y)
   local _scale = self.mRole:getTiledmapScaleByPosY(_y)
    self.mSpine:setScale(_scale*self.mScale)
    if self.mSpineSkillEffect then
      local Scale = 1
      if self.mSpineSkillEffect:getScaleX() < 0 then
        Scale = -1
      end
      self.mSpineSkillEffect:setScaleX(_scale*self.mEffectScale*Scale)
      self.mSpineSkillEffect:setScaleY(_scale*self.mEffectScale)
    end
end

--[[
  停止当前动画
]]
function FightArmature:StopCurrentAction()
   self.mSpine:clearTracks()
   self:setupToPose()
end

--[[
   暂停动作
]]
function FightArmature:pauseAction(_bb)
   --if self.mNoAction then return end
   --if self.mSpine:getCurrentAniName() == "beBlowUpStart" then return end
   if self.mRole.mFEM:IsFrozen() then return end
   if self.mRole.mFEM:IsImmobilized() then return end
   self.mSpine:setStopTick(_bb)
   self:pauseSkillEffect(_bb)
end

function FightArmature:pauseSkillEffect(_bb)
   if self.mSpineSkillEffect then
      self.mSpineSkillEffect:setStopTick(_bb)
   end
end

-- 清除注册动作事件回调链表
function FightArmature:clearAnimationFunlist()
    self.mActionCustomEventTable = {}
end

-- 清除注册动作完成回调链表
function FightArmature:clearAnimationEndFunlist()
   self.mActionEndTable = {}
end

-------------------------------回调--------------------------------------
--[[
	动作结束回调
]]
function FightArmature:onAnimationStart(event)
      -- cclog(string.format("[spine] %d start: %s", 
      --                 event.trackIndex,
      --                 event.animation))


      for k,v in pairs(self.mActionStartTable) do
          v(event.animation)
      end
end

function FightArmature:onAnimationEnd(event)
      -- cclog(string.format("[spine] %d end: %s", 
      --                     event.trackIndex,
      --                     event.animation))
      if self.mRole.mAI and self.mRole.IsShowTimeBorn then
        self.mRole.IsShowTimeBorn = false
        self.mRole.mAI.mActionOpen = true
        self.mRole:setInvincible(false)
        self.mRole.mArmature:setVisiMonsterBlood(true)
        self.mRole.mFSM:ChangeToState("idle")
      end

      for k,v in pairs(self.mActionEndTable) do
          v(event.animation)
      end

end

function FightArmature:onEffectAnimationEnd(event)
    if self.EffectName == event.animation then
        if self.mEffectSpine then
          SpineDataCacheManager:collectFightSpineByAtlas(self.mEffectSpine)
          self.mEffectSpine = nil
        end
    end
end

function FightArmature:DestoryEffect()
    if self.mEffectSpine then
      SpineDataCacheManager:collectFightSpineByAtlas(self.mEffectSpine)
      self.mEffectSpine = nil
    end
    if self.mSpineSkillEffect then
      self.mSpineSkillEffect:clearTracks()
      self.mSpineSkillEffect:setToSetupPose()
    end
end

function FightArmature:onCustomEvent(event)
      -- cclog(string.format("[spine] %d event: %s, %s: %d, %f, %s", 
      --                 event.trackIndex,
      --                 event.animation,
      --                 event.eventData.name,
      --                 event.eventData.intValue,
      --                 event.eventData.floatValue,
      --                 event.eventData.stringValue))

      local result = self.mRole.mSkillCon:onCustomCallBack(event)
      for k,v in pairs(self.mActionCustomEventTable) do
          v(event.animation, event.eventData.name)
      end
      if result then
        self.mRole.mSkillCon:ExecuteSkillProcess()
      end
end

function FightArmature:onAnimationEvent(event)
    if event.type == 'start' then
    	self:onAnimationStart(event)
    elseif event.type == 'end' then
    	self:onAnimationEnd(event)
    elseif event.type == 'complete' then
    elseif event.type == 'event' then
    	self:onCustomEvent(event)
    end
end

function FightArmature:onEffectAnimationEvent(event)
    if event.type == 'start' then
    elseif event.type == 'end' then
      self:onEffectAnimationEnd(event)
    elseif event.type == 'complete' then
      
    elseif event.type == 'event' then
      
    end
end

function FightArmature:onEffectSkillEvent(event)  
    if event.type == 'end' then
      self.mSkillOffsetTick = true
    elseif event.type == 'event' then
      if event.eventData.name == "offset" then
        local num = tonumber(event.eventData.intValue)
        if type(num) == "number" then
          self.mSkillOffsetTick = false
          if self.mSpineSkillEffect then
            self.mSpineSkillEffect:setLocalZOrder(self.mSpineSkillEffect:getLocalZOrder()+num)
          end
        end
      end
    end
end

--------------Debug 相关------------------------------
-- debug显示动作名
function FightArmature:debugShowActionName(_action)
   if not FightConfig.__DEBUG_ROLE_STATUS then return end
   self.mDebugAction:setString(string.format("[Action]%s", _action))
end

function FightArmature:DrawPoint_Beat()
    if not FightConfig.__DEBUG_ROLEPOINT then return end
    --
    self.mSpine:enableBeatRange(cc.p(0, 0))
end

-- 画矩形
function FightArmature:DrawRect_SkillRange1(_point1, _point2)
    if not FightConfig.__DEBUG_SKILLRANGE then return end
    --if self.mDebug_range then return end
    local _debug = quickCreate9ImageView("debug_rectangle.png", _point2.x, _point2.y)
    _debug:setAnchorPoint(cc.p(0, 0))
    _debug:setPosition(_point1)
    self:addChild(_debug)
    --
    self:DelayHideDebug(_debug)
end

-- 画椭圆
function FightArmature:DrawRect_SkillRange2(_posCenter, _a, _b)
     if not FightConfig.__DEBUG_SKILLRANGE then return end
     --if self.mDebug_range then return end
     --
    local _debug = quickCreate9ImageView("debug_circular.png", _a * 2, _b* 2)
    _debug:setPosition(_posCenter)
    self:addChild(_debug)
    --
    self:DelayHideDebug(_debug)
end

function FightArmature:DelayHideDebug(_debug)
    local function ActionCallBack( sender )
          cclog("销毁技能debug框")
          sender:removeFromParent()
          self.mDebug_range = nil
    end
    local _ac1 = cc.FadeOut:create(1)
    local _ac2 = cc.CallFunc:create(ActionCallBack)
    local _seq = cc.Sequence:create({_ac1, _ac2})
    _debug:runAction(_seq)
    self.mDebug_range = _debug
end

-- 更换插槽下的贴图
function FightArmature:setAttachmentForSlot(_slot, _att)
   self.mSpine:closeAttachment(_slot, _att)
end

-- 移除插槽下的贴图
function FightArmature:removeAttachmentForSlot(_slot)
   self.mSpine:uncloseAttachment(_slot)
end

-- 更改spine播放速率
function FightArmature:setAniSpeedScale(_scale)
   self.mSpine:setTimeScale(_scale)
end