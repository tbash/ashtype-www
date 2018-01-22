module Main exposing (..)

import Data.Item exposing (Item)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import RemoteData exposing (RemoteData(..), WebData)
import Request.Item
import SelectList exposing (Position(..), SelectList)


-- TYPES


type alias Model =
    { tabs : SelectList Tab
    , itemList : WebData (List Item)
    }


type Msg
    = ItemListResponse (WebData (List Item))
    | SelectTab Tab


type Tab
    = About
    | Social
    | Contact



-- STATE


init : ( Model, Cmd Msg )
init =
    ( { tabs = SelectList.fromLists [ About ] Social [ Contact ]
      , itemList = Loading
      }
    , Request.Item.list
        |> RemoteData.sendRequest
        |> Cmd.map ItemListResponse
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ItemListResponse itemList ->
            ( { model | itemList = RemoteData.map (List.take 12) itemList }
            , Cmd.none
            )

        SelectTab tab ->
            ( { model | tabs = SelectList.select ((==) tab) model.tabs }
            , Cmd.none
            )



-- VIEW


view : Model -> Html Msg
view model =
    let
        email =
            "info@ashtype.com"
    in
    div [ class "flex justify-center flex-col items-center m-8 bounce-in-up" ]
        [ img [ class " w-64", src "/media/logo.png" ] []
        , model.tabs
            |> SelectList.mapBy viewTab
            |> SelectList.toList
            |> ul [ class "list-reset flex justify-center mt-8 mb-8" ]
        , div [ class "m-4" ]
            [ case SelectList.selected model.tabs of
                About ->
                    div []
                        [ span []
                            [ text "figuring things out." ]
                        ]

                Social ->
                    viewSocial model.itemList

                Contact ->
                    div []
                        [ a [ href <| "mailto:" ++ email ]
                            [ text email ]
                        ]
            ]
        ]


viewTab : Position -> Tab -> Html Msg
viewTab position tab =
    li [ class "m-2" ]
        [ a
            [ href "javascript:void(0);"
            , onClick <| SelectTab tab
            , classList
                [ ( "p-4", True )
                , ( "border-b", position == Selected )
                ]
            ]
            [ text (tabToString tab) ]
        ]


tabToString : Tab -> String
tabToString tab =
    case tab of
        About ->
            "ABOUT"

        Social ->
            "SOCIAL"

        Contact ->
            "CONTACT"


viewSocial : WebData (List Item) -> Html Msg
viewSocial itemList =
    div [ class "flex justify-center" ]
        [ case itemList of
            Success items ->
                items
                    |> List.map viewItem
                    |> ul
                        [ class "list-reset flex flex-wrap justify-around"
                        , style [ ( "max-width", "64rem" ) ]
                        ]

            Loading ->
                div [ class "loader" ] []

            NotAsked ->
                text ""

            Failure _ ->
                text ""
        ]


viewItem : Item -> Html Msg
viewItem item =
    li [ class "h-64 w-64 rounded overflow-hidden shadow-lg m-4" ]
        [ a [ href item.link, target "_blank" ]
            [ img [ class "h-64", src item.imgUrl ] []
            ]
        ]



-- MAIN


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = \_ -> Sub.none
        }
