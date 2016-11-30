module DigitalOcean.Api exposing (..)

import DigitalOcean.Decoders exposing (..)
import DigitalOcean.Encoders exposing (..)
import DigitalOcean.Models exposing (..)
import Models exposing (ApostelloConfig)
import Http
import Json.Decode as Decode
import Regex


doRequest : String -> String -> String -> Http.Body -> Decode.Decoder a -> Http.Request a
doRequest method url token body decoder =
    let
        secureUrl =
            url
                |> Regex.replace Regex.All (Regex.regex "http://") (\_ -> "https://")
    in
        Http.request
            { method = method
            , headers =
                [ Http.header "Content-Type" "application/json"
                , Http.header "Authorization" ("Bearer " ++ token)
                ]
            , url = secureUrl
            , body = body
            , expect = Http.expectJson decoder
            , timeout = Nothing
            , withCredentials = True
            }


doGet : String -> Maybe String -> Decode.Decoder a -> Http.Request a
doGet url token decoder =
    doRequest "GET" url (Maybe.withDefault "" token) Http.emptyBody decoder


doPost : String -> Maybe String -> Http.Body -> Decode.Decoder a -> Http.Request a
doPost url token body decoder =
    doRequest "POST" url (Maybe.withDefault "" token) body decoder


getKeys : Maybe String -> Http.Request (List SSHKey)
getKeys token =
    doGet "https://api.digitalocean.com/v2/account/keys" token (Decode.at [ "ssh_keys" ] (Decode.list decodeKey))


getRegions : Maybe String -> Http.Request (List Region)
getRegions token =
    doGet "https://api.digitalocean.com/v2/regions" token (Decode.at [ "regions" ] (Decode.list decodeRegion))


getAction : Maybe String -> Maybe CreateResp -> Http.Request Action
getAction token droplet =
    let
        url =
            case droplet of
                Just d ->
                    d.links.actions
                        |> List.head
                        |> Maybe.withDefault (ActionLink 0 "" "")
                        |> .href

                Nothing ->
                    ""
    in
        doGet url token (Decode.at [ "action" ] actionDecoder)


postCreateDroplet : Maybe String -> Config -> ApostelloConfig -> Http.Request CreateResp
postCreateDroplet token config apostello =
    doPost "https://api.digitalocean.com/v2/droplets" token (createDropletBody config apostello) decodeCreateDropletResp


getDropletInfo : Maybe String -> Maybe CreateResp -> Http.Request Droplet
getDropletInfo token createDropletResp =
    let
        id =
            case createDropletResp of
                Just resp ->
                    toString resp.droplet.id

                Nothing ->
                    ""
    in
        doGet ("https://api.digitalocean.com/v2/droplets/" ++ id) token (Decode.at [ "droplet" ] decodeDroplet)
