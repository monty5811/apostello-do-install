module Models
    exposing
        ( ApostelloConfig
        , Flags
        , Model
        , RespStatus(NoResp, RespError, RespOk)
        , Step(ChooseSetup, Deployed, DeployedNoIp, Deploying, NotLoggedIn, PullData)
        )

import Autocomplete
import Dict
import DigitalOcean.Models
    exposing
        ( Action
        , Config
        , CreateResp
        , IPAddress
        , Region
        , SSHKey
        )


type Step
    = NotLoggedIn
    | PullData RespStatus
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
    , autoState : Autocomplete.State
    , numToShow : Int
    , timezones : List String
    , selectedTimeZone : Maybe String
    , dbPass : String
    , secretKey : String
    }


type alias Model =
    { url : String
    , accessToken : Maybe String
    , sshKeys : List SSHKey
    , regions : List Region
    , config : Config
    , createResp : Maybe CreateResp
    , createAction : Maybe Action
    , currentStep : Step
    , apostello : ApostelloConfig
    }


type alias Flags =
    { url : String
    }
