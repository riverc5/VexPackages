local PackageIndex = script.Parent._Index

local package = PackageIndex["Shimmer"]["Shimmer"]

if package.ClassName == "ModuleScript" then
	return require(package)
end

return package