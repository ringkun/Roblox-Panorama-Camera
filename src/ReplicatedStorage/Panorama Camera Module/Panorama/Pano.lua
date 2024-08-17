local pano = {}

pano.PanoScreenGui = nil
pano.n = 5
pano.FOV = 360
pano.World = {}
pano.panoramaconnection = nil
pano.camtable = {}
pano.vptable = {}
function H2VFOV(fov,ratio)
	return math.deg(2*math.atan(math.tan(math.rad(fov/2))*1/ratio))
end

function pano.set(listOfStuff)
	if pano.PanoScreenGui then
		pano.PanoScreenGui:Destroy()
	end
	local panorama = Instance.new("ScreenGui")
	panorama.Enabled = false
	panorama.Name = "Panorama"
	panorama.Parent = game.StarterGui
	pano.PanoScreenGui = panorama
	local panoFrame = Instance.new("Frame")
	panoFrame.Size = UDim2.new(1,0,1,0)
	panoFrame.BackgroundTransparency = 1
	panoFrame.Parent = panorama

	local cc = game.Workspace.CurrentCamera
	pano.camtable = {}
	pano.vptable = {}
	local ViewPortObjects = nil
	if listOfStuff then
		ViewPortObjects = Instance.new("Folder")
		for i,v in pairs(listOfStuff) do
			v:Clone().Parent = ViewPortObjects
		end
	end
	pano.World = listOfStuff
	for i = 0,pano.n do
		local vp = Instance.new("ViewportFrame")
		vp.Size = UDim2.new(1/pano.n,0,1,0)
		vp.AnchorPoint = Vector2.new(0,.5)
		vp.Position = UDim2.new((1/pano.n)*i-1/(2*pano.n),0,.5,0)
		vp.Parent = panoFrame
		vp.Name = i
		vp.BorderSizePixel=0
		vp.BackgroundTransparency = 1

		local cam = Instance.new("Camera")
		cam.Parent = panoFrame
		cam.Name = i
		vp.CurrentCamera = cam
		table.insert(pano.camtable,cam)
		local vpo = ViewPortObjects:Clone()
		vpo.Parent = vp
	end
	pano.PanoScreenGui.Enabled = true
	print("Panorama is ready to be set or rendered")
end
function pano.render()
	if not pano.PanoScreenGui then
		warn("You must set the panorama using _G.pano.set()")
	end
	if pano.panoramaconnection then
		pano.panoramaconnection:Disconnect()
	end

	local panoratio = pano.FOV/pano.n
	local panoFrame = pano.PanoScreenGui.Frame
	local cc = game.Workspace.CurrentCamera
	local ratio = (panoFrame.AbsoluteSize.X/pano.n)/panoFrame.AbsoluteSize.Y
	local angleOffset = CFrame.Angles(0,math.rad(pano.FOV*.5),0)
	local camCFR = cc.CFrame*angleOffset
	local VFOV = H2VFOV(panoratio,ratio)	
	for i,v in pairs(pano.camtable) do
		v.CFrame = camCFR*CFrame.Angles(0,math.rad(-panoratio)*(i-1),0)
		v.FieldOfView = VFOV
	end
	pano.PanoScreenGui.Enabled = true
end
function pano.run()
	if not pano.PanoScreenGui then
		warn("You must set the panorama using _G.pano.set()")
	end

	if pano.panoramaconnection then
		pano.panoramaconnection:Disconnect()
	end
	local panoratio = pano.FOV/pano.n
	local panoFrame = pano.PanoScreenGui.Frame
	local angleOffset = CFrame.Angles(0,math.rad(pano.FOV*.5),0)

pano.panoramaconnection = game:GetService("RunService").PreRender:Connect(function()
		local cc = game.Workspace.CurrentCamera
		if not cc then
			pano.quit()
		end
		local ratio = (panoFrame.AbsoluteSize.X/pano.n)/panoFrame.AbsoluteSize.Y
		local camCFR = cc.CFrame*angleOffset
		local VFOV = H2VFOV(panoratio,ratio)	
		for i,v in pairs(pano.camtable) do
			v.CFrame = camCFR*CFrame.Angles(0,math.rad(-panoratio)*(i-1),0)
			v.FieldOfView = VFOV
		end
	end)
	
end

function pano.quit()
	if pano.panoramaconnection then
		pano.panoramaconnection:Disconnect()
	end
	pano.PanoScreenGui:Destroy()
	pano.PanoScreenGui = nil
end

function pano.help()
	print("[.set(a)   ] When you change the internal values of the module, you will need to call this so the panorama can update properly, where 'a' is the list of elements you want to render in the panorama.")
	print("[.render() ] Creates a single snap shot of the panorama from your direction")
	print("[.run()    ] Will render the panorama at run time.")
	print("[.quit()   ] Will reset the panorama screen gui")
end
return pano
