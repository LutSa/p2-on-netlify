module Load exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode
import Message exposing (..)

loadImg url =
    img
        [ src url
        , on "error" (Json.Decode.succeed (ImageError url))
        , on "load" (Json.Decode.succeed (ImageLoaded url))
        ]
        []

connectName namePrefix anim id=
    namePrefix ++ anim ++ "/" ++ namePrefix ++ anim ++"_"
    ++ String.padLeft 4 '0' (String.fromInt id)

initLoadPack =
    let
        prefix = "img/character/color/"
        surfix = ".png"
        names = (List.range 0 64
            |> List.map (connectName "" "walk"))
            ++ (List.range 0 59
            |> List.map (connectName "character_" "walk"))
            ++ (List.range 0 59
            |> List.map (connectName "" "attack"))
            ++ (List.range 0 59
            |> List.map (connectName "character_" "attack"))
            ++ (List.range 0 2
            |> List.map (connectName "" "charge"))
            ++
            [ connectName "" "jump" 0
            , "attacked/attackedBack_0000"
            , "attacked/attackedFront_0000"]
        urls =  List.map (\name-> prefix ++ name ++ surfix) names
                ++ ["img/background.png"]
                ++ ["img/CG/CG1_1.png"
                   ,"img/CG/CG1_2.png"
                   ,"img/CG/CG1_3.png"
                   ,"img/CG/CG1_4.png"
                   ,"img/CG/CG2_1.png"
                   ,"img/CG/CG2_2.png"
                   ,"img/CG/CG3_1.png"
                   ,"img/CG/CG5_1.png"
                   ,"img/CG/CG5_2.png"
                   ,"img/CG/CG6_2.png"
                   ,"img/CG/Story1_1.png"
                   ,"img/CG/Story1_2.png"
                   ,"img/CG/Story1_3.png"
                   ,"img/CG/Story1_4.png"
                   ,"img/CG/Story1_5.png"
                   ,"img/CG/Story2_1.png"
                   ,"img/CG/Story2_2.png"
                   ,"img/CG/Story3_1.png"
                   ,"img/CG/Story3_2.png"
                   ,"img/CG/Story4_Lose.png"
                   ,"img/CG/Story4_Win.png"
                   ,"img/CG/Story5_0.png"
                   ,"img/CG/Story5_1.png"
                   ,"img/CG/Story5_2.png"
                   ,"img/CG/Story6_1.png"
                   ,"img/Page/LOGO.png"
                   ,"img/Page/About.png"
                   ,"img/Page/Start.png"
                   ,"img/Page/Break.png"
                   ,"img/Page/Exit.png"
                   ,"img/Effect/bloodFrame_1.png"
                   ,"img/Effect/bloodFrame_2.png"
                   ,"img/Effect/bloodFrame_3.png"
                   ,"img/Effect/bloodFrame_4.png"
                   ,"img/Effect/bloodFrame_5.png"
                   ,"img/Stone/map_1/stone_1.png"
                   ,"img/Stone/map_1/stone_2.png"
                   ,"img/Stone/map_2/stone_1.png"
                   ,"img/Stone/map_2/stone_2.png"
                   ,"img/Stone/map_3/stone_1.png"
                   ,"img/Stone/map_3/stone_2.png"
                   ,"img/Stone/map_3/stone_3.png"
                   ,"img/Stone/map_4/stone_1.png"
                   ,"img/Stone/map_5/stone_1.png"
                   ,"img/Stone/map_5/stone_2.png"
                   ,"img/background/background1_1.png"
                   ,"img/background/background1_2.png"
                   ,"img/background/background1_3.png"
                   ,"img/background/background1_4.png"
                   ,"img/background/background2_1.png"
                   ,"img/background/background2_2.png"
                   ,"img/background/background3_1.png"
                   ,"img/background/background4_1.png"
                   ,"img/background/background4_2.png"
                   ,"img/background/background5_1.png"
                   ,"img/Button/AboutBut.png"
                   ,"img/Button/BackBut.png"
                   ,"img/Button/NextBut.png"
                   ,"img/Button/StartBut.png"



                   
                   
                   
                   
                   
                   
                   
                    ]
    in
        urls
        

        