# Total Json parser in Idris [![Build Status](https://travis-ci.com/stop-cran/idris-tparsec-json.svg?branch=master)](https://travis-ci.com/stop-cran/idris-tparsec-json)

This is a total Json parser built on [TParsec](https://github.com/gallais/idris-tparsec) library.

# Installation

```bash
idris --install .\TParsecJson.ipkg
```

# Example

```
> idris -p tparsecjson
Idris> :module TParsecJson
*TParsecJson> :exec map formatJson $ parseJson "[\"xx\", 1.12, null, {\"a\":  1, \"bb\" : {\"cc\" : true}}]"
```

The result:
```
Just "[\"xx\", 1.12, null, {\"a\" : 1, \"bb\" : {\"cc\" : true}}]"
```