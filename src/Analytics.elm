module Analytics exposing (Event(..), logEvent)

import Json.Encode as Encode
import Models exposing (Model(..), Step(..))
import Ports exposing (gaEvent)


type Event
    = PageHit Model
    | DropletDeployed


logEvent : Event -> Cmd msg
logEvent event =
    event
        |> convertEvent
        |> Maybe.map encodeEvent
        |> logEventHelp


logEventHelp : Maybe Encode.Value -> Cmd msg
logEventHelp maybeVal =
    case maybeVal of
        Nothing ->
            Cmd.none

        Just val ->
            gaEvent val


encodeEvent : ( String, List ( String, Encode.Value ) ) -> Encode.Value
encodeEvent ( name, params ) =
    Encode.object
        [ ( "name", Encode.string name )
        , ( "params", Encode.object params )
        ]


convertEvent : Event -> Maybe ( String, List ( String, Encode.Value ) )
convertEvent event =
    case event of
        PageHit model ->
            case model of
                NotAuthed _ ->
                    Just ( "LandingPageHit", [] )

                Authed _ ->
                    Just ( "SetupPageHit", [] )

        DropletDeployed ->
            Just ( "DropletDeployed", [] )
