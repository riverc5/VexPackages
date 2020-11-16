local PackageIndex = script.Parent._Index

local package = PackageIndex["Sound"]["Sound"]

if package.ClassName == "ModuleScript" then
	return require(package)
end

return package