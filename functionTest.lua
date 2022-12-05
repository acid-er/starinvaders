


function myFunction(numAliens, alienType)
	print("numAliens: " .. numAliens)
	if alienType == nil then
		print( "alienType was not set")
	else
		print( "alienType: " .. alienType)
	end
end


myFunction(8,5)
myFunction(9)