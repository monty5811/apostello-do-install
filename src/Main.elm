module Main exposing (..)

import Actions exposing (fetchData, generateRandomApostelloVal)
import Helpers exposing (initialModel)
import Html exposing (programWithFlags)
import Messages exposing (Msg(..))
import Models exposing (Flags, Model)
import Subscriptions exposing (subscriptions)
import Update exposing (update)
import View exposing (view)


main : Program Flags Model Msg
main =
    programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        model =
            initialModel flags
    in
    ( model
    , Cmd.batch
        [ fetchData model
        , generateRandomApostelloVal "dbPass"
        , generateRandomApostelloVal "secretKey"
        ]
    )
