module Actions exposing (..)

import DigitalOcean.Api exposing (..)
import Http
import Messages exposing (..)
import Models exposing (..)


fetchData : Model -> Cmd Msg
fetchData model =
    case model.currentStep of
        NotLoggedIn ->
            Cmd.none

        PullData _ ->
            Cmd.batch
                [ fetchSSHKeys model
                , fetchRegions model
                ]

        _ ->
            Cmd.none


deployDroplet : Model -> Cmd Msg
deployDroplet model =
    Http.send ReceiveCreateResp (postCreateDroplet model.accessToken model.config)


fetchSSHKeys : Model -> Cmd Msg
fetchSSHKeys model =
    Http.send ReceiveKeys (getKeys model.accessToken)


fetchRegions : Model -> Cmd Msg
fetchRegions model =
    Http.send ReceiveRegions (getRegions model.accessToken)


fetchAction : Model -> Cmd Msg
fetchAction model =
    Http.send ReceiveAction (getAction model.accessToken model.createResp)


fetchDropletInfo : Model -> Cmd Msg
fetchDropletInfo model =
    Http.send ReceiveDroplet (getDropletInfo model.accessToken model.createResp)
