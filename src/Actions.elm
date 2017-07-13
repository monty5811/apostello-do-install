module Actions exposing (..)

import DigitalOcean.Api exposing (..)
import Http
import Messages exposing (..)
import Models exposing (..)
import Random
import Random.Char
import Random.String


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


generateRandomApostelloVal : String -> Cmd Msg
generateRandomApostelloVal field =
    Random.generate (UpdateApostelloConfig field) (Random.String.string 64 Random.Char.english)


deployDroplet : Model -> Cmd Msg
deployDroplet model =
    Http.send ReceiveCreateResp (postCreateDroplet model.accessToken model.config model.apostello)


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
