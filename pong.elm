import Engine exposing (..)
import Engine.Material.Material exposing  (MaterialProperty)
import Math.Vector3 exposing (vec3, Vec3)
import Engine.Shader.GouraudShader exposing  (gouraudShader)

import Time exposing (..)
import Signal exposing (..)
import Keyboard exposing (..)
import Window exposing (..) 

import Array exposing (fromList)

import Graphics.Element exposing (Element)

-- INPUT

type alias Input = {
  space : Bool,
  paddle1 : Int,
  paddle2 : Int,
  delta : Time
}


delta : Signal Time
delta = inSeconds <~ fps 60

input : Signal Input
input = sampleOn delta <| Input <~ Keyboard.space
                                 ~ map .y Keyboard.wasd
                                 ~ map .y Keyboard.arrows
                                 ~ delta



-- MODEL

(gameWidth, gameHeight) = (600, 400)
(halfWidth, halfHeight) = (300, 200)


type alias Object a = { a |
  x : Float,
  y : Float,
  vx : Float,
  vy : Float
}

type alias Ball = Object {}

type alias Player = Object { score : Int }

type State = Play | Pause

type alias Game = {
  state : State,
  ball : Ball,
  player1 : Player,
  player2 : Player
}

player : Float -> Player
player x = { x = x, y = 0, vx = 0, vy = 0, score = 0 }

defaultGame : Game
defaultGame = {
  state = Pause,
  ball = { x = 0, y = 0, vx = 200, vy = 200 },
  player1 = player (20 - halfWidth),
  player2 = player (halfWidth - 20) }


-- UPDATE

near : Float -> Float -> Float -> Bool
near n c m = m >= n - c && m <= n + c

within : Ball -> Player -> Bool
within ball player =
  (ball.x |> near player.x 8) && (ball.y |> near player.y 20)


stepV : Float -> Bool -> Bool -> Float
stepV v lowerCollision upperCollision =
  if lowerCollision then abs v
  else if upperCollision then 0 - abs v
  else v


stepObj : Time -> Object a -> Object a
stepObj t ({x,y,vx,vy} as obj) =
  { obj | x = x + vx * t,
          y = y + vy * t }

stepBall : Time -> Ball -> Player -> Player -> Ball
stepBall t ({x,y,vx,vy} as ball) player1 player2 =
  if not (ball.x |> near 0 halfWidth)
  then { ball | x = 0, y = 0}
  else
    let vx2 = stepV vx (within ball player1) (within ball player2)
        vy2 = stepV vy (y < 7 - halfHeight) (y > halfHeight - 7)
    in
      stepObj t { ball | vx = vx2, vy = vy2 }

stepPlyr : Time -> Int -> Int -> Player -> Player
stepPlyr t dir points player =
  let player2 = stepObj t { player | vy = toFloat dir * 200 }
      y2 = clamp (22 - halfHeight) (halfHeight - 22) player2.y
      score2 = player.score + points
  in
    { player2 | y = y2, score = score2 }

stepGame : Input -> Game -> Game
stepGame {space, paddle1, paddle2, delta}
         ({state, ball, player1, player2} as game) =
  let score1 = if ball.x > halfWidth then 1 else 0
      score2 = if ball.x < -halfWidth then 1 else 0

      state2 = if space then Play
               else if score1 /= score2 then Pause
               else state

      ball2 = if state == Pause then ball
              else stepBall delta ball player1 player2

      player1after = stepPlyr delta paddle1 score1 player1
      player2after = stepPlyr delta paddle2 score2 player2

  in
    { game | state   = state2,
             ball    = ball2,
             player1 = player1,
             player2 = player2after}


gameState : Signal Game
gameState = foldp stepGame defaultGame input


-- VIEW
pongGreen = vec3 (60 / 255) (100 / 255) (60 / 255)
white = vec3 1 1 1
blue  = vec3 0 0 1
red   = vec3 1 0 0

gouraudMaterial : Vec3 -> Material
gouraudMaterial color = {
  material | fragmentShader = gouraudShader,
             emissive = MaterialProperty color 1.0,
             ambient  = MaterialProperty white 0.4,
             diffuse  = MaterialProperty white 0.4,
             specular = MaterialProperty white 0.5 }



displayObj : Object a -> Renderable -> Renderable
displayObj object renderable =
  {renderable | position = vec3 object.x object.y 0,
                material = gouraudMaterial blue }

ballShape : Float -> Renderable
ballShape radius =
  { sphere | scale = vec3 radius radius radius,
             material = gouraudMaterial red }

background : Vec3 -> Float -> Float -> Renderable
background color width height =
  { cube | position = vec3 0 0 1,
           scale = vec3 width height 0.5,
           material = gouraudMaterial color }

paddleShape : Float -> Float -> Renderable
paddleShape width height =
  { cube | scale = vec3 width height 1 }

display : (Int, Int) -> Game -> Html msg
display (w,h) {state, ball, player1, player2} =
  let gameCamera = { camera |
        position = vec3 0 0 -550,
        aspectRatio = gameWidth / gameHeight }

      gameLight = { light |
        position = vec3 -3 5 -4 }

      gameDimensions = { width = gameWidth, height = gameHeight }

      gameViewport = { viewport |
        dimensions = gameDimensions }

      gameScene = { scene |
        objects = fromList [
          background pongGreen gameWidth gameHeight,
          displayObj ball (ballShape 15),
          displayObj player1 (paddleShape 10 40),
          displayObj player2 (paddleShape 10 40)
        ],
        camera = gameCamera,
        light  = gameLight,
        viewport = gameViewport }
  in render gameScene

main = map2 display Window.dimensions gameState
