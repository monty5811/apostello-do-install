module DigitalOcean.Decoders exposing (..)

import DigitalOcean.Models exposing (..)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required, decode)


decodeKey : Decoder SSHKey
decodeKey =
    decode SSHKey
        |> required "id" Decode.int
        |> required "name" Decode.string


decodeRegion : Decoder Region
decodeRegion =
    decode Region
        |> required "slug" Decode.string
        |> required "name" Decode.string
        |> required "sizes" (Decode.list Decode.string)
        |> required "available" Decode.bool
        |> required "features" (Decode.list Decode.string)


decodeCreateDropletResp : Decoder CreateResp
decodeCreateDropletResp =
    decode CreateResp
        |> required "droplet" decodeDroplet
        |> required "links" decodeLinks


decodeDroplet : Decoder Droplet
decodeDroplet =
    decode Droplet
        |> required "id" Decode.int
        |> required "name" Decode.string
        |> required "status" (Decode.andThen decodeDropletStatus Decode.string)
        |> required "networks" decodeNetworks


decodeNetworks : Decoder Networks
decodeNetworks =
    decode Networks
        |> required "v4" (Decode.list decodeNetwork)
        |> required "v6" (Decode.list decodeNetwork)


decodeNetwork : Decoder Network
decodeNetwork =
    decode Network
        |> required "ip_address" Decode.string


decodeLinks : Decoder DropletLinks
decodeLinks =
    decode DropletLinks
        |> required "actions" (Decode.list decodeActionLink)


decodeActionLink : Decoder ActionLink
decodeActionLink =
    decode ActionLink
        |> required "id" Decode.int
        |> required "rel" Decode.string
        |> required "href" Decode.string


decodeDropletStatus : String -> Decoder DropletStatus
decodeDropletStatus status =
    decode <|
        case status of
            "active" ->
                Active

            "new" ->
                New

            "off" ->
                Off

            "archive" ->
                Archive

            _ ->
                Unknown


actionDecoder : Decoder Action
actionDecoder =
    decode Action
        |> required "id" Decode.int
        |> required "status" (Decode.andThen decodeActionStatus Decode.string)


decodeActionStatus : String -> Decoder ActionStatus
decodeActionStatus status =
    decode <|
        case status of
            "in-progress" ->
                InProgess

            "completed" ->
                Completed

            "errored" ->
                Errored

            _ ->
                UnknownActionStatus
