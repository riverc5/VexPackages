local PackageIndex = script.Parent._Index

local package = PackageIndex["Networking"]["Networking"]

if package.ClassName == "ModuleScript" then
	return require(package)
end

return package