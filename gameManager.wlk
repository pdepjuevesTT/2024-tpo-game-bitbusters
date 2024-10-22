import classes.*
import constants.*

object gameManager {
  // ----------MAIN SCRIPT----------------

  method start() {
    // Config Wollok Game
    self.configGame()
	
    // Handle Main Menu
    self.startMainMenu()
  }

  // ----------BASIC CONFIGS-------------

  method configGame() {
    game.title("Tetris Wollok")
    game.height(22)
    game.width(33)
    game.cellSize(64)
    game.boardGround(sprites.background())
    game.start()
  }

  // ----------GAMESTATE-------------

  const gameState = object {
    const property mainMenu = 0
    const property playingGame = 1
    const property gameOver = 2
  }
  
  var currentGameState = null

  // ----------MAIN MENU-------------

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

    keyboard.space().onPressDo({ if(currentGameState == gameState.mainMenu()) { self.removeMainMenu(); self.startMainGame() }})
  }

  method removeMainMenu() {
    game.removeVisual(mainMenuBorder)
    game.removeVisual(mainMenuArrow)
  }

  // ----------MAIN GAME-------------

  var gameBorder = null

  var player1 = null
  var player2 = null

  method startMainGame() {
    currentGameState = gameState.playingGame()

    gameBorder = new GameObject(sprite = sprites.borders())
	
    player1 = new Player(
	    board = new Board(downPin = game.at(1, 1), upPin = game.at(11, 21)),
      keys = keybinds.wasd()
    )

    if(multiplayer) {
      player2 = new Player(
        board = new Board(downPin = game.at(17, 1), upPin = game.at(27, 21)),
        keys = keybinds.arrows()
      )
    }
  }

  method onPlayerLost() {
    if(!multiplayer) { self.endMainGame() }
    else if (player1.lost() && player2.lost()) { self.endMainGame() }
  }

  method endMainGame() {
    game.allVisuals().forEach({visual => game.removeVisual(visual)})
  }

  // ----------END SCREEN-------------
}