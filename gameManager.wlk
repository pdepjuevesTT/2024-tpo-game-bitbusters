import classes.*
import constants.*

object gameManager {
  method configGame() {
    game.title("Tetris Wollok")
    game.height(22)
    game.width(33)
    game.cellSize(64)
    game.boardGround(sprites.background())
    game.start()
  }

  const gameState = object {
    const property mainMenu = 0
    const property playingGame = 1
    const property gameOver = 2
  }
  
  var currentGameState = null

  var mainMenuBorder = null
  var mainMenuArrow = null
  const arrowStartPos = game.at(14,8)
  var property multiplayer = false
  
  method toogleMultiplayer() {
    multiplayer = !multiplayer

    if(multiplayer) { mainMenuArrow.move(0, -2) }
    else            { mainMenuArrow.move(0,  2) }
  }

  method startMainMenu() {
    currentGameState = gameState.mainMenu()
    
    mainMenuBorder = new GameObject(sprite = sprites.mainMenu())
    mainMenuArrow = new GameObject(sprite = sprites.arrow(), position = arrowStartPos)

    keybinds.wasd().up().onPressDo({ if(currentGameState == gameState.mainMenu()) self.toogleMultiplayer() })
    keybinds.wasd().down().onPressDo({ if(currentGameState == gameState.mainMenu()) self.toogleMultiplayer() })
    keybinds.arrows().up().onPressDo({ if(currentGameState == gameState.mainMenu()) self.toogleMultiplayer() })
    keybinds.arrows().down().onPressDo({ if(currentGameState == gameState.mainMenu()) self.toogleMultiplayer() })

    keyboard.space().onPressDo({ if(currentGameState == gameState.mainMenu()) { self.removeMainMenu(); self.startGame() }})
  }

  method removeMainMenu() {
    game.removeVisual(mainMenuBorder)
    game.removeVisual(mainMenuArrow)
  }

  var gameBorder = null

  method startGame() {
    if(multiplayer) { console.println("STARTING VERSUS GAME...") }
    else { console.println("STARTING SOLO GAME") }

    gameBorder = new GameObject(sprite = sprites.borders())
	
    const board1 = new Board(downPin = game.at(1, 1), upPin = game.at(11, 21))
    const player1 = new Player(
	    board = board1,
      keys = keybinds.wasd()
    )

    if(multiplayer) {
      const board2 = new Board(downPin = game.at(17, 1), upPin = game.at(27, 21))
      const player2 = new Player(
        board = board2,
        keys = keybinds.arrows()
      )
    }
  }
}