module View exposing (..)

import Html exposing (..)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Html exposing (Html, button, div, text)
import Html.Attributes exposing (style,src,controls,autoplay,loop,attribute)
import Html.Events exposing (on, onClick, onMouseDown, onMouseUp)
import Model exposing (..)
import Message exposing (..)
import Update exposing (..)
import Animate exposing (..)
import MapSetting exposing (..)
import Load exposing (..)

viewAttrs =
    { size = Vector 1600 800
    }

textStoryOne = "story one"

view : Model -> Html Msg
view model =
    let
        prefix = ""
        --prefix = ""

        renderSvg = svg
                        (gameUIAttribute model.size)
                        (if model.state == Story1_1 || model.state == Story1_2 || model.state == Story1_3 || 
                            model.state == Story1_4 || model.state == Story1_5 || model.state == Story2_1 || 
                            model.state == Story2_2 || model.state == Story3_1 || 
                            model.state == Story4_Lose || model.state == Story4_Win || 
                            model.state == Story5_1 || model.state == Story5_0 || model.state == Story5_2 ||
                            model.state == Story6_1 then
                            [renderStory model.story] ++  renderStoryBackground model
                        else if model.state == CG1_1 || model.state == CG1_2 || model.state == CG1_3 || 
                                model.state == CG1_4 || model.state == CG2_1 || model.state == CG2_2 ||
                                model.state == CG3_1 || model.state == CG5_1 || model.state == CG5_2 || 
                                model.state == CG6_1 || model.state == CG6_2 then 
                            [renderCG model]
                        else if model.state == Loading then
                            [ renderBackground model]
                        else if model.state == LOGO then
                            [ renderLOGO model, renderBackground model]
                        else if model.state == Model.Start then
                            [ renderBackground model ]
                        else if model.state == End then
                            [ renderBackground model ]
                        else if model.state == Model.About then
                            [ renderBackground model]
                        else
                            ([ renderBackground model
                            , renderPlayer model.state model.player
                            ]
                            ++ renderCharacters model.player model.map.characters
                            ++ renderBricksShader (List.map .pos model.map.bricks) model 
                                --++ debugCollision model.map.characters model.player
                            --++ debugAttack model.map.characters model.player
                            ++ renderNPCs model.player model.map.npcs 
                            ++ 
                            ( 
                               if model.state == Two then
                                    renderSpeedAI model.player model.speedAI
                               else
                                    []
                             )
                            ++ 
                            ( if model.state == Three then
                                renderBoss model.player model.boss
                           else
                                []
                            )
                             ++ [renderPlayerText model.player]
                             ++ renderNPCsText model.player model.map.npcs
                             ++ renderBlood model.player
                        ))                    
        renderLoad = if model.state == Loading then
                        List.map loadImg initLoadPack
                    else 
                        []
        renderHtml = if model.state == One || model.state == DiscoverI || model.state == Two ||
                        model.state == DiscoverII || model.state == Three then
                        renderbricks (List.map .pos model.map.bricks) model
                    else if model.state == Model.Start then 
                        [ renderButton Message.Start (prefix++"img/Button/StartBut.png") model.size (Pos 1100 1300 200 350)
                        , renderButton Message.About (prefix++"img/Button/AboutBut.png") model.size (Pos 1100 1300 400 550) ] 
                    else if  model.state == End then
                        [ renderButton Next (prefix++"img/Button/NextBut.png") model.size (Pos 1100 1300 400 500) ]
                    else if model.state == Model.About then
                        [ renderButton Back (prefix++"img/Button/BackBut.png") model.size (Pos 1100 1300 400 500) ] 
                    else
                        [ renderAudio  "bgm/kttbgm.mp3"]
    in  
    div[]
        [    
             div []renderHtml     
            , div
                [ Html.Attributes.style "height" "0px"]
                [ renderSvg
                , span[Html.Attributes.style "opacity" "0"] renderLoad
                ]    
        

        ]

renderSpeedAI player speedAI= 
    let
        url = getAnimUrl speedAI.anim speedAI.frame speedAI ""
        attr = getDirectionAttr speedAI.direction
        viewpos = speedAI.pos |> offset player |> resizePlayer|> clearOutsideImage
    in
        [renderImage url viewpos attr]

