module Messages exposing (Msg(..))

import DigitalOcean exposing (..)
import Http
import Menu
import Models exposing (..)


type Msg
    = ReceiveKeys (Result Http.Error (List SSHKey))
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
    | UpdateDatabasePass String
    | UpdateSecretKey String
    | SetMenuState Menu.Msg
    | SelectTimeZone String
    | SetTZQuery String
