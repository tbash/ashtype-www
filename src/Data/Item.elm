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
    Decode.field "node" <|
        Decode.map4 Item
            (Decode.at [ "edge_liked_by", "count" ] Decode.int)
            (Decode.field "thumbnail_src" Decode.string)
            (Decode.field "shortcode" Decode.string |> Decode.map toLink)
            (Decode.at [ "edge_media_to_caption", "edges" ] <|
                Decode.map (Maybe.withDefault "" << List.head) <|
                    Decode.list <|
                        Decode.map identity <|
                            Decode.at [ "node", "text" ] Decode.string
            )


listDecoder : Decoder (List Item)
listDecoder =
    Decode.list decoder
        |> Decode.at
            [ "graphql", "user", "edge_owner_to_timeline_media", "edges" ]