renderBoss player boss =
    let
        url = getAnimUrl boss.anim boss.frame boss "boss_"
        attr = getDirectionAttr boss.direction
        viewpos = boss.pos |> offset player |> resizePlayer|> clearOutsideImage
    in
        [renderImage url viewpos attr]



renderBlood player = 
    let
        prefix = ""
    in
    if player.mood == Normal then
        if player.hp >= 7 && player.hp <10 then
            [ renderImage (prefix++"img/Effect/bloodFrame_1.png") (Pos 0 1600 0 800) [opacity (String.fromFloat (abs(player.effecttimeOne)/2000))]
            ]
        else if player.hp >= 5 && player.hp < 7 then
            [ renderImage (prefix++"img/Effect/bloodFrame_1.png") (Pos 0 1600 0 800) [opacity (String.fromFloat (abs(player.effecttimeTwo)/1750))]
            , renderImage (prefix++"img/Effect/bloodFrame_2.png") (Pos 0 1600 0 800) [opacity (String.fromFloat (abs(player.effecttimeOne)/1750))]           
            ]
        else if player.hp >= 3 && player.hp < 5 then
            [ renderImage (prefix++"img/Effect/bloodFrame_1.png") (Pos 0 1600 0 800) [opacity (String.fromFloat (abs(player.effecttimeThree)/1500))]
            , renderImage (prefix++"img/Effect/bloodFrame_2.png") (Pos 0 1600 0 800) [opacity (String.fromFloat (abs(player.effecttimeTwo)/1500))] 
            , renderImage (prefix++"img/Effect/bloodFrame_3.png") (Pos 0 1600 0 800) [opacity (String.fromFloat (abs(player.effecttimeThree)/1500))]
            ] 
        else if player.hp > 0 && player.hp < 3 then
            [ renderImage (prefix++"img/Effect/bloodFrame_1.png") (Pos 0 1600 0 800) [opacity (String.fromFloat (abs(player.effecttimeFour)/1250))]
            , renderImage (prefix++"img/Effect/bloodFrame_2.png") (Pos 0 1600 0 800) [opacity (String.fromFloat (abs(player.effecttimeTwo)/1250))] 
            , renderImage (prefix++"img/Effect/bloodFrame_3.png") (Pos 0 1600 0 800) [opacity (String.fromFloat (abs(player.effecttimeThree)/1250))]
            , renderImage (prefix++"img/Effect/bloodFrame_4.png") (Pos 0 1600 0 800) [opacity (String.fromFloat (abs(player.effecttimeFour)/1250))]
            ]  
        else
            [ renderImage (prefix++"img/Effect/bloodFrame_1.png") (Pos 0 0 0 0) [opacity "0"]
            ]
    else 
        [ renderImage (prefix++"img/Effect/bloodFrame_1.png") (Pos 0 1600 0 800) [opacity (String.fromFloat (abs(player.effecttimeFive)/1000))]
        , renderImage (prefix++"img/Effect/bloodFrame_2.png") (Pos 0 1600 0 800) [opacity (String.fromFloat (abs(player.effecttimeThree)/1000))] 
        , renderImage (prefix++"img/Effect/bloodFrame_3.png") (Pos 0 1600 0 800) [opacity (String.fromFloat (abs(player.effecttimeFour)/1000))]
        , renderImage (prefix++"img/Effect/bloodFrame_4.png") (Pos 0 1600 0 800) [opacity (String.fromFloat (abs(player.effecttimeFive)/1000))]
        , renderImage (prefix++"img/Effect/bloodFrame_5.png") (Pos 0 1600 0 800) [opacity (String.fromFloat (abs(player.effecttimeFive)/1000))]
        ]

        

offset player pos =
    let
        dx = toFloat(floor (player.pos.x1/viewAttrs.size.x) * viewAttrs.size.x)
        dy = toFloat(floor (player.pos.y1/viewAttrs.size.y)* viewAttrs.size.y)
    in
        Pos (pos.x1-dx) (pos.x2-dx) (pos.y1-dy) (pos.y2-dy)

renderbricks posList model=
    List.map (renderbrick1 model) posList
    
renderBricksShader posList model = 
    List.map (renderbrick model model.player) posList

