local PackageIndex = script.Parent._Index


local package = PackageIndex["Animation"]["Animation"]

if package.ClassName == "ModuleScript" then
	return require(package)
end

return package