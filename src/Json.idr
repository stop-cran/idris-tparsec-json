module Json

%default total
%access public export


data JsonType = Value | Array | Object

data Json : JsonType -> Type where
    JsonString : String -> Json Value
    JsonNumber : Double -> Json Value
    JsonBool   : Bool   -> Json Value
    JsonNull   : Json Value
    JsonArrayNil   : Json Array
    JsonArrayCons  : Json type -> Json Array -> Json Array
    JsonObjectNil  : Json Object
    JsonObjectCons : String -> Json type -> Json Object -> Json Object

toJsonString : String -> DPair JsonType Json
toJsonString s = (_ ** JsonString s)

toJsonNumber : Double -> DPair JsonType Json
toJsonNumber d = (_ ** JsonNumber d)

toJsonArray : List (DPair JsonType Json) -> Json Array
toJsonArray [] = JsonArrayNil
toJsonArray ((_ ** x) :: xs) = JsonArrayCons x (toJsonArray xs)

toJsonObject : List (String, DPair JsonType Json) -> Json Object
toJsonObject [] = JsonObjectNil
toJsonObject ((key, (_ ** value)) :: xs) = JsonObjectCons key value (toJsonObject xs)

Show (Json type) where
    show (JsonString s)   = show s
    show (JsonNumber x)   = show x
    show (JsonBool True ) = "true"
    show (JsonBool False) = "false"
    show  JsonNull        = "null"
    show {type=Array} x   = "[" ++ showArray x ++ "]" where
        showArray  JsonArrayNil                   = ""
        showArray (JsonArrayCons x JsonArrayNil)  = show x
        showArray (JsonArrayCons x xs)            = show x ++ ", " ++ showArray xs
    show {type=Object} x  = "{" ++ showObject x ++ "}" where
        showObject  JsonObjectNil                        = ""
        showObject (JsonObjectCons key x JsonObjectNil)  = show key ++ " : " ++ show x
        showObject (JsonObjectCons key x xs)             = show key ++ " : " ++ show x ++ ", " ++ showObject xs

formatJson : DPair JsonType Json -> String
formatJson (_ ** json) = show json