renderbrick1 model pos=
    let
        prefix = "" 
        viewpos = pos |> offset model.player
                    |> cutBrickView
                    |> clearOutsideImage
        text = if model.state == One then
                    prefix++"img/Stone/map_1/stone_1.png"
                else if model.state == DiscoverI then
                    if pos.x2-pos.x1 >= pos.y2-pos.y1 then
                        prefix++"img/Stone/map_2/stone_1.png"
                    else
                       prefix++"img/Stone/map_2/stone_2.png"
                else if model.state == Two then
                    if pos.x2-pos.x1 >= pos.y2-pos.y1 then
                        prefix++"img/Stone/map_3/stone_1.png"
                    else if pos.y2-pos.y1 >= 1000 then
                        prefix++"img/Stone/map_3/stone_3.png"
                    else
                       prefix++"img/Stone/map_3/stone_2.png"
                else if model.state == DiscoverII then
                    if pos.x2-pos.x1 >= pos.y2-pos.y1 then
                        prefix++"img/Stone/map_4/stone_1.png"
                    else
                       prefix++"img/Stone/map_4/stone_2.png"
                else if model.state == Three then
                    if pos.x2-pos.x1 >= pos.y2-pos.y1 then
                        prefix++"img/Stone/map_5/stone_1.png"
                    else
                       prefix++"img/Stone/map_5/stone_2.png"
                else
                    prefix++"img/Stone/map_1/stone_1.png"
    in
        renderHtmlImg model.size text viewpos
        --renderImage text viewpos []

    

    
renderbrick model player pos=
    let
        viewpos = pos |> offset player
                    |> cutBrickView
                    |> clearOutsideImage
        rgb = case model.state of
            One ->
                "#413447"
            DiscoverI ->
                "#596E47"--
            Two ->
                "#6075AB"
            DiscoverII ->
                "#67AF6D"
            Three ->
                "#7C341E"
            _ ->
                "#000000"

    in
    rect
        [ rx "10"
        , ry "10"
        , x (String.fromFloat viewpos.x1)
        , y (String.fromFloat viewpos.y1)
        , width (String.fromFloat (viewpos.x2-viewpos.x1))
        , height (String.fromFloat (viewpos.y2-viewpos.y1))
        , fill rgb
        ]
        []

cutBrickView viewpos =
    let
        x1 = if viewpos.x1<0 then
                    0
                else
                    viewpos.x1
        x2 = if viewpos.x2>viewAttrs.size.x then
                    viewAttrs.size.x
                else
                    viewpos.x2
        y1 = if viewpos.y1<0 then
                    0
                else
                    viewpos.y1
        y2 = if viewpos.y2>viewAttrs.size.y then
                    viewAttrs.size.y
                else
                    viewpos.y2
    in
        Pos x1 x2 y1 y2



renderBackground model=
    let
       prefix = ""
        --prefix = ""
    in
    if model.state == LOGO then
        renderImage (prefix++"img/background.png") (Pos 0 viewAttrs.size.x 0 viewAttrs.size.y) [opacity (String.fromFloat (0))] 
    else if model.state == Model.Start then 
        renderImage (prefix++"img/Page/Start.png") (Pos 0 viewAttrs.size.x 0 viewAttrs.size.y) [opacity (String.fromFloat (0.7+(abs(model.player.effecttimeHalf)/2000)))] 
    else if model.state == End then
        renderImage (prefix++"img/Page/Exit.png") (Pos 0 viewAttrs.size.x 0 viewAttrs.size.y) [opacity (String.fromFloat (0.7+(abs(model.player.effecttimeHalf)/2000)))] 
    else if model.state == Model.About then
        renderImage (prefix++"img/Page/About.png") (Pos 0 viewAttrs.size.x 0 viewAttrs.size.y) [opacity "1"]
    else if model.state == Loading then
        renderImage (prefix++"img/Page/Load_1.png") (Pos 0 viewAttrs.size.x 0 viewAttrs.size.y) [opacity "1"] 
        
    else if model.state == One then
        if model.player.pos.y1 >= 3200 || (model.player.pos.y2 <= 800 && model.player.pos.x1 >= 3200) then
            if model.player.pos.x1 <= 1600  then
                renderImage (prefix++"img/background/background1_1.png") (Pos 0 viewAttrs.size.x 0 viewAttrs.size.y) []
            else if model.player.pos.y2 <= 800 && model.player.pos.x1 >= 3200 then
                renderImage (prefix++"img/background/background1_4.png") (Pos 0 viewAttrs.size.x 0 viewAttrs.size.y) [] 
            else
                renderImage (prefix++"img/background/background1_2.png") (Pos 0 viewAttrs.size.x 0 viewAttrs.size.y) [] 
        else 
            renderImage (prefix++"img/background/background1_3.png") (Pos 0 viewAttrs.size.x 0 viewAttrs.size.y) []
    else if model.state == DiscoverI then
        if model.player.pos.y1 >= 3200 then
            renderImage (prefix++"img/background/background2_1.png") (Pos 0 viewAttrs.size.x 0 viewAttrs.size.y) [] 
        else
           renderImage (prefix++"img/background/background2_2.png") (Pos 0 viewAttrs.size.x 0 viewAttrs.size.y) [] 
    else if model.state == Two then
        renderImage (prefix++"img/background/background3_1.png") (Pos 0 viewAttrs.size.x 0 viewAttrs.size.y) [] 
    else if model.state == DiscoverII then
        if model.player.pos.y1 >=3200 then
            renderImage (prefix++"img/background/background4_1.png") (Pos 0 viewAttrs.size.x 0 viewAttrs.size.y) [] 
        else 
            renderImage (prefix++"img/background/background4_2.png") (Pos 0 viewAttrs.size.x 0 viewAttrs.size.y) [] 
    else if model.state == Three then
        renderImage (prefix++"img/background/background5_1.png") (Pos 0 viewAttrs.size.x 0 viewAttrs.size.y) []
    else
        Svg.image [][]

