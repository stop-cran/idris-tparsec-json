module Scientific

import Data.NEList

%default total
%access public export


-- inspired by Haskell's Data.Scientific module
record Scientific where
    constructor MkScientific
    coefficient : Integer
    exponent : Integer
  
scientificToDouble : Scientific -> Double
scientificToDouble (MkScientific c e) = fromInteger c * exp where
    exp = if e < 0 then 1 / pow 10 (fromIntegerNat (- e))
                   else pow 10 (fromIntegerNat e)

toScientific : Integer -> Maybe (NEList Nat) -> Maybe Integer -> Scientific
toScientific c Nothing exp = MkScientific c (fromMaybe 0 exp)
toScientific c (Just l) exp = let len = (Data.NEList.length l)
                                  fromDigits = foldl (\a, b => 10 * a + cast b) 0 in
    MkScientific
        (c * pow 10 len + fromDigits l)
        (fromMaybe 0 exp - cast len)
