-- Name:    SpineShadowSprite
-- Func：   Spine影子
-- Author:  Johny

SpineShadowSprite = class("SpineShadowSprite", function()
   return cc.Sprite:create()
end)

------------------------局部变量-----------------
local LEFT_SCALEY    = 0.5
local LEFT_SKEWX     = -45
local RIGHT_SCALEY   = 0.6
local RIGHT_SKEWX    = -60
local SHADOW_DEPTH   = 200          --透明度
local HORSE_SCALEY_RATE = 1.5
local BLUR_RADIUS    =  10.0
local CANVAS_INIT_SIZE_NPC        = cc.size(256,256)  --画布初始大小
local CANVAS_INIT_SIZE_ROLE       = cc.size(512,512)  --画布初始大小
local CANVAS_INIT_SIZE_HORSE      = cc.size(512,256)  --画布初始大小
local CANVAS_INIT_SIZE_SCENE      = cc.size(256,256)  --画布初始大小
local CANVAS_TYPE    = {}
CANVAS_TYPE.NPC     = 1
CANVAS_TYPE.ROLE    = 2
CANVAS_TYPE.HORSE   = 3
CANVAS_TYPE.SCENE   = 4
local CANVAS_SIZE_MAP = {}
CANVAS_SIZE_MAP[CANVAS_TYPE.NPC]    =  CANVAS_INIT_SIZE_NPC
CANVAS_SIZE_MAP[CANVAS_TYPE.ROLE]   =  CANVAS_INIT_SIZE_ROLE
CANVAS_SIZE_MAP[CANVAS_TYPE.HORSE]  =  CANVAS_INIT_SIZE_HORSE
CANVAS_SIZE_MAP[CANVAS_TYPE.SCENE]  =  CANVAS_INIT_SIZE_SCENE
--------------------------------------------------

function SpineShadowSprite:ctor()
   self.mRenderFlag = true
end

function SpineShadowSprite:init(type)
    self.mCanvasType = type
    self.IsStopTickPosX = false  -- 是否停止同步坐标X
    self.IsStopTickPosY = false  -- 是否停止同步坐标Y
    self:setAnchorPoint(0.5,0)
    self:setFlippedY(true)
    self:setColor(G_COLOR_C3B.BLACK)
    self.mCanvasSize = CANVAS_SIZE_MAP[type]
    self.mCanvas = cc.RenderTexture:create(self.mCanvasSize.width, self.mCanvasSize.height, cc.PixelFormat.RGBA4444)
    self.mCanvas:retain()
    FightSystem.mSpineShadowRenderManager:addSpineShadow(self)
    self:directionSetting()

    self.mStopDraw = false
end

-- 用于角色
function SpineShadowSprite:initWithRole(_role)
    self.mType = 1
    self.mRole = _role
    self:init(CANVAS_TYPE.ROLE)
end

-- 常用于NPC
--@_bornDirection: 1: 左  0: 右
function SpineShadowSprite:initWithSpine(_spine, _bornDirection)
    self.mType = 2
    self.mSpine = _spine
    self.mBornDirection = _bornDirection
    self:init(CANVAS_TYPE.NPC)
end

-- 用于坐骑
function SpineShadowSprite:initWithHorse(_horse)
    self.mType = 3
    self.mHorse = _horse
    self:init(CANVAS_TYPE.HORSE)
end

-- 用于场景动画
function SpineShadowSprite:initWithSceneAni(_spine, _bornDirection, _db)
    if not _db then
       doError("[ERROR] SceneViewDB is nil!!!!!!")
    end
    self.mType = 4
    self.mSpine = _spine
    self.mBornDirection = _bornDirection
    self.mSceneAni_SceneDB = _db
    self:init(CANVAS_TYPE.SCENE)
end

function SpineShadowSprite:destroy()
    if self.mHasDestroyed then return end
    self.mHasDestroyed = true
    FightSystem.mSpineShadowRenderManager:removeSpineShadow(self)
    if self.mCanvas then
      self.mCanvas:release()
      self.mCanvas = nil
    end
    self:removeFromParent(true)
end

-- 移除画布（用于进入后台）
function SpineShadowSprite:removeCanvas()
    if self:isVisible() then
        cclog("SpineShadowSprite:removeCanvas()")
        self.mCanvas:release()
        self.mCanvas = nil
        self:setVisible(false)
        self.mHasRemoveCanvas = true
    end
end