renderCharacters player characters =
        List.map (renderCharacter player)characters 

renderCharacter player character =
    let
        url = getAnimUrl character.anim character.frame character "character_"
        attr = getDirectionAttr character.direction
        viewpos = character.pos |> offset player |> resizePlayer|> clearOutsideImage
        --character.pos
        --getPlayerViewPos character

    in
        renderImage url viewpos attr

clearOutsideImage viewpos=
    if viewpos.x2<0 || viewpos.x1>viewAttrs.size.x || viewpos.y2<0 || viewpos.y1>viewAttrs.size.y then
        Pos -1600 -1600 0 0
    else
        viewpos

connectName namePrefix anim id=
    namePrefix ++ anim ++ "/" ++ namePrefix ++ anim ++"_"
    ++ String.padLeft 4 '0' (String.fromInt id)

--Todo: add whole rage picture(blood or something else)
getAnimUrl anim frame player namePrefix= 
    let
        prefix = "img/character/color/"
        --prefix = "img/character/color/"
        surfix = ".png"
        name = case anim of
            Stand -> 
                    connectName namePrefix "walk" 0
            Walk ->
                let
                    id = if namePrefix == "" then
                            modBy 65 frame
                        else 
                            modBy 60 frame

                in
                    connectName namePrefix "walk" id
            Charge ->
                let
                    id = if frame < 50 then 
                                1 
                            else if frame < 120 then 
                                0 
                            else 
                                2
                in
                    connectName namePrefix "charge" id
                -- might use chargetime to decide       
            Jump -> 
                    connectName namePrefix "jump" 0
            Attack ->
                let
                    id = modBy 60 frame
                in
                    connectName namePrefix "attack" id

            Crouch ->
                    connectName namePrefix "charge" 2

            Grovel ->
                    connectName namePrefix "grovel" 0

            Attacked ->
                if (namePrefix == "") then
                    if ( player.speed.x < 0 && player.direction == Left)
                    || ( player.speed.x > 0 && player.direction == Right) then
                        namePrefix++"attacked/"++namePrefix++"attackedBack_0000"
                    else
                        namePrefix++"attacked/"++namePrefix++"attackedFront_0000"
                else
                    let
                        id = modBy 350 frame
                    in
                        connectName namePrefix "attacked" id
            Fly ->
                    connectName namePrefix "jump" 0

            Dead ->
                let
                    id = Basics.min 239 frame
                in
                    connectName namePrefix "dead" id
            
            DebugMode ->
                    connectName namePrefix "walk" 0

            JumpStart ->
                let
                    id = Basics.min 13 (floor ((toFloat frame)/4))
                in
                    connectName namePrefix "jumpstart" id
            JumpEnd ->
                let
                    id = if frame <= 35 then
                            0
                        else Basics.min 7 (floor ((toFloat (frame-35))/2))
                in
                    connectName namePrefix "jumpend" id
            JumpLoop ->
                let
                    id = modBy 20 frame
                in
                    connectName namePrefix "jumploop" id
            Getup ->
                let
                    id = Basics.min 81 (Basics.max 0 (floor ((toFloat (frame-80))/2)))
                in
                    connectName namePrefix "getup" id
    in
        prefix ++ name ++ surfix



