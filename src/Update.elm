module Update exposing (update)

import Actions exposing (..)
import Autocomplete
import Dict
import DigitalOcean.Models exposing (..)
import Helpers exposing (..)
import Messages exposing (..)
import Models exposing (..)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

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

        FetchSSHKeys ->
            ( { model | currentStep = PullData NoResp }, fetchSSHKeys model )

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
                    { config | keys = addOrRemoveKey model.config.keys key }
            in
            ( { model | config = newConfig }, Cmd.none )

        ChooseRegion region ->
            let
                config =
                    model.config

                newConfig =
                    { config | region = region, size = "512mb" }
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
                        , autoState = Autocomplete.empty
                    }
            in
            ( { model | apostello = newApostello }, Cmd.none )

        SetAutocompleteState autoMsg ->
            let
                ( newState, maybeMsg ) =
                    Autocomplete.update
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
                    update updateMsg newModel

        Deploy ->
            ( { model | currentStep = Deploying NoResp }, deployDroplet model )

        ReceiveCreateResp (Ok resp) ->
            ( { model | createResp = Just resp, currentStep = Deploying RespOk }, Cmd.none )

        ReceiveCreateResp (Err _) ->
            ( { model | createResp = Nothing, currentStep = Deploying RespError }, Cmd.none )

        CheckActionStatus ->
            ( model, fetchAction model )

        ReceiveAction (Ok action) ->
            ( { model | createAction = Just action, currentStep = action2Step action }, fetchDropletInfo model )

        ReceiveAction (Err _) ->
            ( { model | createAction = Nothing, currentStep = Deploying RespError }, Cmd.none )

        CheckDropletStatus ->
            ( model, fetchDropletInfo model )

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


autoCompleteConfig : Autocomplete.UpdateConfig Msg String
autoCompleteConfig =
    Autocomplete.updateConfig
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
