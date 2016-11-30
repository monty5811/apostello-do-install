module Update exposing (update)

import Actions exposing (..)
import DigitalOcean.Models exposing (..)
import Helpers exposing (..)
import Messages exposing (..)
import Models exposing (..)
import Dict


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

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

        UpdateApostelloConfig k v ->
            let
                newConfig =
                    Dict.insert k v model.apostello
            in
                ( { model | apostello = newConfig }, Cmd.none )

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
                    case (dropletIP model) of
                        Just ip ->
                            Deployed

                        Nothing ->
                            Deploying RespOk
            in
                ( { newModel | currentStep = step }, Cmd.none )

        ReceiveDroplet (Err _) ->
            ( model, Cmd.none )
