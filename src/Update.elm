module Update exposing (update)

import Actions exposing (..)
import Analytics exposing (Event(..), logEvent)
import Dict
import DigitalOcean exposing (..)
import Helpers exposing (..)
import Menu
import Messages exposing (..)
import Models exposing (..)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case model of
        Authed aModel ->
            let
                ( newModel, cmd ) =
                    updateHelp msg aModel
            in
            ( Authed newModel, cmd )

        NotAuthed _ ->
            ( model, Cmd.none )


updateHelp : Msg -> AuthedModel -> ( AuthedModel, Cmd Msg )
updateHelp msg model =
    case msg of
        UpdateDatabasePass pass ->
            let
                apostello =
                    model.apostello

                newApostello =
                    { apostello | dbPass = pass }
            in
            ( { model | apostello = newApostello }, Cmd.none )

        UpdateSecretKey key ->
            let
                apostello =
                    model.apostello

                newApostello =
                    { apostello | secretKey = key }
            in
            ( { model | apostello = newApostello }, Cmd.none )

        ReceiveKeys (Ok keys) ->
            ( { model | sshKeys = keys, currentStep = ChooseSetup }, Cmd.none )

        ReceiveKeys (Err _) ->
            ( { model | currentStep = PullData RespError }, Cmd.none )

        ReceiveRegions (Ok regions) ->
            ( { model | regions = regions }, Cmd.none )

        ReceiveRegions (Err _) ->
            ( { model | currentStep = PullData RespError }, Cmd.none )

        ChooseSSHKey key ->
            let
                config =
                    model.config

                newConfig =
                    { config | keys = addOrRemoveKey config.keys key }
            in
            ( { model | config = newConfig }, Cmd.none )

        ChooseRegion region ->
            let
                config =
                    model.config

                newConfig =
                    { config | region = region, size = "s-1vcpu-1gb" }
            in
            ( { model | config = newConfig }, Cmd.none )

        ChooseSize size ->
            let
                config =
                    model.config

                newConfig =
                    { config | size = size }
            in
            ( { model | config = newConfig }, Cmd.none )

        SetTZQuery str ->
            let
                apostello =
                    model.apostello

                newApostello =
                    { apostello
                        | tzQuery = str
                        , selectedTimeZone = Nothing
                        , numToShow =
                            if String.length str == 0 then
                                0

                            else
                                10
                    }
            in
            ( { model | apostello = newApostello }, Cmd.none )

        SelectTimeZone tz ->
            let
                apostello =
                    model.apostello

                newApostello =
                    { apostello
                        | selectedTimeZone = Just tz
                        , numToShow = 0
                        , autoState = Menu.empty
                    }
            in
            ( { model | apostello = newApostello }, Cmd.none )

        SetMenuState autoMsg ->
            let
                ( newState, maybeMsg ) =
                    Menu.update
                        autoCompleteConfig
                        autoMsg
                        model.apostello.numToShow
                        model.apostello.autoState
                        (acceptableTimeZones model.apostello.tzQuery timezones)

                apostello =
                    model.apostello

                newApostello =
                    { apostello | autoState = newState }

                newModel =
                    { model | apostello = newApostello }
            in
            case maybeMsg of
                Nothing ->
                    ( newModel, Cmd.none )

                Just updateMsg ->
                    updateHelp updateMsg newModel

        Deploy ->
            ( { model | currentStep = Deploying NoResp }
            , Cmd.batch
                [ deployDroplet model.accessToken model.config model.apostello
                , logEvent DropletDeployed
                ]
            )

        ReceiveCreateResp (Ok resp) ->
            ( { model | createResp = Just resp, currentStep = Deploying RespOk }, Cmd.none )

        ReceiveCreateResp (Err _) ->
            ( { model | createResp = Nothing, currentStep = Deploying RespError }, Cmd.none )

        CheckActionStatus ->
            ( model, fetchAction model.accessToken model.createResp )

        ReceiveAction (Ok action) ->
            ( { model | createAction = Just action, currentStep = action2Step action }, fetchDropletInfo model.accessToken model.createResp )

        ReceiveAction (Err _) ->
            ( { model | createAction = Nothing, currentStep = Deploying RespError }, Cmd.none )

        CheckDropletStatus ->
            ( model, fetchDropletInfo model.accessToken model.createResp )

        ReceiveDroplet (Ok droplet) ->
            let
                resp =
                    model.createResp

                newResp =
                    case resp of
                        Just r ->
                            Just { r | droplet = droplet }

                        Nothing ->
                            Nothing

                newModel =
                    { model | createResp = newResp }

                step =
                    case dropletIP model of
                        Just ip ->
                            Deployed ip

                        Nothing ->
                            Deploying RespOk
            in
            ( { newModel | currentStep = step }, Cmd.none )

        ReceiveDroplet (Err _) ->
            ( model, Cmd.none )


autoCompleteConfig : Menu.UpdateConfig Msg String
autoCompleteConfig =
    Menu.updateConfig
        { toId = identity
        , onKeyDown =
            \code maybeId ->
                if code == 13 then
                    Maybe.map SelectTimeZone maybeId

                else
                    Nothing
        , onTooLow = Nothing
        , onTooHigh = Nothing
        , onMouseEnter = \_ -> Nothing
        , onMouseLeave = \_ -> Nothing
        , onMouseClick = \id -> Just <| SelectTimeZone id
        , separateSelections = False
        }


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
