module Helpers exposing (..)

import Autocomplete
import DigitalOcean.Models exposing (..)
import Models exposing (..)
import Regex


initialModel : Flags -> Model
initialModel flags =
    let
        ( step, token ) =
            parseAccessToken flags.url
    in
    { url = flags.url
    , accessToken = token
    , sshKeys = []
    , regions = []
    , config =
        { region = defaultRegion
        , keys = []
        , size = "512mb"
        }
    , createResp = Nothing
    , createAction = Nothing
    , currentStep = step
    , apostello = initialApostelloConfig
    }


initialApostelloConfig : ApostelloConfig
initialApostelloConfig =
    { tzQuery = ""
    , autoState = Autocomplete.empty
    , numToShow = 0
    , timezones = timezones
    , selectedTimeZone = Nothing
    , dbPass = "change_me_to_a_long_string"
    , secretKey = "change_me_to_a_long_string"
    }


baseUrl : String -> String
baseUrl url =
    url
        |> String.split "#"
        |> List.head
        |> Maybe.withDefault url


parseAccessToken : String -> ( Step, Maybe String )
parseAccessToken url =
    let
        match =
            Regex.find (Regex.AtMost 1) (Regex.regex "access_token=([^&]*)") url
                |> List.head

        token =
            case match of
                Just m ->
                    m.submatches
                        |> List.head
                        |> Maybe.withDefault Nothing

                Nothing ->
                    Nothing
    in
    case token of
        Just t ->
            ( PullData NoResp, token )

        Nothing ->
            ( NotLoggedIn, token )


addOrRemoveKey : List SSHKey -> SSHKey -> List SSHKey
addOrRemoveKey keys key =
    if List.member key keys then
        List.filter (\k -> not (k.id == key.id)) keys
    else
        key :: keys


action2Step : Action -> Step
action2Step action =
    case action.status of
        InProgess ->
            Deploying RespOk

        Completed ->
            DeployedNoIp

        Errored ->
            Deploying RespError

        UnknownActionStatus ->
            Deploying RespOk


dropletV4 : Model -> Maybe Network
dropletV4 model =
    case model.createResp of
        Just resp ->
            resp.droplet.networks.v4
                |> List.head

        Nothing ->
            Nothing


dropletIP : Model -> Maybe IPAddress
dropletIP model =
    let
        network =
            dropletV4 model
    in
    case network of
        Just net ->
            Just net.ip_address

        Nothing ->
            Nothing


acceptableTimeZones : String -> List String -> List String
acceptableTimeZones query tzs =
    let
        q =
            String.toLower query
    in
    List.filter (String.toLower >> String.contains q) tzs


timezones : List String
timezones =
    List.concat
        [ america
        , europe
        , africa
        , asia
        , other
        ]


