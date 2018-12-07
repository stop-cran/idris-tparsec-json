module TParsecJson

import public Json
import Data.NEList
import TParsec
import TParsec.Running
import TParsec.Combinators.Numbers
import TParsecExtras
import Scientific

%default total


hex : Parser' Int
hex = alts $ map (\(i, c) => cmap i (char c)) $
        map (\i => (i, chr (ord '0' + i))) [0..9] ++
        map (\i => (i, chr (ord 'a' + i - 10))) [10..15]

hexQuad : Parser' Int
hexQuad = map (\(((a, b), c), d) => a * 4096 + b * 256 + c * 16 + d) $
            ((hex `and` hex) `and` hex) `and` hex

specialChar : Parser' Char
specialChar = char '\\' `rand` alts [
    char '"',
    char '\\',
    char '/',
    cmap '\b' (char 'b'),
    cmap '\f' (char 'f'),
    cmap '\n' (char 'n'),
    cmap '\r' (char 'r'),
    cmap '\t' (char 't'),
    char 'u' `rand` map chr hexQuad]

jsonString : Parser' String
jsonString = between (char '"') (char '"')
             (map nepack $ nelist $ specialChar `alt` except '"') `alt`
             cmap "" (string "\"\"")

jsonNumber : Parser' Double
jsonNumber = map (scientificToDouble . uncurry (uncurry toScientific)) $
             (decimalInteger `andopt`
             (char '.' `rand` nelist decimalDigit)) `andopt`
             (char 'e' `rand` decimalInteger)

jsonValue : Parser' (DPair JsonType Json)
jsonValue = fix _ $ \rec =>
    let jsonArray = optbetween (char '[') (char ']') $
                    natMap (sepBy (char ',') . betweenopt spaces spaces) rec
        jsonObject = optbetween (char '{') (char '}') $
                     sepBy (char ',') $
                     (betweenopt spaces spaces jsonString `land` char ':') `and`
                     natMap (betweenopt spaces spaces) rec in
            alts [cmap (_ ** JsonBool True)  $ string "true",
                  cmap (_ ** JsonBool False) $ string "false",
                  cmap (_ ** JsonNull)       $ string "null",
                  map toJsonString             jsonString,
                  map toJsonNumber             jsonNumber,
                  map (\x => (Array  ** toJsonArray  (toListMaybe x))) jsonArray,
                  map (\x => (Object ** toJsonObject (toListMaybe x))) jsonObject]

export
parseJson : String -> Maybe (DPair JsonType Json)
parseJson content = parseMaybe content jsonValue
