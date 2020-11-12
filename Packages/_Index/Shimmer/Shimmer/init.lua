--[[

  // Shimmer.lua
  // Lightweight library for adding Shimmer to UI elements
  // Compatible objects: Any UI class with BackgroundColor3
  // Author: @Vexitory
  // 11.7.2020

]]

--// SERVICES

local ReplicatedStorage = game:GetService('ReplicatedStorage')

--// VARIABLES

local Tween = require(ReplicatedStorage.Packages.Tween)

local Settings = {

	Debug = true,
	ShineTime = 0.85,
	ShineDelay = 1,
	Offset = Vector2.new(-1, 0),
	GoalOffset = Vector2.new(1, 0),
	Rotation = 50,

}

local Shimmer = {}
Shimmer.__index = Shimmer
local TweenInfoQuick = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

--// FUNCTIONS

local function InstantizeUIGradient(NewShimmer)

	local UIGradient = Instance.new('UIGradient')
	UIGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, NewShimmer.BaseColor), ColorSequenceKeypoint.new(0.3, NewShimmer.BaseColor), ColorSequenceKeypoint.new(0.5, NewShimmer.ShineColor), ColorSequenceKeypoint.new(0.8, NewShimmer.BaseColor), ColorSequenceKeypoint.new(1, NewShimmer.BaseColor)})
	UIGradient.Rotation = NewShimmer.Rotation
	UIGradient.Offset = NewShimmer.Offset
	return UIGradient

end

local function InstantizeTweenNumberValue(Start, End)

	local NumberValue = Instance.new('NumberValue')
	NumberValue.Value = Start
	Tween(NumberValue, TweenInfoQuick, {Value = End})

	coroutine.wrap(function()
		wait(0.1)
		NumberValue:Destroy()
	end)()

	return NumberValue

end

function Shimmer.new(Object, OptionalData)

	local NewShimmer = {}
	setmetatable(NewShimmer, Shimmer)
	if not OptionalData then OptionalData = {} end

	NewShimmer.IsPlaying = false
	NewShimmer.ShineTime = OptionalData.ShineTime or Settings.ShineTime
	NewShimmer.BaseColor = Object.BackgroundColor3
	NewShimmer.ShineColor = NewShimmer.BaseColor:Lerp(Color3.fromRGB(255, 255, 255), 0.65)
	NewShimmer.Rotation = OptionalData.Rotation or Settings.Rotation
	NewShimmer.ShineDelay = OptionalData.ShineDelay or Settings.ShineDelay
	NewShimmer.Offset = OptionalData.Offset or Settings.Offset
	NewShimmer.GoalOffset = OptionalData.GoalOffset or Settings.GoalOffset
	NewShimmer.TweenInformation = TweenInfo.new(NewShimmer.ShineTime, Enum.EasingStyle.Circular, Enum.EasingDirection.Out, -1, false, NewShimmer.ShineDelay)
	NewShimmer.PhysicalGradientObject = InstantizeUIGradient(NewShimmer)

	Object.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	local PhysicalGradientObject = NewShimmer.PhysicalGradientObject

	PhysicalGradientObject.Parent = Object

	Tween(PhysicalGradientObject, NewShimmer.TweenInformation, {Offset = NewShimmer.GoalOffset})

	return NewShimmer

end

function Shimmer:Start()

	local NewShimmer = self
	NewShimmer.IsPlaying = true

end

function Shimmer:Stop()

	local NewShimmer = self
	NewShimmer.IsPlaying = false

end

return Shimmer