america : List String
america =
    [ "America/Puerto_Rico"
    , "America/New_York"
    , "America/Chicago"
    , "America/Denver"
    , "America/Phoenix"
    , "America/Los_Angeles"
    , "America/Anchorage"
    , "Pacific/Honolulu"
    , "America/Adak"
    , "America/Anchorage"
    , "America/Anguilla"
    , "America/Antigua"
    , "America/Araguaina"
    , "America/Argentina/Buenos_Aires"
    , "America/Argentina/Catamarca"
    , "America/Argentina/ComodRivadavia"
    , "America/Argentina/Cordoba"
    , "America/Argentina/Jujuy"
    , "America/Argentina/La_Rioja"
    , "America/Argentina/Mendoza"
    , "America/Argentina/Rio_Gallegos"
    , "America/Argentina/Salta"
    , "America/Argentina/San_Juan"
    , "America/Argentina/San_Luis"
    , "America/Argentina/Tucuman"
    , "America/Argentina/Ushuaia"
    , "America/Aruba"
    , "America/Asuncion"
    , "America/Atikokan"
    , "America/Atka"
    , "America/Bahia"
    , "America/Barbados"
    , "America/Belem"
    , "America/Belize"
    , "America/Blanc-Sablon"
    , "America/Boa_Vista"
    , "America/Bogota"
    , "America/Boise"
    , "America/Buenos_Aires"
    , "America/Cambridge_Bay"
    , "America/Campo_Grande"
    , "America/Cancun"
    , "America/Caracas"
    , "America/Catamarca"
    , "America/Cayenne"
    , "America/Cayman"
    , "America/Chicago"
    , "America/Chihuahua"
    , "America/Coral_Harbour"
    , "America/Cordoba"
    , "America/Costa_Rica"
    , "America/Cuiaba"
    , "America/Curacao"
    , "America/Danmarkshavn"
    , "America/Dawson"
    , "America/Dawson_Creek"
    , "America/Denver"
    , "America/Detroit"
    , "America/Dominica"
    , "America/Edmonton"
    , "America/Eirunepe"
    , "America/El_Salvador"
    , "America/Ensenada"
    , "America/Fortaleza"
    , "America/Fort_Wayne"
    , "America/Glace_Bay"
    , "America/Godthab"
    , "America/Goose_Bay"
    , "America/Grand_Turk"
    , "America/Grenada"
    , "America/Guadeloupe"
    , "America/Guatemala"
    , "America/Guayaquil"
    , "America/Guyana"
    , "America/Halifax"
    , "America/Havana"
    , "America/Hermosillo"
    , "America/Indiana/Indianapolis"
    , "America/Indiana/Knox"
    , "America/Indiana/Marengo"
    , "America/Indiana/Petersburg"
    , "America/Indiana/Tell_City"
    , "America/Indiana/Vevay"
    , "America/Indiana/Vincennes"
    , "America/Indiana/Winamac"
    , "America/Indianapolis"
    , "America/Inuvik"
    , "America/Iqaluit"
    , "America/Jamaica"
    , "America/Jujuy"
    , "America/Juneau"
    , "America/Kentucky/Louisville"
    , "America/Kentucky/Monticello"
    , "America/Knox_IN"
    , "America/La_Paz"
    , "America/Lima"
    , "America/Los_Angeles"
    , "America/Louisville"
    , "America/Maceio"
    , "America/Managua"
    , "America/Manaus"
    , "America/Marigot"
    , "America/Martinique"
    , "America/Matamoros"
    , "America/Mazatlan"
    , "America/Mendoza"
    , "America/Menominee"
    , "America/Merida"
    , "America/Mexico_City"
    , "America/Miquelon"
    , "America/Moncton"
    , "America/Monterrey"
    , "America/Montevideo"
    , "America/Montreal"
    , "America/Montserrat"
    , "America/Nassau"
    , "America/New_York"
    , "America/Nipigon"
    , "America/Nome"
    , "America/Noronha"
    , "America/North_Dakota/Center"
    , "America/North_Dakota/New_Salem"
    , "America/Ojinaga"
    , "America/Panama"
    , "America/Pangnirtung"
    , "America/Paramaribo"
    , "America/Phoenix"
    , "America/Port-au-Prince"
    , "America/Porto_Acre"
    , "America/Port_of_Spain"
    , "America/Porto_Velho"
    , "America/Puerto_Rico"
    , "America/Rainy_River"
    , "America/Rankin_Inlet"
    , "America/Recife"
    , "America/Regina"
    , "America/Resolute"
    , "America/Rio_Branco"
    , "America/Rosario"
    , "America/Santa_Isabel"
    , "America/Santarem"
    , "America/Santiago"
    , "America/Santo_Domingo"
    , "America/Sao_Paulo"
    , "America/Scoresbysund"
    , "America/Shiprock"
    , "America/St_Barthelemy"
    , "America/St_Johns"
    , "America/St_Kitts"
    , "America/St_Lucia"
    , "America/St_Thomas"
    , "America/St_Vincent"
    , "America/Swift_Current"
    , "America/Tegucigalpa"
    , "America/Thule"
    , "America/Thunder_Bay"
    , "America/Tijuana"
    , "America/Toronto"
    , "America/Tortola"
    , "America/Vancouver"
    , "America/Virgin"
    , "America/Whitehorse"
    , "America/Winnipeg"
    , "America/Yakutat"
    , "America/Yellowknife"
    ]


