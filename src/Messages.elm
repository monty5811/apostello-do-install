module Messages exposing (..)

import DigitalOcean.Models exposing (..)
import Http
import Models exposing (..)


type Msg
    = NoOp
    | FetchSSHKeys
    | ReceiveKeys (Result Http.Error (List SSHKey))
    | ReceiveRegions (Result Http.Error (List Region))
    | ChooseRegion Region
    | ChooseSize String
    | ChooseSSHKey SSHKey
    | Deploy
    | ReceiveCreateResp (Result Http.Error CreateResp)
    | CheckActionStatus
    | ReceiveAction (Result Http.Error Action)
    | CheckDropletStatus
    | ReceiveDroplet (Result Http.Error Droplet)
