module TParsecExtras

import TParsec
import TParsec.Running
import Data.NEList

%default total
%access export


toListMaybe : Maybe (NEList a) -> List a
toListMaybe Nothing = []
toListMaybe (Just (MkNEList x xs)) = x :: xs

nepack : NEList Char -> String
nepack = pack . Data.NEList.toList

sepBy : (Alternative mn, Monad mn) =>
        All (Parser mn p a :-> Parser mn p b :-> Parser mn p (NEList b))
sepBy sep p = map (uncurry cons') $ andopt p $ nelist $ rand sep p where
    cons' x xs = MkNEList x $ toListMaybe xs

optbetween : (Alternative mn, Monad mn) =>
    All (Parser mn p a :-> Box (Parser mn p b) :-> Box (Parser mn p c) :-> Parser mn p (Maybe c))
optbetween open close content = (open `randopt` content) `land` close

public export
TParser' : Type -> Nat -> Type
TParser' = Parser TParsecU Types.chars

natMap : (f : All (TParser' a :-> TParser' b)) -> All (Box (TParser' a) :-> Box (TParser' b))
natMap {a} = Nat.map {a=TParser' a}

public export
Parser' : Type -> Type
Parser' t = All (TParser' t)

except : Char -> Parser' Char
except c = guard (/= c) anyTok {p=Types.chars}