europe : List String
europe =
    [ "Europe/Amsterdam"
    , "Europe/Andorra"
    , "Europe/Athens"
    , "Europe/Belfast"
    , "Europe/Belgrade"
    , "Europe/Berlin"
    , "Europe/Bratislava"
    , "Europe/Brussels"
    , "Europe/Bucharest"
    , "Europe/Budapest"
    , "Europe/Chisinau"
    , "Europe/Copenhagen"
    , "Europe/Dublin"
    , "Europe/Gibraltar"
    , "Europe/Guernsey"
    , "Europe/Helsinki"
    , "Europe/Isle_of_Man"
    , "Europe/Istanbul"
    , "Europe/Jersey"
    , "Europe/Kaliningrad"
    , "Europe/Kiev"
    , "Europe/Lisbon"
    , "Europe/Ljubljana"
    , "Europe/London"
    , "Europe/Luxembourg"
    , "Europe/Madrid"
    , "Europe/Malta"
    , "Europe/Mariehamn"
    , "Europe/Minsk"
    , "Europe/Monaco"
    , "Europe/Moscow"
    , "Europe/Nicosia"
    , "Europe/Oslo"
    , "Europe/Paris"
    , "Europe/Podgorica"
    , "Europe/Prague"
    , "Europe/Riga"
    , "Europe/Rome"
    , "Europe/Samara"
    , "Europe/San_Marino"
    , "Europe/Sarajevo"
    , "Europe/Simferopol"
    , "Europe/Skopje"
    , "Europe/Sofia"
    , "Europe/Stockholm"
    , "Europe/Tallinn"
    , "Europe/Tirane"
    , "Europe/Tiraspol"
    , "Europe/Uzhgorod"
    , "Europe/Vaduz"
    , "Europe/Vatican"
    , "Europe/Vienna"
    , "Europe/Vilnius"
    , "Europe/Volgograd"
    , "Europe/Warsaw"
    , "Europe/Zagreb"
    , "Europe/Zaporozhye"
    , "Europe/Zurich"
    ]


