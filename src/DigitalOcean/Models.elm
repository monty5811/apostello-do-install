module DigitalOcean.Models exposing (..)


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
    Region "lon1" "London 1" [ "512mb", "1gb", "2gb", "4gb", "8gb", "16gb", "m-16gb", "32gb", "m-32gb", "48gb", "m-64gb", "64gb", "m-128gb", "m-224gb" ] True [ "private_networking", "backups", "ipv6", "metadata" ]


type alias Networks =
    { v4 : List Network
    , v6 : List Network
    }


type alias Network =
    { ip_address : String }


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
