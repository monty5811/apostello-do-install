module Helpers exposing (..)

import DigitalOcean.Models exposing (..)
import Models exposing (Flags, Model, Step(..), RespStatus(..))
import Regex


initialModel : Flags -> Model
initialModel flags =
    let
        ( step, token ) =
            parseAccessToken flags.url
    in
        { url = flags.url
        , accessToken = token
        , sshKeys = []
        , regions = []
        , config =
            { region = defaultRegion
            , keys = []
            , size = "512mb"
            }
        , createResp = Nothing
        , createAction = Nothing
        , currentStep = step
        }


baseUrl : String -> String
baseUrl url =
    url
        |> String.split "#"
        |> List.head
        |> Maybe.withDefault url


parseAccessToken : String -> ( Step, Maybe String )
parseAccessToken url =
    let
        match =
            Regex.find (Regex.AtMost 1) (Regex.regex "access_token=([^&]*)") url
                |> List.head

        token =
            case match of
                Just m ->
                    m.submatches
                        |> List.head
                        |> Maybe.withDefault Nothing

                Nothing ->
                    Nothing
    in
        case token of
            Just t ->
                ( PullData NoResp, token )

            Nothing ->
                ( NotLoggedIn, token )


addOrRemoveKey : List SSHKey -> SSHKey -> List SSHKey
addOrRemoveKey keys key =
    if List.member key keys then
        List.filter (\k -> not (k.id == key.id)) keys
    else
        key :: keys


action2Step : Action -> Step
action2Step action =
    case action.status of
        InProgess ->
            Deploying RespOk

        Completed ->
            DeployedNoIp

        Errored ->
            Deploying RespError

        UnknownActionStatus ->
            Deploying RespOk


dropletV4 : Model -> Maybe Network
dropletV4 model =
    case model.createResp of
        Just resp ->
            resp.droplet.networks.v4
                |> List.head

        Nothing ->
            Nothing


dropletIP : Model -> Maybe String
dropletIP model =
    let
        network =
            dropletV4 model
    in
        case network of
            Just net ->
                Just net.ip_address

            Nothing ->
                Nothing
