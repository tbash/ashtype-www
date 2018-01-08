module Request.Item exposing (list)

import Data.Item as Item exposing (Item)
import Http exposing (Request)


list : Request (List Item)
list =
    let
        endpoint =
            "https://g19xty6i0c.execute-api.us-east-1.amazonaws.com/dev/feed/ashtype"
    in
    Http.get endpoint Item.listDecoder
