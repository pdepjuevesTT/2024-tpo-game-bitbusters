import gameManager.*
import constants.*

// ||||||||||||||GAMEOBJECT|||||||||||||||||||
class GameObject
{
  var property position = game.at(0,0)
  
  method initialize() { game.addVisual(self) }

  method move(deltaX, deltaY) { position = game.at(position.x() + deltaX.coerceToInteger(), position.y() + deltaY.coerceToInteger()) }

  method tp(x,y){
    position = game.at(x,y)
  }

  var property sprite = ""
  method setSprite(newSprite) {
    if(newSprite == "") sprite = sprites.empty()
    else sprite = newSprite
  }

  method image() = self.sprite()
}

// ||||||||||||||BLOCKSET|||||||||||||||||||
class BlockSet
{
  var property position = game.at(0,0)

  const property board

  method initialize()

  method moveAll(deltaX, deltaY) {
    blocks.forEach({ elem =>
      if(elem != 0) elem.move(deltaX, deltaY)
    })
  }

  method checkCollision(horizontal, delta, minimum, maximum) {
    var actualPos
    var newP
    var newRelP
    var collision = false

    blocks.forEach({ block =>
      if(!collision) {
        if(horizontal) { actualPos = block.position().x() }
        else           { actualPos = block.position().y() }

        newP = actualPos + delta
        
        if(horizontal) { newRelP = board.getRelativePosition(game.at(newP, block.position().y())) }
        else           { newRelP = board.getRelativePosition(game.at(block.position().x(), newP)) }

        collision = (newP < minimum || newP > maximum)
        if(!collision && newRelP.y() != board.height()) { collision = (board.bitmap().get(newRelP.y()).blocks().get(newRelP.x()) != 0) }
      }
    })

    return collision
  }

  method horizontalCollision(deltaX) = self.checkCollision(true, deltaX, self.board().downPin().x(), self.board().upPin().x() - 1)

  method verticalCollision(deltaY) = self.checkCollision(false, deltaY, self.board().downPin().y(), self.board().upPin().y() + 1)

  var property blocks = []
}

// ||||||||||||||TETROMINO|||||||||||||||||||
class Tetromino inherits BlockSet
{
  const property data

  var property settled = false

  // ---------- INITIALIZE ----------

  override method initialize() {
    4.times({i => 
      const index = i - 1
      const shape = data.shape().get(index)
      const newBlock = new GameObject(
        position = game.at(position.x() + shape.x() , position.y() + shape.y()),
        sprite = data.sprite()
      )
      blocks.add(newBlock)
    })
  }

  // ---------- MOVEMENT ----------

  method move(deltaX, deltaY) {
    if(self.preMoveChecks(deltaX, deltaY)) { return }

    self.moveAll(deltaX, deltaY)

    return
  }

  method preMoveChecks(deltaX, deltaY) {
    if(deltaX != 0 && self.horizontalCollision(deltaX)) { return true }
    
    const shouldSettle = deltaY != 0 && self.verticalCollision(deltaY)

    if(shouldSettle) {
      self.settlePiece()
    }

    return shouldSettle
  }

  // ---------- SETTLE AND CLEAR LINES ----------

  method settlePiece() {
    var shouldLose = false
    blocks.forEach({ block =>
      const relativePos = board.getRelativePosition(block.position())
      if(relativePos.y() >= board.height()) { shouldLose = true; game.removeVisual(block) }
      else { board.setValue(relativePos.y(), relativePos.x(), block) }
    })
    if(shouldLose) { board.onLoseGame() }
    else { settled = true }
  }

  method checkAffectedLines() {
    const affectedLines = new Set()
    blocks.forEach({ block =>
      affectedLines.add(board.getRelativePosition(block.position()).y())
    })
    
    var clearedLines = 0
    affectedLines.forEach({ lineIndex => 
      if(board.checkLine(lineIndex)) clearedLines += 1
    })

    board.calculateScore(clearedLines)
  }

  // ---------- ROTATION ----------

