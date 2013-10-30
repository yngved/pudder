#####################################################################################################
# @name: replace-in-template
# @created: 24.10.2013
# @author: 	YND
#
# The script will do a replacement of the values denoted {...} in a 'template_file':
# 			i.e.
# 			- {CONNECTOR_PORT}
# 			- {SERVER_PORT}
#
# It will substitute  the denoted values with the values found in the 'prop_file'. It will use the 'env'
# parameter to find the correct value(s) in the 'prop_file'.
#
# example usage: .\replace-in-template-env.ps1 -env DEV1 -templateFile server-template.xml -destinationFile server.xml -propertiesFile server-xml.prop
#
# Valid values
# $environment=$env: DEV1/DEV2/ST1/ST2
#
#######################################################################################################

# Resolve input parameters
param($env, $templateFile, $destinationFile, $propertiesFile)

# Write input variables to console
Write-Host "(Target=$env)"
Write-Host "(Template=$templateFile)"
Write-Host "(Destination=$destinationFile)"
Write-Host "(Properties=$propertiesFile)"

# Find properties to replace in 'templateFile'
$lines = (Get-Content $templateFile) | Where-Object {$_ -like "*{*}*" }

$propertiesToReplace=@()
foreach ($line in $lines)
{	
	# regex will look for pattern like this: {*}
	$regex = "(?<={)[^}]*(?=})"	
	$properties = $line | select-string -Pattern $regex -AllMatches | % { $_.Matches } | % { $_.Value } 	
	
	foreach($prop in $properties)
	{
		if($propertiesToReplace -notcontains $prop)
		{	
			$propertiesToReplace += "{" + $prop + "}"
		}
	}	
}

# Filter properties on $environment
$properties = Get-Content $propertiesFile | Where-Object {$_ -like "$env*" }

# Match properties and values and add them to the 'lookupTable'
$lookupTable = @{}
foreach ($prop in $properties)
{	
	# Find the index of the delimeter =
	$delimeter = $prop.IndexOf("=")
	$key = $prop.Substring(0,$delimeter)
	$value = $prop.Substring($delimeter +1)		
	
	# Remove environment part of $key. Looking for the first '.'
	$delimeter = $key.IndexOf(".")
	$key = $key.Substring($delimeter + 1)	
	
	foreach ($replace in $propertiesToReplace)
	{
		# Remove the curly braces
		$match = $replace.Substring(1, ($replace.Length -2))		
		
		#Write-Host "Match=$match"
		if($key.ToLower() -like $match.ToLower())
		{
			if (!$lookupTable.contains($replace.TrimEnd()))
			{					
				# Add key/value to 'lookupTable'								
				$lookupTable.add($replace.TrimEnd(), $value.TrimEnd())
			}
		}			
	}		
}

# Do replacement in 'template-file' and write content to 'destinationFile'
Get-Content -Path $templateFile | ForEach-Object { 
    $line = $_

    $lookupTable.GetEnumerator() | ForEach-Object {
        if ($line -match $_.Key)
        {        		
            $line = $line -replace $_.Key, $_.Value
        }
    }
   $line
} | Set-Content -Path $destinationFile

Write-Host "$destinationFile generated"