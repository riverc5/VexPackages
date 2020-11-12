local PackageIndex = script.Parent._Index

local package = PackageIndex["Tween"]["Tween"]

if package.ClassName == "ModuleScript" then
	return require(package)
end

return package