  method rotate() {
    const pivot = blocks.first()
    var dx
    var dy

    var blocked = false
    const newPositions = []
    const newRelPositions = []

    blocks.forEach({ block =>
      dx = block.position().x() - pivot.position().x()
      dy = block.position().y() - pivot.position().y()

      newPositions.add(game.at(pivot.position().x() + dy, pivot.position().y() - dx))
    })

    newPositions.forEach({pos => newRelPositions.add(board.getRelativePosition(pos))})

    var i
    var newPos
    var newRelPos
    4.times({_i => i = _i - 1
      if(!blocked)
      {
        newPos = newPositions.get(i)
        newRelPos = newRelPositions.get(i)

        blocked = 
            newPos.x() < board.downPin().x()
        ||  newPos.x() > board.upPin().x() - 1
        ||  newPos.y() < board.downPin().y()
        ||  newPos.y() > board.upPin().y() + 1
        ||  board.bitmap().get(newRelPos.y()).blocks().get(newRelPos.x()) != 0
      }
    })

    if(!blocked) {4.times({_i => blocks.get(_i-1).position(newPositions.get(_i-1))})}
  }
}

// ||||||||||||||LINE|||||||||||||||||||
class Line inherits BlockSet
{
  var property index
  const property size

  override method initialize() {
    size.times({i => blocks.add(0)})
  }

  method drop() {
    var relPos
    self.moveAll(0, -1)
    blocks.forEach({ block => 
      if(block != 0) {
        relPos = board.getRelativePosition(block.position())
        board.setValue(self.index() - 1, relPos.x(), block)
      }
    })
    self.clear(false)
  }

  method isFull() = blocks.all({elem => elem != 0})

  method isEmpty() = blocks.all({elem => elem == 0})

  method clear(removeVisual) {
    if(removeVisual) blocks.forEach({ block => game.removeVisual(block) })
    blocks.clear()
    size.times({i => blocks.add(0)})
  }
  
  method setValue(i, value) {
    var newLine = blocks.take(i)
    newLine.add(value)
    newLine += blocks.drop(i + 1)
    blocks = newLine
  }
}

// ||||||||||||||BOARD|||||||||||||||||||
class Board
{
  const property downPin
  const property upPin
  var property width = upPin.x() - downPin.x()
  var property height = upPin.y() - downPin.y()

  var property bitmap = []

  var property points = 0
  var property linesCompleted = 0
  var property level = 1

  var property uiPanel = null

  method initialize() {
    height.times({i => bitmap.add(new Line(index = i-1, board = self, size = width))})
    uiPanel = new UIPanel(
      topLeftPin = game.at(upPin.x() + 1, upPin.y() - 1),
      spacing = 3,
      hasPieceBoard = true
    )
    uiPanel.updateUI(points, linesCompleted, level)
  }

  method getRelativePosition(position) = game.at(position.x() - downPin.x(), position.y() - downPin.y())

  method setValue(lineIndex, blockIndex, value) = bitmap.get(lineIndex).setValue(blockIndex, value)

  method checkLine(index) {
    const line = bitmap.get(index)

    const lineFull = line.isFull()

    if(lineFull) {
      line.clear(true)
      bitmap.forEach({ line => if(line.index() > index) { line.drop() }})
    }
    
    return lineFull
  }

  const linesToLevelup = 5

  method calculateScore(clearedLines) {
    if(clearedLines == 0 || clearedLines > 4) { return }
    linesCompleted += clearedLines
    points += constants.scoreValues.get(clearedLines - 1) * level
    if(linesCompleted / linesToLevelup > level) {
      level = level + 1;
      
      if(level < 10) { self.updateTickSpeed() }
    }

    uiPanel.updateUI(points, linesCompleted, level)
    return
  }

  var property player = null

  method setPlayer(playerRef) { player = playerRef }

  method updateTickSpeed() {
    const newTickMs = 700 - (0.6 * level)
    player.updateGravity(newTickMs)
  }

  var gameOverCard = null

  method onLoseGame() {
    gameOverCard = new GameObject(sprite = sprites.playerLost(), position = self.downPin())
    player.onLostGame()
  }
}

// ||||||||||||||UIPANEL|||||||||||||||||||
class UIPanel {
  const property topLeftPin
  const property spacing
  const property hasPieceBoard

  var property linesBoard = null
  var property pointsBoard = null
  var property levelBoard = null
  var property nextPieceBoard = null

