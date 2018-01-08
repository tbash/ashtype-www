module Data.Item exposing (Item, listDecoder)

import Json.Decode as Decode exposing (Decoder)


type alias Item =
    { likeCount : Int
    , imgUrl : String
    , link : String
    , caption : String
    }


decoder : Decoder Item
decoder =
    let
        toLink =
            (++) "https://www.instagram.com/p/"
    in
    Decode.map4 Item
        (Decode.at [ "likes", "count" ] Decode.int)
        (Decode.field "thumbnail_src" Decode.string)
        (Decode.field "code" Decode.string |> Decode.map toLink)
        (Decode.field "caption" Decode.string)


listDecoder : Decoder (List Item)
listDecoder =
    Decode.at [ "user", "media", "nodes" ] (Decode.list decoder)
