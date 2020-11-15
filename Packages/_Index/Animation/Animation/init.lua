--[[

// Animation.lua
// Provide a lightweight library for controlling all humanoid animations
// ** Filed on Trello, still an in-progress module
// @Vexitory
// 11.11.2020

]]

--// SERVICES

local ContentProvider = game:GetService('ContentProvider')
local KeyframeSequenceProvider = game:GetService('KeyframeSequenceProvider')

--// VARIABLES

local Animation = {}
Animation.__index = Animation

local AnimationDatabase = script.AnimationDatabase
local ActiveHumanoid = nil
local UrlDatabase = require(script.Parent.Parent.UrlDatabase)
local Environment = require(script.Parent.Parent.Environment.Environment)

local PreviousSpeedBeforePause = nil

--// FUNCTIONS

function InstantizeValue(ValueType, Value)

    local Object = Instance.new(ValueType)
    Object.Value = Value
    return Object

end

function InstantizeAnimation(Id)

    local PhysAnimation = Instance.new('Animation')
    PhysAnimation.AnimationId = UrlDatabase.RobloxAssetPrefix .. Id
    return PhysAnimation

end

function InstantizeAnimator(Parent)

    local Animator = Instance.new('Animator')
    Animator.Parent = Parent
    return Animator

end

function Animation:SetActiveHumanoid(Humanoid)

    if not Humanoid then error('Humanoid was not passed') return end
    if not Humanoid:IsA('Humanoid') then error('Not a valid Humanoid!') return end
    if not Humanoid:IsDescendantOf(game) then error("Humanoid hasn't loaded in yet!") return end
    ActiveHumanoid = Humanoid
    return

end

function Animation:StopAllAnimations(Humanoid)

    local HumanoidToBeUsed = nil

    if not Humanoid then
        if ActiveHumanoid then
            HumanoidToBeUsed = ActiveHumanoid
        elseif (not ActiveHumanoid) then
            error("You didn't pass a Humanoid and an an active humanoid hasn't been set!")
            return
        end
    elseif (Humanoid) then
        HumanoidToBeUsed = Humanoid
    end

    local AnimatorAssigned = HumanoidToBeUsed:FindFirstChild('Animator')
    if not AnimatorAssigned then error("An animator does not exist for the Humanoid! Please call Animation:Animator() on the server") return end
    for _, Track in pairs(AnimatorAssigned:GetPlayingAnimationTracks()) do
        if Track.IsPlaying == true then
            Track:Stop()
        end
    end

end

function Animation:Animator(Humanoid)

    if Environment.IsServer == true then
        
        if not Humanoid:FindFirstChild('Animator') then
            InstantizeAnimator(Humanoid)
        end
    else
        error('Animation:Animator() must be called on the server')
    end

end

