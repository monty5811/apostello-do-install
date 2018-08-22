module Models exposing
    ( ApostelloConfig
    , AuthedModel
    , Flags
    , Model(..)
    , RespStatus(..)
    , Step(..)
    )

import Dict
import DigitalOcean exposing (..)
import Menu


type Step
    = PullData RespStatus
    | ChooseSetup
    | Deploying RespStatus
    | DeployedNoIp
    | Deployed IPAddress


type RespStatus
    = NoResp
    | RespError
    | RespOk


type alias ApostelloConfig =
    { tzQuery : String
    , autoState : Menu.State
    , numToShow : Int
    , timezones : List String
    , selectedTimeZone : Maybe String
    , dbPass : String
    , secretKey : String
    }


type Model
    = NotAuthed String
    | Authed AuthedModel


type alias AuthedModel =
    { url : String
    , sshKeys : List SSHKey
    , regions : List Region
    , config : Config
    , createResp : Maybe CreateResp
    , createAction : Maybe Action
    , currentStep : Step
    , apostello : ApostelloConfig
    , accessToken : AccessToken
    }


type alias Flags =
    { url : String
    }
