port module Ports exposing (gaEvent)

import Json.Encode exposing (Value)


port gaEvent : Value -> Cmd msg
