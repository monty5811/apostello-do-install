module Main exposing (init, main)

import Actions exposing (fetchData, generateRandomApostelloVal)
import Analytics exposing (Event(..), logEvent)
import Browser
import DigitalOcean exposing (..)
import Helpers exposing (baseUrl, timezones)
import Menu
import Messages exposing (Msg(..))
import Models exposing (..)
import Regex
import Subscriptions exposing (subscriptions)
import Update exposing (update)
import View exposing (view)


main : Program Flags Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        model =
            initialModel flags
    in
    ( model
    , Cmd.batch
        [ fetchData model
        , generateRandomApostelloVal UpdateDatabasePass
        , generateRandomApostelloVal UpdateSecretKey
        , logEvent (PageHit model)
        ]
    )


initialModel : Flags -> Model
initialModel flags =
    let
        maybeToken =
            parseAccessToken flags.url
    in
    case maybeToken of
        Nothing ->
            NotAuthed flags.url

        Just token ->
            Authed
                { url = flags.url
                , sshKeys = []
                , regions = []
                , config =
                    { region = defaultRegion
                    , keys = []
                    , size = ""
                    }
                , createResp = Nothing
                , createAction = Nothing
                , currentStep = PullData NoResp
                , apostello = initialApostelloConfig
                , accessToken = token
                }


initialApostelloConfig : ApostelloConfig
initialApostelloConfig =
    { tzQuery = ""
    , autoState = Menu.empty
    , numToShow = 0
    , timezones = timezones
    , selectedTimeZone = Nothing
    , dbPass = "change_me_to_a_long_string"
    , secretKey = "change_me_to_a_long_string"
    }


accessTokenRe : Regex.Regex
accessTokenRe =
    Maybe.withDefault Regex.never <|
        Regex.fromString "access_token=([^&]*)"


parseAccessToken : String -> Maybe AccessToken
parseAccessToken url =
    let
        match =
            Regex.find accessTokenRe url
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
    Maybe.map (accessToken <| baseUrl url) token