getDirectionAttr direction =
    case direction of
           Left ->
            [ transform "scale (-1 1)"]
           Right ->
            []

getPlayerViewPos player =
    player.pos 
    |> offset player 
    |> resizePlayer

renderPlayer state player=
    let
        url = getAnimUrl player.anim player.frame player ""
        attr = if state == Two then
                    getDirectionAttr player.direction ++ [opacity "0.5"]
               else
                    getDirectionAttr player.direction
        pos = getPlayerViewPos player
    in
        if player.anim == Grovel then
            renderImage url (Pos (pos.x1+85) (pos.x2-85) (pos.y1+30) (pos.y2+30)) attr
        else
            renderImage url pos attr


renderNPC player npc=
    let
        url = getAnimUrl npc.anim npc.frame npc "NPC_"
        attr = getDirectionAttr npc.direction
        pos = npc.pos |> offset player |> clearOutsideImage

    in    
    renderImage url (Pos pos.x1 pos.x2 (pos.y1+10) (pos.y2+10)) attr

renderNPCs player npcs =
    List.map (renderNPC player) npcs

debugCollision characters player=
    let
        charactersCollisionPos = characters
            |> List.map .collisionPos
            |> List.concat
        collisionPos = player.collisionPos ++ charactersCollisionPos  
            |> List.map (offset player) 
            |> List.map clearOutsideImage

    in
        List.map (\pos ->
                    rect
                        [ x (String.fromFloat pos.x1)
                        , y (String.fromFloat pos.y1)
                        , width (String.fromFloat (pos.x2-pos.x1))
                        , height (String.fromFloat (pos.y2-pos.y1))
                        , opacity "0.2"
                        , fill "#000000"
                        ]
                        []) collisionPos 

debugAttack characters player boss=
    let
        attackPos = ((playerAttackRange player)
            :: bossForwardAttackRange boss
            :: bossBackwardAttackRange boss
            :: jumpPos1
            :: exitPos1
            :: (characters 
            |> List.map attackRange))
            |> List.map (offset player) 
            |> List.map clearOutsideImage
    in
        List.map (\pos ->
                    rect
                        [ x (String.fromFloat pos.x1)
                        , y (String.fromFloat pos.y1)
                        , width (String.fromFloat (pos.x2-pos.x1))
                        , height (String.fromFloat (pos.y2-pos.y1))
                        , opacity "0.2"
                        , fill "#ff0000"
                        ]
                        []) attackPos 

resizePlayer pos =
    let
        y = 768 / 700 * (pos.y2-pos.y1)
        y2 = pos.y2
        y1 = y2 - y
        x = 1366 / 455 * (pos.x2-pos.x1)
        dx = (x - (pos.x2-pos.x1))/2
        x1 = pos.x1 - dx
        x2 = pos.x2 + dx
    in
-- 455 -> 130; 700 ->200
-- 1366 768
    Pos x1 x2 y1 y2



gameUIAttribute size= 
    [ width (String.fromFloat size.x)
    , height (String.fromFloat size.y)
    , viewBox ("0 0 "++(String.fromFloat viewAttrs.size.x) ++ " " ++ (String.fromFloat viewAttrs.size.y)) 
    ]




renderAudio url =
    audio
        [src url, autoplay True, loop True]

        [Html.text "Your browser does not support the audio"]


   
renderButton msg url size svgpos= 
    let
        pos = svgpos|>toHtmlPos size
    in
        button
            [ Html.Attributes.style "border" "0"
            , Html.Attributes.style "bottom" "30px"
            , Html.Attributes.style "cursor" "pointer"
            , Html.Attributes.style "display" "block"
            , Html.Attributes.style "height" "0px"
            , Html.Attributes.style "left" "0px"
            , Html.Attributes.style "line-height" "60px"
            , Html.Attributes.style "outline" "none"
            , Html.Attributes.style "padding" "0"
            -- Display at center
            , Html.Attributes.style "position" "absolute"
            , Html.Attributes.style "left" ((String.fromFloat pos.x1)++"px")
            , Html.Attributes.style "top" ((String.fromFloat pos.y1)++"px")
            -- 
            , Html.Attributes.style "width" "120px"
            , onClick msg
            ]
            [ Html.img [src url
            , height ((String.fromFloat (pos.y2-pos.y1))++"px") 
            , width ((String.fromFloat (pos.x2-pos.x1))++"px")][] ]