  method initialize() {
    const startingHeight = topLeftPin.y() - 1
    const linesBoardPos = game.at(topLeftPin.x(), startingHeight)
    const pointsBoardPos = game.at(topLeftPin.x(), startingHeight - spacing)
    const levelBoardPos = game.at(topLeftPin.x(), startingHeight - (2 * spacing))

    linesBoard = new UINumberBoard(startPos = linesBoardPos, size = 4)
    pointsBoard = new UINumberBoard(startPos = pointsBoardPos, size = 4)
    levelBoard = new UINumberBoard(startPos = levelBoardPos, size = 4)

    if(hasPieceBoard) {
      const nextPieceBoardPos = game.at(topLeftPin.x(), topLeftPin.y() - (4 * spacing))
      nextPieceBoard = new UIPieceBoard(startPos = nextPieceBoardPos)
    }
  }

  method setLines(value) { linesBoard.setValue(value) }
  method setPoints(value) { pointsBoard.setValue(value) }
  method setLevel(value) { levelBoard.setValue(value) }
  method displayPiece(data) { nextPieceBoard.display(data) }

  method updateUI(points, linesCompleted, level) {
    self.setPoints(points)
    self.setLines(linesCompleted)
    self.setLevel(level)
  }
}

class UIPieceBoard{
  const property startPos

  const property blocks = []

  method display(data) {
    var i
    4.times({ _i => i = _i - 1
      const shape = data.displayShape().get(i)

      if (blocks.size() != 4) { // If still uninitialized create the blocks
        const newBlock = new GameObject(
          position = game.at(startPos.x() + shape.x() , startPos.y() + shape.y()),
          sprite = data.sprite()
        )
        blocks.add(newBlock)
      } else { // Else only modify them
        const block = blocks.get(i)
        block.tp(startPos.x() + shape.x() , startPos.y() + shape.y())
        block.setSprite(data.sprite())
      }
    })
  }
}

class UINumberBoard {
  const property startPos
  const property size
  var property numberList = []
  var property value = 0

  method initialize() {
    size.times({i => numberList.add(new UINumber(
      position = game.at(startPos.x() + numberList.size(), startPos.y())
    ))})
    numberList = numberList.reverse() // Reverse for more clear iteration
  }

  method setValue(newValue) {
    // Coerce to nearest displayable value
    if      (newValue > (10 ** size)) { value = (10 ** size) - 1 }
    else if (newValue < 0           ) { value = 0 }
    else                              { value = newValue }

    const valueArray = utils.numberToArray(value)
    (size - valueArray.size()).times({i => valueArray.add(0)})
    // console.println("Original Value: " + newValue + " | Parsed Array: " + valueArray)

    var i
    size.times({ _i => i = _i - 1
      numberList.get(i).setValue(valueArray.get(i))
    })
  }
}

class UINumber inherits GameObject{
  method initialize() { game.addVisual(self); self.setValue(0) }

  method setValue(value) { self.setSprite(sprites.getNumber(value)) }
}

// ||||||||||||||PLAYER|||||||||||||||||||
class Player
{
  const keys
  
  const property board
  var property piecePool = tetrominos.shuffle()

  var property activePiece = null
  var property lost = false

  const gravityEvent = "gravity-" + board.downPin().x().toString()

  method initialize() {
    self.setControls()
    self.pullPiece()
    board.setPlayer(self)
    game.onTick(640, gravityEvent, { self.onGravity() })
  }

  method onLostGame() {
    lost = true
    self.removeGravity()
    gameManager.onPlayerLost()
  }

  method onGravity() {
    activePiece.move(0,-1)
    if(activePiece.settled()) {
      activePiece.checkAffectedLines()
      self.pullPiece()
    }
  }
  
  method updateGravity(ms) {
    self.removeGravity()
    game.onTick(ms, gravityEvent, { self.onGravity() })
  }

  method removeGravity() { game.removeTickEvent(gravityEvent) }

  method pullPiece() {
    const shape = piecePool.first()
    piecePool = piecePool.drop(1)

    if (piecePool.isEmpty()) piecePool = tetrominos.shuffle()

    activePiece = new Tetromino (
      position = game.at((board.downPin().x() + board.upPin().x()).div(2) - 1, board.upPin().y()),
      data = shape,
      board = self.board()
    )

    board.uiPanel().displayPiece(piecePool.first())
  }

  method setControls() {
    keys.left().onPressDo({ if(!lost) { activePiece.move(-1,0) }})
    keys.right().onPressDo({ if(!lost) { activePiece.move(1,0) }})
    keys.down().onPressDo({ if(!lost) { self.onGravity() }})
    keys.up().onPressDo({ if(!lost) { activePiece.rotate() }})
  }
}