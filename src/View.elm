module View exposing (view)

import Browser
import DigitalOcean exposing (..)
import Helpers exposing (acceptableTimeZones, baseUrl, dropletIP)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Menu
import Messages exposing (Msg(..))
import Models exposing (..)


view : Model -> Browser.Document Msg
view model =
    { title = "apostello installer"
    , body =
        [ div [ class "ui grid container", style "min-height" "100vh" ]
            [ uiDivider
            , div [ class "centered row" ] [ innerView model ]
            , uiDivider
            ]
        , footer
        ]
    }


uiDivider : Html Msg
uiDivider =
    div [ class "ui hidden divider" ] []


footer : Html Msg
footer =
    div [ class "ui inverted vertical footer segment" ]
        [ div [ class "ui center aligned container" ]
            [ div [ class "ui stackable inverted divided grid" ]
                [ div [ class "eight wide column" ]
                    [ div [ class "ui inverted link list" ]
                        [ div [ class "item" ] [ a [ href "https://github.com/monty5811/apostello" ] [ text "apostello" ] ]
                        , div [ class "item" ] [ a [ href "https://apostello.readthedocs.io" ] [ text "Documentation" ] ]
                        , div [ class "item" ] [ a [ href "http://chat.church.io" ] [ text "Chat" ] ]
                        , div [ class "item" ] [ a [ href "https://github.com/monty5811/apostello-do-install" ] [ text "Source" ] ]
                        ]
                    ]
                , div [ class "eight wide column" ]
                    [ div [ class "ui inverted link list" ]
                        [ div [ class "item" ] [ text "Warning: this is experimental. You should check your Digital Ocean droplet list after using this tool as creating droplets will result in you being charged by Digital Ocean." ]
                        , a [ class "item", href "https://github.com/monty5811/apostello-do-install/blob/master/LICENSE", target "_blank" ] [ text "MIT License" ]
                        ]
                    ]
                ]
            ]
        ]


innerView : Model -> Html Msg
innerView model =
    case model of
        NotAuthed url ->
            landingView url

        Authed aModel ->
            case aModel.currentStep of
                PullData NoResp ->
                    pullingDataView

                PullData RespOk ->
                    pullingDataView

                PullData RespError ->
                    errorView aModel

                ChooseSetup ->
                    if List.isEmpty aModel.sshKeys then
                        noKeysView

                    else
                        setupView aModel

                Deploying NoResp ->
                    deployingView

                Deploying RespOk ->
                    deployingView

                Deploying RespError ->
                    deployErrorView aModel

                DeployedNoIp ->
                    deployingView

                Deployed ip ->
                    deployedView ip


landingView : String -> Html Msg
landingView url =
    div [ class "ui raised segment ten wide centered column" ]
        [ img [ src "/static/apostello-logo.svg", style "height" "5em" ] []
        , h1 [] [ text "apostello installer for Digital Ocean" ]
        , p [] [ text "Install apostello on Digital Ocean in just a few minutes." ]
        , uiDivider
        , p []
            [ a
                [ class "ui large blue button"
                , href "https://m.do.co/c/4afdc8b5be2e"
                , target "_blank"
                ]
                [ text "Create a Digital Ocean Account" ]
            , text "  or  "
            , a
                [ class "ui large green button"
                , href (loginLink url)
                ]
                [ text "Login to Digital Ocean" ]
            ]
        ]


loginLink : String -> String
loginLink url =
    [ "https://cloud.digitalocean.com/v1/oauth/authorize?client_id="
    , "e6861183e85ec41863a83203df903d2de2e1af690453de126657e65c19c6d547"
    , "&response_type=token&redirect_uri="
    , baseUrl url
    , "&scope=read write"
    ]
        |> String.concat


errorView : AuthedModel -> Html Msg
errorView model =
    div [ class "ui raised inverted red segment fourteen wide centered column" ]
        [ p [] [ text "Something went wrong when we tried to talk to Digital Ocean :-(" ]
        , p [] [ text "Why don't we try again from the beginning:" ]
        , uiDivider
        , restartButton model
        ]