renderHtmlImg size url svgpos=
    let
        pos = svgpos|>toHtmlPos size
    in
        Html.img [src url
            , height ((String.fromFloat (pos.y2-pos.y1))++"px") 
            , width ((String.fromFloat (pos.x2-pos.x1))++"px")
            , Html.Attributes.style "position" "absolute"
            , Html.Attributes.style "left" ((String.fromFloat pos.x1)++"px")
            , Html.Attributes.style "top" ((String.fromFloat (pos.y1))++"px")][]
            
toHtmlPos size pos =
    let
        dy = size.y/2 - size.x/2/2
        x1 = pos.x1 /1600 * size.x
        x2 = pos.x2 /1600 * size.x
        y1 = pos.y1 /1600 * size.x + dy
        y2 = pos.y2 /1600 * size.x+dy
    in
        Pos x1 x2 y1 y2



renderImage url pos attr=
    Svg.image
        ([  xlinkHref url
        , width (String.fromFloat (pos.x2-pos.x1))
        , height (String.fromFloat (pos.y2-pos.y1))
        , if List.member (transform "scale (-1 1)") attr then
             x (String.fromFloat (-pos.x2))
            else
            x (String.fromFloat pos.x1)
        , y (String.fromFloat pos.y1)
        ]
        ++ attr)
    []

renderText size xx yy text =
    Svg.text_
        [ fontSize (String.fromFloat size)
        ]
        [ tspan [x (String.fromFloat xx),
            y (String.fromFloat yy)]
            [Svg.text text]
        ]

renderT size pos w lines text =
    foreignObject [ x (String.fromFloat (pos.x1+70))
                  , y (String.fromFloat (pos.y1-(toFloat(lines)*20)))
                  , width (String.fromFloat w)
                  , height (String.fromFloat (toFloat(lines)*22))
                  ]
                  [ p [ Html.Attributes.style "font-size" ((String.fromFloat size)++"px") ]
                      [ Svg.text text ]
                  ]

renderTyper size pos w lines text frame =
    text
        |> String.left (floor ((toFloat frame)/10))
        |> renderT size pos w lines



renderPlayerText player =
    let
        size = 18
        pos = getPlayerViewPos player
        w = 180
        lines = (floor(toFloat(String.length(player.text))/20)+3)
        text = player.text
    in
        renderT size pos w lines text

renderNPCsText player npcs = 
    List.map (renderNPCText player) npcs

renderNPCText player npc = 
    let
        size = 18
        pos = (Pos (npc.pos.x1-150) (npc.pos.x2-150) (npc.pos.y1+10) (npc.pos.y2+10)) |> offset player |> clearOutsideImage
        w = 180
        lines = (floor(toFloat(String.length(npc.text))/20)+2) 
    in
        renderT size pos w lines npc.text

renderS size w lines text =
    foreignObject [ x "200"
                  , y "80"
                  , width (String.fromFloat w)
                  , height (String.fromFloat (toFloat(lines)*20))
                  ]
                  [ p [ Html.Attributes.style "font-size" ((String.fromFloat size)++"px") ]
                      [ Svg.text text ]
                  ]

renderStory story =
    let
        size = 20
        w = 1000
        lines = (floor(toFloat(String.length(story.text))/20)+2)
        text = story.text
    in
        renderS size w lines text
renderCG model = 
    let
        prefix = "img/CG/"
        --prefix = "img/CG/" 
    in
    renderImage ( (prefix ++ stateToSring model.state) ++ ".png") (Pos 0 viewAttrs.size.x 0 viewAttrs.size.y) [opacity (String.fromFloat (1-(model.cgtime/1000-2.5)^4/40))]

