-- BuildVendored wraps Details Lua in setfenv. Blizzard C APIs that return
-- mixin-backed types (e.g. C_Texture.GetAtlasInfo -> Vector2DMixin) only
-- rawget the function environment, so __index to _G is not enough.
local real_setfenv = setfenv
function setfenv(fn, env)
    if type(env) == "table" then
        local mixins = {
            "Vector2DMixin",
            "Vector3DMixin",
            "ColorMixin",
            "ItemLocationMixin",
            "ItemTransmogInfoMixin",
            "PlayerLocationMixin",
            "TransmogPendingInfoMixin",
            "TransmogLocationMixin",
            "CreateVector2D",
            "CreateVector3D",
            "CreateColor",
            "CreateAndInitFromMixin",
            "CreateFromMixins",
            "Mixin",
        }
        for i = 1, #mixins do
            local name = mixins[i]
            if rawget(env, name) == nil and _G[name] ~= nil then
                rawset(env, name, _G[name])
            end
        end
    end
    return real_setfenv(fn, env)
end

if not Vector2DMixin then
    Vector2DMixin = {}
    function Vector2DMixin:IsZero()
        return self.x == 0 and self.y == 0
    end
    function Vector2DMixin:GetLength()
        return math.sqrt(self.x * self.x + self.y * self.y)
    end
    function Vector2DMixin:GetLengthSquared()
        return self.x * self.x + self.y * self.y
    end
    function Vector2DMixin:Normalize()
        local len = self:GetLength()
        if len > 0 then
            self.x = self.x / len
            self.y = self.y / len
        end
    end
    function Vector2DMixin:Dot(other)
        return self.x * other.x + self.y * other.y
    end
    function Vector2DMixin:ScaleBy(s)
        self.x = self.x * s
        self.y = self.y * s
    end
    function Vector2DMixin:DivideBy(s)
        self.x = self.x / s
        self.y = self.y / s
    end
    function Vector2DMixin:Add(other)
        self.x = self.x + other.x
        self.y = self.y + other.y
    end
    function Vector2DMixin:Subtract(other)
        self.x = self.x - other.x
        self.y = self.y - other.y
    end
    function Vector2DMixin:Clone()
        return CreateVector2D(self.x, self.y)
    end
    function Vector2DMixin:IsEqualTo(other)
        return self.x == other.x and self.y == other.y
    end
    function Vector2DMixin:GetXY()
        return self.x, self.y
    end
    function Vector2DMixin:SetXY(x, y)
        self.x = x
        self.y = y
    end
end

if not CreateVector2D then
    function CreateVector2D(x, y)
        local vector = { x = x or 0, y = y or 0 }
        if Mixin then
            Mixin(vector, Vector2DMixin)
        else
            for k, v in pairs(Vector2DMixin) do
                vector[k] = v
            end
        end
        return vector
    end
end
