local PackageIndex = script.Parent._Index

local package = PackageIndex["Environment"]["Environment"]

if package.ClassName == "ModuleScript" then
	return require(package)
end

return package