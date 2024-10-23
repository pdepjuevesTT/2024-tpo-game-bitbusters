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

  // ----------BASIC STUFF-------------

  method configGame() {
    game.title("Tetris Wollok")
    game.height(22)
    game.width(33)
    game.cellSize(64)
    game.boardGround(sprites.background())
    game.start()
  }

  method removeAllVisuals() { game.allVisuals().forEach({visual => game.removeVisual(visual)}) }

  var firstCycle = true

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
    
    if(firstCycle) {
      mainMenuBorder = new GameObject(sprite = sprites.mainMenu())
      mainMenuArrow = new GameObject(sprite = sprites.arrow(), position = arrowStartPos)

      keybinds.wasd().up().onPressDo({ if(currentGameState == gameState.mainMenu()) self.toogleMultiplayer() })
      keybinds.wasd().down().onPressDo({ if(currentGameState == gameState.mainMenu()) self.toogleMultiplayer() })
      keybinds.arrows().up().onPressDo({ if(currentGameState == gameState.mainMenu()) self.toogleMultiplayer() })
      keybinds.arrows().down().onPressDo({ if(currentGameState == gameState.mainMenu()) self.toogleMultiplayer() })

      keyboard.space().onPressDo({ if(currentGameState == gameState.mainMenu()) { self.removeMainMenu(); self.startMainGame() }})
    } else {
      game.addVisual(mainMenuBorder)
      game.addVisual(mainMenuArrow)
    }
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

    if(firstCycle) { gameBorder = new GameObject(sprite = sprites.borders()) }
    else { game.addVisual(gameBorder) }
	
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
    self.removeAllVisuals()
    self.startGameOver()
  }

  // ----------END SCREEN-------------

  var endGameScreen = null
  var bigNumber = null
  
  const bigNumberStartPos = game.at(27, 15)

  const p1gameStatsUIStartPos = game.at(7,5)
  var p1gameStatsUI = null
  
  const p2gameStatsUIStartPos = game.at(27, 5)
  var p2gameStatsUI = null

  method startGameOver() {

    currentGameState = gameState.gameOver()

    // Render endGameScreen and setup key to restart (Always do)
    var endGameScreenSprite
    if(multiplayer) { endGameScreenSprite = sprites.gameOverMultiplayer() }
    else { endGameScreenSprite = sprites.gameOverSingleplayer() }
    
    if(firstCycle){
      endGameScreen = new GameObject(sprite = endGameScreenSprite)

      keyboard.space().onPressDo({if(currentGameState == gameState.gameOver()) self.endGameOver() })
    } else {
      endGameScreen.setSprite(endGameScreenSprite)

      game.addVisual(endGameScreen)
    }

    // Get Board references for later
    var board1
    var board2

    board1 = player1.board()
    if(multiplayer) {board2 = player2.board()}

    // Render big number if multiplayer (Only do when multiplayer)
    if(multiplayer) {
      var bigNumberSprite

      if(board1.points() >= board2.points()) { bigNumberSprite = sprites.big1() }
      else { bigNumberSprite = sprites.big2() }

      if(firstCycle) { bigNumber = new GameObject(sprite = bigNumberSprite, position = bigNumberStartPos) }
      else { game.addVisual(bigNumber) }
    }

    // Render game stats
    p1gameStatsUI = new UIPanel(
      topLeftPin = p1gameStatsUIStartPos,
      spacing = 1,
      hasPieceBoard = false
    )
    p1gameStatsUI.updateUI(board1.points(), board1.linesCompleted(), board1.level())

    if(multiplayer) {
      p2gameStatsUI = new UIPanel(
        topLeftPin = p2gameStatsUIStartPos,
        spacing = 1,
        hasPieceBoard = false
      )
      p2gameStatsUI.updateUI(board2.points(), board2.linesCompleted(), board2.level())
    }
  }

  method endGameOver() {
    firstCycle = false
    self.removeAllVisuals()
    player1 = null
    player2 = null
    p1gameStatsUI = null
    p2gameStatsUI = null
    self.startMainMenu()
  }
}