module DigitalOcean exposing
    ( AccessToken
    , Action
    , ActionLink
    , ActionStatus(..)
    , Config
    , CreateResp
    , Droplet
    , DropletLinks
    , DropletStatus(..)
    , IPAddress(..)
    , Network
    , Networks
    , Region
    , SSHKey
    , accessToken
    , defaultRegion
    , getAction
    , getDropletInfo
    , getKeys
    , getRegions
    , postCreateDroplet
    )

import Dict
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode


type alias Config =
    { region : Region
    , keys : List SSHKey
    , size : String
    }


type alias SSHKey =
    { id : Int
    , name : String
    }


type alias Region =
    { slug : String
    , name : String
    , sizes : List String
    , avaiable : Bool
    , features : List String
    }


defaultRegion : Region
defaultRegion =
    Region "lon1" "London 1" [ "1gb", "2gb", "4gb", "8gb", "16gb", "m-16gb", "32gb", "m-32gb", "48gb", "m-64gb", "64gb", "m-128gb", "m-224gb" ] True [ "private_networking", "backups", "ipv6", "metadata" ]


type alias Networks =
    { v4 : List Network
    , v6 : List Network
    }


type alias Network =
    { ip_address : IPAddress }


type IPAddress
    = IPAddress String


type DropletStatus
    = Off
    | Archive
    | New
    | Active
    | Unknown


type alias CreateResp =
    { droplet : Droplet
    , links : DropletLinks
    }


type alias Droplet =
    { id : Int
    , name : String
    , status : DropletStatus
    , networks : Networks
    }


type alias DropletLinks =
    { actions : List ActionLink
    }


type alias ActionLink =
    { id : Int
    , rel : String
    , href : String
    }


type ActionStatus
    = InProgess
    | Completed
    | Errored
    | UnknownActionStatus


type alias Action =
    { id : Int
    , status : ActionStatus
    }



-- API


type AccessToken
    = AccessToken String String


accessToken : String -> String -> AccessToken
accessToken hostUrl token =
    AccessToken hostUrl token


doRequest : String -> String -> AccessToken -> Http.Body -> Decode.Decoder a -> Http.Request a
doRequest method url (AccessToken hostUrl token) body decoder =
    let
        secureUrl =
            url
                |> String.replace "http://" "https://"
    in
    Http.request
        { method = method
        , headers =
            [ Http.header "Content-Type" "application/json"
            , Http.header "Authorization" ("Bearer " ++ token)
            , Http.header "Origin" hostUrl
            ]
        , url = secureUrl
        , body = body
        , expect = Http.expectJson decoder
        , timeout = Nothing
        , withCredentials = True
        }


doGet : String -> AccessToken -> Decode.Decoder a -> Http.Request a
doGet url token decoder =
    doRequest "GET" url token Http.emptyBody decoder


doPost : String -> AccessToken -> Http.Body -> Decode.Decoder a -> Http.Request a
doPost url token body decoder =
    doRequest "POST" url token body decoder


getKeys : AccessToken -> Http.Request (List SSHKey)
getKeys token =
    doGet "https://api.digitalocean.com/v2/account/keys" token (Decode.at [ "ssh_keys" ] (Decode.list decodeKey))


getRegions : AccessToken -> Http.Request (List Region)
getRegions token =
    doGet "https://api.digitalocean.com/v2/regions" token (Decode.at [ "regions" ] (Decode.list decodeRegion))


getAction : AccessToken -> Maybe CreateResp -> Http.Request Action
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


postCreateDroplet : AccessToken -> Config -> { a | selectedTimeZone : Maybe String, dbPass : String, secretKey : String } -> Http.Request CreateResp
postCreateDroplet token config apostello =
    doPost "https://api.digitalocean.com/v2/droplets" token (createDropletBody config apostello) decodeCreateDropletResp


getDropletInfo : AccessToken -> Maybe CreateResp -> Http.Request Droplet
getDropletInfo token createDropletResp =
    let
        id =
            case createDropletResp of
                Just resp ->
                    String.fromInt resp.droplet.id

                Nothing ->
                    ""
    in
    doGet ("https://api.digitalocean.com/v2/droplets/" ++ id) token (Decode.at [ "droplet" ] decodeDroplet)



-- Decoders


decodeKey : Decoder SSHKey
decodeKey =
    Decode.succeed SSHKey
        |> required "id" Decode.int
        |> required "name" Decode.string


