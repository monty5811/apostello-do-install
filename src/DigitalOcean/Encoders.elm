module DigitalOcean.Encoders exposing (..)

import DigitalOcean.Models exposing (..)
import Models exposing (ApostelloConfig)
import Http
import Json.Encode as Encode
import Dict


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
userData config =
    let
        dbPass =
            Maybe.withDefault "change_me_to_a_long_string" (Dict.get "dbPass" config)

        secretKey =
            Maybe.withDefault "change_me_to_a_long_string" (Dict.get "secretKey" config)

        accountSID =
            Maybe.withDefault "" (Dict.get "accountSID" config)

        authToken =
            Maybe.withDefault "" (Dict.get "authToken" config)

        fromNum =
            Maybe.withDefault "0.04" (Dict.get "fromNum" config)

        sendingCost =
            Maybe.withDefault "" (Dict.get "sendingCost" config)

        emailHost =
            Maybe.withDefault "" (Dict.get "emailHost" config)

        emailUser =
            Maybe.withDefault "" (Dict.get "emailUser" config)

        emailPass =
            Maybe.withDefault "" (Dict.get "emailPass" config)

        email =
            Maybe.withDefault "" (Dict.get "email" config)

        timeZone =
            Maybe.withDefault "Europe/London" (Dict.get "timeZone" config)
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
       db_password: """ ++ dbPass ++ """
       # Nginx settings
       nginx_server_name: "server_name_replace_me"
       # Application Settings
       django_secret_key: """ ++ secretKey ++ """
       # this is used in the account related emails and should match your server settings
       account_default_http_protocol: 'https'
       # Twilio Credentials
       twilio_account_sid: """ ++ accountSID ++ """
       twilio_auth_token: """ ++ authToken ++ """
       twilio_from_num: """ ++ fromNum ++ """
       twilio_sending_cost: """ ++ sendingCost ++ """
       # Whitelisted domains
       whitelisted_login_domains:
       # Email
       django_email_host: """ ++ emailHost ++ """
       django_email_host_user: """ ++ emailUser ++ """
       django_email_host_password: """ ++ emailPass ++ """
       django_from_email: """ ++ email ++ """
       # locale and time zone:
       django_time_zone: """ ++ timeZone ++ """
       # Elvanto
       elvanto_key:
       country_code:
       # Opbeat
       opbeat_organization_id:
       opbeat_app_id:
       opbeat_secret_token:
       opbeat_js_org_id:
       opbeat_js_app_id:
    path: /home/apostello/custom_vars.yml
runcmd:
  - cd /home/apostello && curl -sf https://raw.githubusercontent.com/monty5811/apostello/master/scripts/ansible_install.sh | sh
"""
