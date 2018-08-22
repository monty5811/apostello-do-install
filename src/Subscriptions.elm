module Subscriptions exposing (subscriptions)

import Menu
import Messages exposing (Msg(..))
import Models exposing (..)
import Time


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map SetMenuState Menu.subscription
        , case model of
            NotAuthed _ ->
                Sub.none

            Authed aModel ->
                case aModel.currentStep of
                    Deploying RespOk ->
                        Time.every 5000 (\_ -> CheckActionStatus)

                    DeployedNoIp ->
                        Time.every 5000 (\_ -> CheckDropletStatus)

                    _ ->
                        Sub.none
        ]
