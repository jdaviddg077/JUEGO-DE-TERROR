-- Services
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- RemoteEvent para comunicarse con el cliente
local remoteEvent = ReplicatedStorage:FindFirstChild("TriggerFadeEvent")
if not remoteEvent then
	remoteEvent = Instance.new("RemoteEvent")
	remoteEvent.Name = "TriggerFadeEvent"
	remoteEvent.Parent = ReplicatedStorage
end

-- CONFIGURACIÓN DE OBJETOS
local TRIGGER_PART = Workspace:WaitForChild("TriggerBlock") -- Bloque donde está el ProximityPrompt
local PROXIMITY_PROMPT = TRIGGER_PART:WaitForChild("ProximityPrompt") -- El objeto ProximityPrompt

local TIME_TO_SET = "14:00:00"

local OLD_BLOCKS = Workspace:WaitForChild("OldBlocks")
local NEW_BLOCKS = Workspace:WaitForChild("NewBlocks")

local debounce = false

local function replaceBlocks()
	-- Eliminar/ocultar bloques antiguos
	for _, block in ipairs(OLD_BLOCKS:GetChildren()) do
		if block:IsA("BasePart") or block:IsA("Model") then
			block:Destroy()
		end
	end

	-- Mostrar nuevos bloques
	for _, block in ipairs(NEW_BLOCKS:GetChildren()) do
		if block:IsA("BasePart") then
			block.Transparency = 1
			block.CanTouch = true
			block.CanCollide = false
		elseif block:IsA("Model") then
			for _, part in ipairs(block:GetDescendants()) do
				if part:IsA("BasePart") then
					part.Transparency = 1
					part.CanCollide = false
					part.CanTouch = true
				end
			end
		end
	end
end

local function onPromptTriggered(player)
	if debounce then return end
	debounce = true

	-- Desactivar temporalmente el Prompt para que no lo presionen varias veces
	PROXIMITY_PROMPT.Enabled = false

	-- 1. Activar la transición en pantalla negra
	remoteEvent:FireAllClients()

	-- 2. Esperar a que la pantalla esté completamente oscura (0.5s dura el fade)
	task.wait(0.5)

	-- 3. Aplicar el cambio de hora y reemplazar bloques en la oscuridad
	Lighting.TimeOfDay = TIME_TO_SET
	replaceBlocks()

	-- 4. Esperar a que termine la animación de regreso y reactivar el prompt (opcional)
	task.wait(1.5)
	-- PROXIMITY_PROMPT.Enabled = true -- Descomenta si quieres que se pueda pulsar otra vez
end

-- Conectar el evento del ProximityPrompt
PROXIMITY_PROMPT.Triggered:Connect(onPromptTriggered)