renderStoryBackground model = 
    let
        prefix = "img/CG/"
        --prefix = "img/CG/" 
    in
    case model.state of
        Story1_5 ->
            [ renderImage  (prefix ++ "CG1_4.png") (Pos 0 viewAttrs.size.x 0 viewAttrs.size.y) [opacity "0.3"]
            , renderImage ( (prefix ++ "Story1_5" ) ++ ".png") (Pos 0 viewAttrs.size.x 0 viewAttrs.size.y) [opacity (String.fromFloat (1-(model.cgtime/1000-2.5)^4/40))] ]
        Story5_0 ->
            [ renderImage  "img/background.png" (Pos 0 viewAttrs.size.x 0 viewAttrs.size.y) [opacity "0"]
            , renderImage ( (prefix ++ "Story5_0" ) ++ ".png") (Pos 0 viewAttrs.size.x 0 viewAttrs.size.y) [opacity (String.fromFloat (1-(model.cgtime/1000-2.5)^4/40))] ]
        Story5_2 ->
            [ renderImage  (prefix ++ "CG5_2.png") (Pos 0 viewAttrs.size.x 0 viewAttrs.size.y) [opacity "0.3"]
            , renderImage ( (prefix ++ "Story5_2" ) ++ ".png") (Pos 0 viewAttrs.size.x 0 viewAttrs.size.y) [opacity (String.fromFloat (1-(model.cgtime/1000-2.5)^4/40))] ]
        Story5_1 ->
            [ renderImage  (prefix ++ "CG5_2.png") (Pos 0 viewAttrs.size.x 0 viewAttrs.size.y) [opacity "0.3"]
            , renderImage ( (prefix ++ "Story5_1" ) ++ ".png") (Pos 0 viewAttrs.size.x 0 viewAttrs.size.y) [opacity (String.fromFloat (1-(model.cgtime/1000-2.5)^4/40))] ]
        Story4_Lose ->
            [ renderImage ( (prefix ++ "Story4_Lose" ) ++ ".png") (Pos 0 viewAttrs.size.x 0 viewAttrs.size.y) [opacity (String.fromFloat (1-(model.cgtime/1000-2.5)^4/40))] ]
        Story4_Win ->
            [ renderImage ( (prefix ++ "Story4_Win" ) ++ ".png") (Pos 0 viewAttrs.size.x 0 viewAttrs.size.y) [opacity (String.fromFloat (1-(model.cgtime/1000-2.5)^4/40))] ]
        _ ->
            [ renderImage ( (prefix ++ "CG" ++(String.right 3 (stateToSring model.state))) ++ ".png") (Pos 0 viewAttrs.size.x 0 viewAttrs.size.y) [opacity "0.3"]
            , renderImage ( (prefix ++ stateToSring model.state ) ++ ".png") (Pos 0 viewAttrs.size.x 0 viewAttrs.size.y) [opacity (String.fromFloat (1-(model.cgtime/1000-2.5)^4/40))] ]


stateToSring: Model.Stage -> String
stateToSring state =
    case state of
            Model.One -> "One"
            Model.Two -> "Two"
            Model.Three -> "Three"
            Model.DiscoverI -> "DiscoverI"
            Model.DiscoverII -> "DiscoverII"
            Model.LOGO -> "LOGO"
            Model.Start -> "Start"
            Model.About -> "About"
            End -> "End"
            Loading -> "Loading"
            Story1_1 -> "Story1_1"
            Story1_2 -> "Story1_2"
            Story1_3 -> "Story1_3"
            Story1_4 -> "Story1_4"
            Story1_5 -> "Story1_5"
            Story2_1 -> "Story2_1"
            Story2_2 -> "Story2_2"
            Story3_1 -> "Story3_1"
            Story4_Win -> "Story4_Win"
            Story4_Lose -> "Story4_Lose"
            Story5_0 -> "Story5_0"
            Story5_1 -> "Story5_1"
            Story5_2 -> "Story5_2"
            Story6_1 -> "Story6_1"
            CG1_1 -> "CG1_1"
            CG1_2 -> "CG1_2"
            CG1_3 -> "CG1_3"
            CG1_4 -> "CG1_4"
            CG2_1 -> "CG2_1"
            CG2_2 -> "CG2_2"
            CG3_1 -> "CG3_1"
            CG5_1 -> "CG5_1"
            CG5_2 -> "CG5_2"
            CG6_1 -> "CG6_1"
            CG6_2 -> "CG6_2"


renderLOGO model = 
    renderImage "img/Page/LOGO.png" (Pos 0 viewAttrs.size.x 0 viewAttrs.size.y) [opacity (String.fromFloat (1-(model.cgtime/1000-2.5)^4/40))] 