return function(Object, Info, Properties)

	local TweenService = game:GetService('TweenService')
	local Tween = TweenService:Create(Object, Info, Properties)
    Tween:Play()

end