module Models exposing (..)

import DigitalOcean.Models exposing (..)


type Step
    = NotLoggedIn
    | PullData RespStatus
    | ChooseSetup
    | Deploying RespStatus
    | DeployedNoIp
    | Deployed


type RespStatus
    = NoResp
    | RespError
    | RespOk


type alias Model =
    { url : String
    , accessToken : Maybe String
    , sshKeys : List SSHKey
    , regions : List Region
    , config : Config
    , createResp : Maybe CreateResp
    , createAction : Maybe Action
    , currentStep : Step
    }


type alias Flags =
    { url : String
    }
