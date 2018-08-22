module Actions exposing (deployDroplet, fetchAction, fetchData, fetchDropletInfo, fetchRegions, fetchSSHKeys, generateRandomApostelloVal)

import Char exposing (fromCode)
import DigitalOcean exposing (..)
import Http
import Messages exposing (..)
import Models exposing (..)
import Random exposing (Generator, andThen, float, int, list, map)
import String exposing (fromList)


fetchData : Model -> Cmd Msg
fetchData model =
    case model of
        NotAuthed _ ->
            Cmd.none

        Authed aModel ->
            case aModel.currentStep of
                PullData _ ->
                    Cmd.batch
                        [ fetchSSHKeys aModel.accessToken
                        , fetchRegions aModel.accessToken
                        ]

                _ ->
                    Cmd.none


generateRandomApostelloVal : (String -> Msg) -> Cmd Msg
generateRandomApostelloVal tagger =
    Random.generate tagger (string 64 ascii)


deployDroplet : AccessToken -> Config -> ApostelloConfig -> Cmd Msg
deployDroplet accessToken config apostelloConfig =
    Http.send ReceiveCreateResp (postCreateDroplet accessToken config apostelloConfig)


fetchSSHKeys : AccessToken -> Cmd Msg
fetchSSHKeys accessToken =
    Http.send ReceiveKeys (getKeys accessToken)


fetchRegions : AccessToken -> Cmd Msg
fetchRegions accessToken =
    Http.send ReceiveRegions (getRegions accessToken)


fetchAction : AccessToken -> Maybe CreateResp -> Cmd Msg
fetchAction accessToken createResp =
    Http.send ReceiveAction (getAction accessToken createResp)


fetchDropletInfo : AccessToken -> Maybe CreateResp -> Cmd Msg
fetchDropletInfo accessToken createResp =
    Http.send ReceiveDroplet (getDropletInfo accessToken createResp)



-- Copied from random-extra until it is upgraded to 0.19


string : Int -> Generator Char -> Generator String
string stringLength charGenerator =
    map fromList (list stringLength charGenerator)


{-| Generate a random character within a certain keyCode range
lowerCaseLetter = char 65 90
-}
char : Int -> Int -> Generator Char
char start end =
    map fromCode (int start end)


{-| Generate a random ASCII Character
-}
ascii : Generator Char
ascii =
    char 0 127