deployingView : Html msg
deployingView =
    div [ class "ui raised segment eight wide centered column" ]
        [ div [ class "ui active inverted dimmer" ]
            [ div [ class "ui massive text loader" ]
                [ text "Creating your droplet" ]
            ]
        ]


deployErrorView : AuthedModel -> Html Msg
deployErrorView model =
    div [ class "ui raised inverted red segment fourteen wide centered column" ]
        [ p [] [ text "Something went wrong when we tried to talk to Digital Ocean :-(" ]
        , p [] [ text "Your droplet may have been setup correctly, we just don't know" ]
        , uiDivider
        , p [] [ text "You should check your Digital Ocean ", a [ href "https://cloud.digitalocean.com/droplets" ] [ text "Dashboard" ], text "." ]
        , uiDivider
        , p [] [ text "If you don't see apostello there, you can try again:" ]
        , restartButton model
        ]


restartButton : AuthedModel -> Html Msg
restartButton model =
    a [ class "ui fluid button", href (baseUrl model.url) ] [ text "Restart" ]


pullingDataView : Html msg
pullingDataView =
    div [ class "ui raised segment eight wide centered column" ]
        [ div [ class "ui active inverted dimmer" ]
            [ div [ class "ui large text loader" ]
                [ text "Contacting Digital Ocean" ]
            ]
        ]


noKeysView : Html Msg
noKeysView =
    div [ class "ui raised segment fourteen wide centered column" ]
        [ p []
            [ text "You don't have any ssh keys, please add som to your account: "
            , a [ href "https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys--2", target "_blank" ] [ text "How to setup SSH Keys" ]
            , text "."
            ]
        , uiDivider
        , p [] [ text "Once you have setup your SSH keys, just refresh this page :-)" ]
        ]


setupView : AuthedModel -> Html Msg
setupView model =
    div []
        [ div
            [ class "ui raised segment" ]
            [ div []
                [ div [ class "centered row" ]
                    [ h2 [] [ text "Digital Ocean Options" ]
                    , div [ class "ui three column grid" ]
                        [ div [ class "column" ] (chooseSSHKeyView model)
                        , div [ class "column" ] (chooseRegionView model)
                        , div [ class "column" ] (chooseSizeView model)
                        ]
                    ]
                , uiDivider
                ]
            ]
        , div [ class "ui raised segment" ]
            [ h2 [] [ text "apostello Configuration" ]
            , div [ class "centered row" ]
                [ apostelloSetup model.apostello
                ]
            , uiDivider
            ]
        , div [ class "ui raised segment" ]
            [ div [ class "centered row" ]
                [ div [] [ deployButton model ]
                ]
            ]
        ]


apostelloFormHelp : Html msg
apostelloFormHelp =
    p [] [ text "We need to know your time zone to deploy apostello." ]


apostelloSetup : ApostelloConfig -> Html Msg
apostelloSetup config =
    div [ class "twelve wide column" ]
        [ Html.div [ class "ui equal width form" ]
            [ apostelloFormHelp
            , div [ class "fields" ] [ tzField config ]
            ]
        ]


tzField : ApostelloConfig -> Html Msg
tzField { numToShow, autoState, tzQuery, timezones, selectedTimeZone } =
    div [ class "field" ]
        [ label [] [ text "Time Zone" ]
        , input
            [ onInput SetTZQuery
            , value <| tzFieldValue tzQuery selectedTimeZone
            ]
            []
        , Html.map SetMenuState
            (Menu.view autoCompleteConfig
                numToShow
                autoState
                (acceptableTimeZones tzQuery timezones)
            )
        ]


tzFieldValue : String -> Maybe String -> String
tzFieldValue query selectedTimeZone =
    case selectedTimeZone of
        Just tz ->
            tz

        Nothing ->
            query


