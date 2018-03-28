module DigitalOcean.Encoders exposing (..)

import Dict
import DigitalOcean.Models exposing (..)
import Http
import Json.Encode as Encode
import Models exposing (ApostelloConfig)


encodeBody : List ( String, Encode.Value ) -> Http.Body
encodeBody data =
    data
        |> Encode.object
        |> Http.jsonBody


encodeKey : SSHKey -> Encode.Value
encodeKey key =
    key.id
        |> toString
        |> Encode.string


createDropletBody : Config -> ApostelloConfig -> Http.Body
createDropletBody config apostello =
    [ ( "name", Encode.string "apostello" )
    , ( "region", Encode.string config.region.slug )
    , ( "size", Encode.string config.size )
    , ( "image", Encode.string "ubuntu-14-04-x64" )
    , ( "ssh_keys", Encode.list (List.map encodeKey config.keys) )
    , ( "backups", Encode.bool False )
    , ( "ipv6", Encode.bool True )
    , ( "user_data", Encode.string (userData apostello) )
    , ( "private_networking", Encode.bool False )
    , ( "volumes", Encode.list [] )
    , ( "tags", Encode.list [] )
    ]
        |> encodeBody


userData : ApostelloConfig -> String
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
       # rollbar
       rollbar_access_token: ''
       rollbar_access_token_client: ''
       cm_server_key:
       cm_sender_id:
    path: /home/apostello/custom_vars.yml
runcmd:
  - cd /home/apostello && curl -sf https://raw.githubusercontent.com/monty5811/apostello/master/scripts/ansible_install.sh | sh
"""