decodeRegion : Decoder Region
decodeRegion =
    Decode.succeed Region
        |> required "slug" Decode.string
        |> required "name" Decode.string
        |> required "sizes" (Decode.list Decode.string)
        |> required "available" Decode.bool
        |> required "features" (Decode.list Decode.string)


decodeCreateDropletResp : Decoder CreateResp
decodeCreateDropletResp =
    Decode.succeed CreateResp
        |> required "droplet" decodeDroplet
        |> required "links" decodeLinks


decodeDroplet : Decoder Droplet
decodeDroplet =
    Decode.succeed Droplet
        |> required "id" Decode.int
        |> required "name" Decode.string
        |> required "status" (Decode.andThen decodeDropletStatus Decode.string)
        |> required "networks" decodeNetworks


decodeNetworks : Decoder Networks
decodeNetworks =
    Decode.succeed Networks
        |> required "v4" (Decode.list decodeNetwork)
        |> required "v6" (Decode.list decodeNetwork)


decodeNetwork : Decoder Network
decodeNetwork =
    Decode.succeed Network
        |> required "ip_address" (Decode.string |> Decode.andThen (\t -> Decode.succeed (IPAddress t)))


decodeLinks : Decoder DropletLinks
decodeLinks =
    Decode.succeed DropletLinks
        |> required "actions" (Decode.list decodeActionLink)


decodeActionLink : Decoder ActionLink
decodeActionLink =
    Decode.succeed ActionLink
        |> required "id" Decode.int
        |> required "rel" Decode.string
        |> required "href" Decode.string


decodeDropletStatus : String -> Decoder DropletStatus
decodeDropletStatus status =
    Decode.succeed <|
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
    Decode.succeed Action
        |> required "id" Decode.int
        |> required "status" (Decode.andThen decodeActionStatus Decode.string)


decodeActionStatus : String -> Decoder ActionStatus
decodeActionStatus status =
    Decode.succeed <|
        case status of
            "in-progress" ->
                InProgess

            "completed" ->
                Completed

            "errored" ->
                Errored

            _ ->
                UnknownActionStatus



-- Encoders


encodeBody : List ( String, Encode.Value ) -> Http.Body
encodeBody data =
    data
        |> Encode.object
        |> Http.jsonBody


encodeKey : SSHKey -> Encode.Value
encodeKey key =
    key.id
        |> String.fromInt
        |> Encode.string


createDropletBody : Config -> { a | selectedTimeZone : Maybe String, dbPass : String, secretKey : String } -> Http.Body
createDropletBody config apostello =
    [ ( "name", Encode.string "apostello" )
    , ( "region", Encode.string config.region.slug )
    , ( "size", Encode.string config.size )
    , ( "image", Encode.string "ubuntu-14-04-x64" )
    , ( "ssh_keys", Encode.list encodeKey config.keys )
    , ( "backups", Encode.bool False )
    , ( "ipv6", Encode.bool True )
    , ( "user_data", Encode.string (userData apostello) )
    , ( "private_networking", Encode.bool False )
    , ( "volumes", Encode.list Encode.string [] )
    , ( "tags", Encode.list Encode.string [] )
    ]
        |> encodeBody


userData : { a | selectedTimeZone : Maybe String, dbPass : String, secretKey : String } -> String
userData apostello =
    let
        tz =
            Maybe.withDefault "Europe/London" apostello.selectedTimeZone
    in
    """#cloud-config
users:
  - name: apostello
    groups: sudo
    shell: /bin/bash
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
packages:
  - curl
write_files:
  - content: |
       ---
       # Let's Encrypt (free SSL):
       le_email: ''
       # Database settings
       db_password: """ ++ apostello.dbPass ++ """
       # Nginx settings
       nginx_server_name: "server_name_replace_me"
       # Application Settings
       django_secret_key: """ ++ apostello.secretKey ++ """
       # this is used in the account related emails and should match your server settings
       account_default_http_protocol: 'https'
       # Whitelisted domains
       whitelisted_login_domains:
       # locale and time zone:
       django_time_zone: """ ++ tz ++ """
       # Elvanto
       elvanto_key:
       country_code:
       # Opbeat
       opbeat_organization_id:
       opbeat_app_id:
       opbeat_secret_token:
       opbeat_js_org_id:
       opbeat_js_app_id:
       cm_server_key:
       cm_sender_id:
    path: /home/apostello/custom_vars.yml
runcmd:
  - cd /home/apostello && curl -sf https://raw.githubusercontent.com/monty5811/apostello/master/scripts/ansible_install.sh | sh
"""