asia : List String
asia =
    [ "Asia/Aden"
    , "Asia/Almaty"
    , "Asia/Amman"
    , "Asia/Anadyr"
    , "Asia/Aqtau"
    , "Asia/Aqtobe"
    , "Asia/Ashgabat"
    , "Asia/Ashkhabad"
    , "Asia/Baghdad"
    , "Asia/Bahrain"
    , "Asia/Baku"
    , "Asia/Bangkok"
    , "Asia/Beirut"
    , "Asia/Bishkek"
    , "Asia/Brunei"
    , "Asia/Calcutta"
    , "Asia/Choibalsan"
    , "Asia/Chongqing"
    , "Asia/Chungking"
    , "Asia/Colombo"
    , "Asia/Dacca"
    , "Asia/Damascus"
    , "Asia/Dhaka"
    , "Asia/Dili"
    , "Asia/Dubai"
    , "Asia/Dushanbe"
    , "Asia/Gaza"
    , "Asia/Harbin"
    , "Asia/Ho_Chi_Minh"
    , "Asia/Hong_Kong"
    , "Asia/Hovd"
    , "Asia/Irkutsk"
    , "Asia/Istanbul"
    , "Asia/Jakarta"
    , "Asia/Jayapura"
    , "Asia/Jerusalem"
    , "Asia/Kabul"
    , "Asia/Kamchatka"
    , "Asia/Karachi"
    , "Asia/Kashgar"
    , "Asia/Kathmandu"
    , "Asia/Katmandu"
    , "Asia/Kolkata"
    , "Asia/Krasnoyarsk"
    , "Asia/Kuala_Lumpur"
    , "Asia/Kuching"
    , "Asia/Kuwait"
    , "Asia/Macao"
    , "Asia/Macau"
    , "Asia/Magadan"
    , "Asia/Makassar"
    , "Asia/Manila"
    , "Asia/Muscat"
    , "Asia/Nicosia"
    , "Asia/Novokuznetsk"
    , "Asia/Novosibirsk"
    , "Asia/Omsk"
    , "Asia/Oral"
    , "Asia/Phnom_Penh"
    , "Asia/Pontianak"
    , "Asia/Pyongyang"
    , "Asia/Qatar"
    , "Asia/Qyzylorda"
    , "Asia/Rangoon"
    , "Asia/Riyadh"
    , "Asia/Saigon"
    , "Asia/Sakhalin"
    , "Asia/Samarkand"
    , "Asia/Seoul"
    , "Asia/Shanghai"
    , "Asia/Singapore"
    , "Asia/Taipei"
    , "Asia/Tashkent"
    , "Asia/Tbilisi"
    , "Asia/Tehran"
    , "Asia/Tel_Aviv"
    , "Asia/Thimbu"
    , "Asia/Thimphu"
    , "Asia/Tokyo"
    , "Asia/Ujung_Pandang"
    , "Asia/Ulaanbaatar"
    , "Asia/Ulan_Bator"
    , "Asia/Urumqi"
    , "Asia/Vientiane"
    , "Asia/Vladivostok"
    , "Asia/Yakutsk"
    , "Asia/Yekaterinburg"
    , "Asia/Yerevan"
    ]


africa : List String
africa =
    [ "Africa/Abidjan"
    , "Africa/Accra"
    , "Africa/Addis_Ababa"
    , "Africa/Algiers"
    , "Africa/Asmara"
    , "Africa/Asmera"
    , "Africa/Bamako"
    , "Africa/Bangui"
    , "Africa/Banjul"
    , "Africa/Bissau"
    , "Africa/Blantyre"
    , "Africa/Brazzaville"
    , "Africa/Bujumbura"
    , "Africa/Cairo"
    , "Africa/Casablanca"
    , "Africa/Ceuta"
    , "Africa/Conakry"
    , "Africa/Dakar"
    , "Africa/Dar_es_Salaam"
    , "Africa/Djibouti"
    , "Africa/Douala"
    , "Africa/El_Aaiun"
    , "Africa/Freetown"
    , "Africa/Gaborone"
    , "Africa/Harare"
    , "Africa/Johannesburg"
    , "Africa/Kampala"
    , "Africa/Khartoum"
    , "Africa/Kigali"
    , "Africa/Kinshasa"
    , "Africa/Lagos"
    , "Africa/Libreville"
    , "Africa/Lome"
    , "Africa/Luanda"
    , "Africa/Lubumbashi"
    , "Africa/Lusaka"
    , "Africa/Malabo"
    , "Africa/Maputo"
    , "Africa/Maseru"
    , "Africa/Mbabane"
    , "Africa/Mogadishu"
    , "Africa/Monrovia"
    , "Africa/Nairobi"
    , "Africa/Ndjamena"
    , "Africa/Niamey"
    , "Africa/Nouakchott"
    , "Africa/Ouagadougou"
    , "Africa/Porto-Novo"
    , "Africa/Sao_Tome"
    , "Africa/Timbuktu"
    , "Africa/Tripoli"
    , "Africa/Tunis"
    , "Africa/Windhoek"
    ]


