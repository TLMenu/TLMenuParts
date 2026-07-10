
local UIS = game:GetService("UserInputService")  

local dragRoot = script.Parent              
local header   = dragRoot:WaitForChild("Header")  

local dragging = false        
local dragStart, startPos     


header.InputBegan:Connect(function(input)
    
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        dragging  = true              
        dragStart = input.Position    
        startPos  = dragRoot.Position 

        
        local connection
        connection = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false           
                connection:Disconnect()    
            end
        end)
    end
end)


UIS.InputChanged:Connect(function(input)
    
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart  

        
        dragRoot.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,  
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y   
        )
    end
end)