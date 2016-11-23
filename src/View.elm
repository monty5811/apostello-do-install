module View exposing (view)

import DigitalOcean.Models exposing (..)
import Helpers exposing (baseUrl, dropletIP)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onClick)
import Messages exposing (Msg(..))
import Models exposing (..)


view : Model -> Html Msg
view model =
    div []
        [ div [ class "ui grid container", style [ ( "min-height", "100vh" ) ] ]
            [ uiDivider
            , div [ class "centered row" ] [ innerView model ]
            , uiDivider
            ]
        , footer
        ]


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
    case model.currentStep of
        NotLoggedIn ->
            landingView model

        PullData NoResp ->
            pullingDataView model

        PullData RespOk ->
            pullingDataView model

        PullData RespError ->
            errorView model

        ChooseSetup ->
            if List.isEmpty model.sshKeys then
                noKeysView
            else
                setupView model

        Deploying NoResp ->
            deployingView model

        Deploying RespOk ->
            deployingView model

        Deploying RespError ->
            deployErrorView model

        DeployedNoIp ->
            deployingView model

        Deployed ->
            deployedView model


landingView : Model -> Html Msg
landingView model =
    div [ class "ui raised segment ten wide centered column" ]
        [ img [ src "/apostello-logo.svg", style [ ( "height", "5em" ) ] ] []
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
                , href (loginLink model)
                ]
                [ text "Login to Digital Ocean" ]
            ]
        ]


loginLink : Model -> String
loginLink model =
    [ "https://cloud.digitalocean.com/v1/oauth/authorize?client_id="
    , "e6861183e85ec41863a83203df903d2de2e1af690453de126657e65c19c6d547"
    , "&response_type=token&redirect_uri="
    , baseUrl model.url
    , "&scope=read write"
    ]
        |> String.concat


errorView : Model -> Html Msg
errorView model =
    div [ class "ui raised inverted red segment fourteen wide centered column" ]
        [ p [] [ text "Something went wrong when we tried to talk to Digital Ocean :-(" ]
        , p [] [ text "Why don't we try again from the beginning:" ]
        , uiDivider
        , restartButton model
        ]


deployingView : Model -> Html Msg
deployingView model =
    div [ class "ui raised segment eight wide centered column" ]
        [ div [ class "ui active inverted dimmer" ]
            [ div [ class "ui massive text loader" ]
                [ text "Creating your droplet" ]
            ]
        ]


deployErrorView : Model -> Html Msg
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


restartButton : Model -> Html Msg
restartButton model =
    a [ class "ui fluid button", href (baseUrl model.url) ] [ text "Restart" ]


pullingDataView : Model -> Html Msg
pullingDataView model =
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


setupView : Model -> Html Msg
setupView model =
    div
        [ class "ui raised segment" ]
        [ div [ class "ui three column grid" ]
            [ div [ class "centered row" ]
                [ div [ class "column" ] (chooseSSHKeyView model)
                , div [ class "column" ] (chooseRegionView model)
                , div [ class "column" ] (chooseSizeView model)
                ]
            , uiDivider
            , div [ class "centered row" ]
                [ div [ class "ten wide column" ] [ deployButton model ]
                ]
            ]
        ]


deployButton : Model -> Html Msg
deployButton model =
    if List.isEmpty model.config.keys then
        div
            [ class "ui fluid disabled button"
            ]
            [ text "Deploy Now!" ]
    else
        div
            [ class "ui fluid blue button"
            , onClick Deploy
            ]
            [ text "Deploy Now!" ]


chooseSSHKeyView : Model -> List (Html Msg)
chooseSSHKeyView model =
    [ h3 [] [ text "Please choose your SSH key(s)" ]
    , div [ class "ui list" ] (List.map (sshKeyView model.config.keys) model.sshKeys)
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
    div [ class "ui item" ]
        [ div
            [ class (sshLabelClass activeKeys key)
            , onClick (ChooseSSHKey key)
            ]
            [ text key.name ]
        ]


chooseRegionView : Model -> List (Html Msg)
chooseRegionView model =
    [ h3 [] [ text "Choose a region" ]
    , div [ class "ui list" ]
        (List.map (regionView model.config.region) <|
            List.filter (\r -> List.member "metadata" r.features) model.regions
        )
    ]


regionView : Region -> Region -> Html Msg
regionView activeRegion region =
    div []
        [ div
            [ class (labelClass activeRegion region)
            , onClick (ChooseRegion region)
            ]
            [ text region.name ]
        ]


chooseSizeView : Model -> List (Html Msg)
chooseSizeView model =
    [ h3 [] [ text "Choose a droplet size" ]
    , div [ class "ui list" ] (List.map (sizeView model.config.size) model.config.region.sizes)
    ]


sizeView : String -> String -> Html Msg
sizeView activeSize size =
    div [ class "ui item" ]
        [ div
            [ class (labelClass activeSize size)
            , onClick (ChooseSize size)
            ]
            [ text size ]
        ]


deployedView : Model -> Html Msg
deployedView model =
    div [ class "ui raised segment eight wide centered column" ]
        [ h2 [] [ text "Droplet created!" ]
        , p [] [ text "A droplet has been created and apostello is being installed." ]
        , p [] [ text "It may take a few minutes for the install script to complete." ]
        , p []
            [ text "Your instance of apostello will be avaiable at "
            , dropletLink (dropletIP model)
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
                        ++ (Maybe.withDefault "" <|
                                dropletIP model
                           )
                ]
            ]
        ]


dropletLink : Maybe String -> Html Msg
dropletLink ip_ =
    case ip_ of
        Just ip ->
            a [ href ("http://" ++ ip), target "_blank" ] [ text ip ]

        Nothing ->
            div [] []