other : List String
other =
    [ "Australia/ACT"
    , "Australia/Adelaide"
    , "Australia/Brisbane"
    , "Australia/Broken_Hill"
    , "Australia/Canberra"
    , "Australia/Currie"
    , "Australia/Darwin"
    , "Australia/Eucla"
    , "Australia/Hobart"
    , "Australia/LHI"
    , "Australia/Lindeman"
    , "Australia/Lord_Howe"
    , "Australia/Melbourne"
    , "Australia/North"
    , "Australia/NSW"
    , "Australia/Perth"
    , "Australia/Queensland"
    , "Australia/South"
    , "Australia/Sydney"
    , "Australia/Tasmania"
    , "Australia/Victoria"
    , "Australia/West"
    , "Australia/Yancowinna"
    , "Indian/Antananarivo"
    , "Indian/Chagos"
    , "Indian/Christmas"
    , "Indian/Cocos"
    , "Indian/Comoro"
    , "Indian/Kerguelen"
    , "Indian/Mahe"
    , "Indian/Maldives"
    , "Indian/Mauritius"
    , "Indian/Mayotte"
    , "Indian/Reunion"
    , "Atlantic/Azores"
    , "Atlantic/Bermuda"
    , "Atlantic/Canary"
    , "Atlantic/Cape_Verde"
    , "Atlantic/Faeroe"
    , "Atlantic/Faroe"
    , "Atlantic/Jan_Mayen"
    , "Atlantic/Madeira"
    , "Atlantic/Reykjavik"
    , "Atlantic/South_Georgia"
    , "Atlantic/Stanley"
    , "Atlantic/St_Helena"
    , "Pacific/Apia"
    , "Pacific/Auckland"
    , "Pacific/Chatham"
    , "Pacific/Easter"
    , "Pacific/Efate"
    , "Pacific/Enderbury"
    , "Pacific/Fakaofo"
    , "Pacific/Fiji"
    , "Pacific/Funafuti"
    , "Pacific/Galapagos"
    , "Pacific/Gambier"
    , "Pacific/Guadalcanal"
    , "Pacific/Guam"
    , "Pacific/Honolulu"
    , "Pacific/Johnston"
    , "Pacific/Kiritimati"
    , "Pacific/Kosrae"
    , "Pacific/Kwajalein"
    , "Pacific/Majuro"
    , "Pacific/Marquesas"
    , "Pacific/Midway"
    , "Pacific/Nauru"
    , "Pacific/Niue"
    , "Pacific/Norfolk"
    , "Pacific/Noumea"
    , "Pacific/Pago_Pago"
    , "Pacific/Palau"
    , "Pacific/Pitcairn"
    , "Pacific/Ponape"
    , "Pacific/Port_Moresby"
    , "Pacific/Rarotonga"
    , "Pacific/Saipan"
    , "Pacific/Samoa"
    , "Pacific/Tahiti"
    , "Pacific/Tarawa"
    , "Pacific/Tongatapu"
    , "Pacific/Truk"
    , "Pacific/Wake"
    , "Pacific/Wallis"
    , "Pacific/Yap"
    , "Antarctica/Casey"
    , "Antarctica/Davis"
    , "Antarctica/DumontDUrville"
    , "Antarctica/Macquarie"
    , "Antarctica/Mawson"
    , "Antarctica/McMurdo"
    , "Antarctica/Palmer"
    , "Antarctica/Rothera"
    , "Antarctica/South_Pole"
    , "Antarctica/Syowa"
    , "Antarctica/Vostok"
    , "Arctic/Longyearbyen"
    , "UTC"
    , "UTC-12"
    , "UTC-11"
    , "UTC-10"
    , "UTC-9"
    , "UTC-8"
    , "UTC-7"
    , "UTC-6"
    , "UTC-5"
    , "UTC-4"
    , "UTC-3"
    , "UTC-2"
    , "UTC-1"
    , "UTC+0"
    , "UTC+1"
    , "UTC+2"
    , "UTC+3"
    , "UTC+4"
    , "UTC+5"
    , "UTC+6"
    , "UTC+7"
    , "UTC+8"
    , "UTC+9"
    , "UTC+10"
    , "UTC+11"
    , "UTC+12"
    , "UTC+13"
    , "UTC+14"
    ]