autoCompleteConfig : Menu.ViewConfig String
autoCompleteConfig =
    let
        customizedLi keySelected mouseSelected tz =
            { attributes =
                [ classList
                    [ ( "autocomplete-item", True )
                    , ( "is-selected", keySelected || mouseSelected )
                    ]
                ]
            , children = [ Html.text tz ]
            }
    in
    Menu.viewConfig
        { toId = identity
        , ul = [ class "autocomplete-list" ]
        , li = customizedLi -- given selection states and a person, create some Html!
        }


deployButton : AuthedModel -> Html Msg
deployButton { config, apostello } =
    if List.isEmpty config.keys || String.isEmpty config.size || isNothing apostello.selectedTimeZone then
        disabledDeployButton

    else
        div
            [ class "ui fluid blue button"
            , onClick Deploy
            ]
            [ text "Deploy Now!" ]


disabledDeployButton : Html msg
disabledDeployButton =
    div
        [ class "ui fluid disabled button"
        ]
        [ text "Deploy Now!" ]


isNothing : Maybe a -> Bool
isNothing maybe =
    case maybe of
        Nothing ->
            True

        Just _ ->
            False


chooseSSHKeyView : AuthedModel -> List (Html Msg)
chooseSSHKeyView model =
    [ h3 [] [ text "Please choose your SSH key(s)" ]
    , div [] (List.map (sshKeyView model.config.keys) model.sshKeys)
    ]


sshLabelClass : List SSHKey -> SSHKey -> String
sshLabelClass list key =
    if List.member key list then
        "ui green label"

    else
        "ui label"


labelClass : a -> a -> String
labelClass active current =
    if current == active then
        "ui green label"

    else
        "ui label"


sshKeyView : List SSHKey -> SSHKey -> Html Msg
sshKeyView activeKeys key =
    div
        [ class (sshLabelClass activeKeys key)
        , onClick (ChooseSSHKey key)
        ]
        [ text key.name ]


chooseRegionView : AuthedModel -> List (Html Msg)
chooseRegionView model =
    [ h3 [] [ text "Choose a region" ]
    , div []
        (List.map (regionView model.config.region) <|
            List.filter (\r -> List.member "metadata" r.features) model.regions
        )
    ]


regionView : Region -> Region -> Html Msg
regionView activeRegion region =
    div
        [ class (labelClass activeRegion region)
        , onClick (ChooseRegion region)
        ]
        [ text region.name ]


chooseSizeView : AuthedModel -> List (Html Msg)
chooseSizeView model =
    let
        selectedSize =
            model.config.size

        allSizes =
            model.config.region.sizes
    in
    [ h3 [] [ text "Choose a droplet size" ]
    , div [] (List.map (sizeView selectedSize) allSizes)
    ]


sizeView : String -> String -> Html Msg
sizeView activeSize size =
    div
        [ class (labelClass activeSize size)
        , onClick (ChooseSize size)
        ]
        [ text size ]


deployedView : IPAddress -> Html Msg
deployedView (IPAddress ip) =
    div [ class "ui raised segment eight wide centered column" ]
        [ h2 [] [ text "Droplet created!" ]
        , p [] [ text "A droplet has been created and apostello is being installed." ]
        , p [] [ text "It may take a few minutes for the install script to set up the server." ]
        , p []
            [ text "Your instance of apostello will be avaiable at "
            , a [ href ("http://" ++ ip), target "_blank" ] [ text ip ]
            ]
        , p []
            [ text "Please look at the "
            , a [ href "https://apostello.readthedocs.io/en/latest/deploy_do.html#configuration", target "_blank" ]
                [ text "getting started"
                ]
            , text " documentation so you can finish the setup."
            ]
        , uiDivider
        , p []
            [ text "SSH access: "
            , pre []
                [ text <|
                    "ssh root@"
                        ++ ip
                ]
            ]
        , p []
            [ text "You can monitor the progress by running this command:"
            , pre []
                [ text <|
                    "ssh root@"
                        ++ ip
                        ++ " tail -f /var/log/cloud-init-output.log"
                ]
            ]
        ]
