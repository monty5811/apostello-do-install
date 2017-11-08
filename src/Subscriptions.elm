module Subscriptions exposing (subscriptions)

import Autocomplete
import Messages exposing (Msg(..))
import Models exposing (..)
import Time exposing (Time, second)


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map SetAutocompleteState Autocomplete.subscription
        , case model.currentStep of
            Deploying RespOk ->
                Time.every (5 * second) (\_ -> CheckActionStatus)

            DeployedNoIp ->
                Time.every (5 * second) (\_ -> CheckDropletStatus)

            _ ->
                Sub.none
        ]