function Animation:LoadAnimation(AnimationOrId, Humanoid)

    local NewAnimation = {}
    setmetatable(NewAnimation, Animation)

    local HumanoidToBeUsed
    local AnimatorToBeUsed
    local Id

    if not Humanoid then
        if ActiveHumanoid then
            HumanoidToBeUsed = ActiveHumanoid
        elseif (not ActiveHumanoid) then
            error("You didn't pass a Humanoid and an an active humanoid hasn't been set!")
            return
        end
    elseif (Humanoid) then
        HumanoidToBeUsed = Humanoid
    end

    if typeof(AnimationOrId) == 'string' then

        if AnimationDatabase[AnimationOrId] then
            Id = AnimationDatabase[AnimationOrId]
        else
            error('An animation corresponding to this name does not exist in the library. Add it or use a raw animation Id.')
            return
        end

    elseif typeof(AnimationOrId) == 'number' then

        Id = AnimationOrId

    end

    if Environment.IsClient == true then
        local AnimatorFound = HumanoidToBeUsed:FindFirstChild('Animator')
        if not AnimatorFound then
            error('There is no Animator loaded onto the Humanoid. Please load one from the server.')
            return
        elseif AnimatorFound then
            AnimatorToBeUsed = AnimatorFound
        end
    else
        local AnimatorFound = HumanoidToBeUsed:FindFirstChild('Animator')
        if not AnimatorFound then
            AnimatorToBeUsed = InstantizeAnimator(HumanoidToBeUsed)
        elseif AnimatorFound then
            AnimatorToBeUsed = AnimatorFound
        end
    end

    local PhysicalAnimation = InstantizeAnimation(Id)

    NewAnimation.PhysicalAnimationTrack = AnimatorToBeUsed:LoadAnimation(PhysicalAnimation)

    ContentProvider:PreloadAsync({NewAnimation.PhysicalAnimationTrack})

    NewAnimation.Speed = InstantizeValue('NumberValue', NewAnimation.PhysicalAnimationTrack.Speed)
    NewAnimation.Weight = InstantizeValue('NumberValue', 1)
    NewAnimation.Length = InstantizeValue('NumberValue', NewAnimation.PhysicalAnimationTrack.Length / NewAnimation.Speed.Value)
    NewAnimation.IsPlaying = InstantizeValue('BoolValue', NewAnimation.PhysicalAnimationTrack.IsPlaying)
    NewAnimation.IsLooped = InstantizeValue('BoolValue', NewAnimation.PhysicalAnimationTrack.Looped)
    NewAnimation.Priority = NewAnimation.PhysicalAnimationTrack.Priority
    NewAnimation.TimePosition = InstantizeValue('NumberValue', NewAnimation.PhysicalAnimationTrack.TimePosition / NewAnimation.Speed.Value)
    NewAnimation.IsPaused = InstantizeValue('BoolValue', false)
    NewAnimation.MarkerReachedSignal = nil
    NewAnimation.Name = 'Animation'
    NewAnimation.FadeOutTime = InstantizeValue('NumberValue', 0.1)
    NewAnimation.Humanoid = HumanoidToBeUsed

    NewAnimation.Weight.Changed:Connect(function(Value)
        NewAnimation.PhysicalAnimationTrack:AdjustWeight(Value, NewAnimation.FadeOutTime)
    end)

    NewAnimation.Speed.Changed:Connect(function(Value)
        NewAnimation.PhysicalAnimationTrack:AdjustSpeed(Value)
        NewAnimation.Length.Value = NewAnimation.Length.Value / NewAnimation.Speed.Value
        if NewAnimation.IsPaused.Value == true then
            NewAnimation.IsPaused.Value = false
        end
    end)

    NewAnimation.IsLooped.Changed:Connect(function(Value)
        NewAnimation.PhysicalAnimationTrack.Looped = true
    end)

    NewAnimation.TimePosition.Changed:Connect(function(Value)
        NewAnimation.PhysicalAnimationTrack.TimePosition = Value / NewAnimation.Speed.Value
    end)

    NewAnimation.PhysicalAnimationTrack.Stopped:Connect(function()
        NewAnimation.IsPlaying.Value = false
    end)

    local MaxRetries = 8
	local Tries = 0

	function TryGetKeyframe()
		Tries += 1
		if MaxRetries == Tries then return end
		local NowTick = tick()
		local success, result = pcall(function() return KeyframeSequenceProvider:GetKeyframeSequenceAsync('rbxassetid://' .. Id) end)
		if success == true then
			return result
		else
			game:GetService('RunService').Stepped:Wait()
			TryGetKeyframe()
		end
	end

	local Sequence = TryGetKeyframe()

	if Sequence then
		local Markers = {}
		local Keyframes = Sequence:GetKeyframes()

		for _, Keyframe in pairs(Keyframes) do
			local TheseMarkers = Keyframe:GetMarkers()
			for _, NewMarker in pairs(TheseMarkers) do
				table.insert(Markers, NewMarker)
			end
		end
        for _,v in pairs(Markers) do
            print(v)
			local Bindable = Instance.new('BindableEvent')
			NewAnimation[v.Name] = Bindable.Event
			NewAnimation.PhysicalAnimationTrack:GetMarkerReachedSignal(v.Name):Connect(function()
				Bindable:Fire()
			end)
		end
	end

    return NewAnimation

end

function Animation:Play()

    local NewAnimation = self
    NewAnimation.PhysicalAnimationTrack:Play(NewAnimation.FadeOutTime.Value, NewAnimation.Weight.Value, NewAnimation.Speed.Value)
    NewAnimation.IsPlaying.Value = true

end

function Animation:Stop()

    local NewAnimation = self
    NewAnimation.PhysicalAnimationTrack:Stop(NewAnimation.FadeOutTime.Value)

end

function Animation:Pause()

    local NewAnimation = self
    PreviousSpeedBeforePause = NewAnimation.Speed.Value
    NewAnimation.Speed.Value = 0
    NewAnimation.IsPaused.Value = true
    return

end

function Animation:Resume()

    local NewAnimation = self

    if NewAnimation.IsPaused.Value == true then

        NewAnimation.IsPaused.Value = false
        NewAnimation.Speed.Value = PreviousSpeedBeforePause

    end

    return

end

return Animation