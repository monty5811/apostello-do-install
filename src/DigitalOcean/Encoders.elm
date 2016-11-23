module DigitalOcean.Encoders exposing (..)

import DigitalOcean.Models exposing (..)
import Http
import Json.Encode as Encode


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


createDropletBody : Config -> Http.Body
createDropletBody config =
    [ ( "name", Encode.string "apostello" )
    , ( "region", Encode.string config.region.slug )
    , ( "size", Encode.string config.size )
    , ( "image", Encode.string "ubuntu-14-04-x64" )
    , ( "ssh_keys", Encode.list (List.map encodeKey config.keys) )
    , ( "backups", Encode.bool False )
    , ( "ipv6", Encode.bool True )
    , ( "user_data", Encode.string userData )
    , ( "private_networking", Encode.bool False )
    , ( "volumes", Encode.list [] )
    , ( "tags", Encode.list [] )
    ]
        |> encodeBody


userData : String
userData =
    """
#cloud-config
users:
- name: apostello
  groups: sudo
  shell: /bin/bash
  sudo: ['ALL=(ALL) NOPASSWD:ALL']
packages:
- curl
runcmd:
- cd /home/apostello && curl -sf https://raw.githubusercontent.com/monty5811/apostello/master/scripts/ansible_install.sh | sh
    """