-- 重载画布（用于进入前台）
function SpineShadowSprite:reloadCanvas()
    if self.mHasRemoveCanvas then
      cclog("SpineShadowSprite:reloadCanvas()")
      local canvas_reload = CANVAS_SIZE_MAP[self.mCanvasType]
      self.mCanvas = cc.RenderTexture:create(canvas_reload.width, canvas_reload.height, cc.PixelFormat.RGBA4444)
      self.mCanvas:retain()
    end
end

-- 生成最新影子
function SpineShadowSprite:generate()
      if self.mRole and not self.mRole.mIsEnableRender then return end
      if not self.mCanvas then return end
      local _model = nil
      local size = nil
      if self.mType == 1 then
         _model = self.mRole.mArmature.mSpine
         size = _model:getBoundingBox()
      elseif self.mType == 2 or self.mType == 4 then
         _model = self.mSpine
         size = _model:getBoundingBox()
      elseif self.mType == 3 then
         _model = self.mHorse.mSpine
         size = _model:getBoundingBox()
      end
      -------
      local posx,posy = _model:getPosition()
      if size.width < 1 then
          -- doError("size.width < 1===" .. size.width)
          return
      end
      ------------创建画布，并把主体画上--------
      local _scale = _model:getScale()
      local _canvasRealW = _scale * size.width
      local _canvasRealH = _scale * size.height
      local _canvasW = self.mCanvasSize.width
      local _canvas = self.mCanvas
      _model:setPosition(_canvasW/2,0)
      _canvas:beginWithClear(0,0,0,0)
      _model:visit()
      _canvas:endToLua()
      _model:setPosition(posx,posy)
      ------------将画布载入精灵并渲染出来--------
      local _tex = _canvas:getSprite():getTexture()
      local _texSize = _tex:getContentSize()
      local _rect = cc.rect(0,0,_texSize.width, _texSize.height)
      self:setTexture(_tex)
      self:setTextureRect(_rect)
      ---
      if self.mHasRemoveCanvas then
         self:setVisible(true)
         self.mHasRemoveCanvas = false
      end
end

-- 方向设置
function SpineShadowSprite:directionSetting()
      -----------根据角色方向设置角度-----------
      local _sceneView = nil
      local _dynamicShadowConfig = nil
      if self.mType == 1 then
         _sceneView = FightSystem.mSceneManager:GetSceneView(self.mRole.mSceneIndex)
      else
         _sceneView = FightSystem.mSceneManager:GetSceneView()
      end
      local _scaleY = LEFT_SCALEY
      local _skewX = LEFT_SKEWX
      local _depth = SHADOW_DEPTH
      if _sceneView then
          local _mapDB = _sceneView.mDB
          _dynamicShadowConfig = _mapDB.DynamicShadowConfig
          if self.mType == 1 then
              if self.mRole.IsFaceLeft then
                   _scaleY = _dynamicShadowConfig[1]
                   _skewX = _dynamicShadowConfig[2]
              else
                  _scaleY = _dynamicShadowConfig[3]
                  _skewX = _dynamicShadowConfig[4]
              end
              _depth = _dynamicShadowConfig[5]
          elseif self.mType == 2 then
              if self.mBornDirection == 1 then
                 _scaleY = _dynamicShadowConfig[1]
                 _skewX = _dynamicShadowConfig[2]
              else
                 _scaleY = _dynamicShadowConfig[3]
                 _skewX = _dynamicShadowConfig[4]
              end
              _depth = _dynamicShadowConfig[5]
          elseif self.mType == 3 then
              if self.mHorse.mRole.IsFaceLeft then
                   _scaleY = _dynamicShadowConfig[1] * HORSE_SCALEY_RATE
                   _skewX = _dynamicShadowConfig[2]
              else
                  _scaleY = _dynamicShadowConfig[3] * HORSE_SCALEY_RATE
                  _skewX = _dynamicShadowConfig[4]
              end 
              _depth = _dynamicShadowConfig[6]
          elseif self.mType == 4 then
              _dynamicShadowConfig = self.mSceneAni_SceneDB.DynamicShadowConfig
              if self.mBornDirection == 1 then
                 _scaleY = _dynamicShadowConfig[1]
                 _skewX = _dynamicShadowConfig[2]
              else
                 _scaleY = _dynamicShadowConfig[3]
                 _skewX = _dynamicShadowConfig[4]
              end
              _depth = _dynamicShadowConfig[5]
          end
      end
      self:setOpacity(_depth)
      self:setScaleY(_scaleY)
      self:setRotationSkewX(_skewX)
      self.mScaleY = _scaleY
      self.mSkewX = _skewX
      self.mDynamicShadowConfig = _dynamicShadowConfig
end