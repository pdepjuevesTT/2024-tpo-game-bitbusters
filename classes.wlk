import constants.*

class GameObject
{
  var property position = game.at(0,0)
  
  method move(deltaX, deltaY) { position = game.at(position.x() + deltaX.coerceToInteger(), position.y() + deltaY.coerceToInteger()) }

  method tp(x,y){
    position = game.at(x,y)
  }

  var property sprite = ""
  method setSprite(newSprite) {
    if(newSprite == "") sprite = "empty.png"
    else sprite = newSprite
  }

  method image() = self.sprite()
}

class Block inherits GameObject
{

}

class BlockSet
{
  var property position = game.at(0,0)

  const property board

  var property settled = false

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

class Tetromino inherits BlockSet
{
  const property data

  // ---------- INITIALIZE ----------

  override method initialize() {
    4.times({i => 
      const index = i - 1
      const shape = data.shape().get(index)
      const newBlock = new Block(
        position = game.at(position.x() + shape.x() , position.y() + shape.y()),
        sprite = data.sprite()
      )
      blocks.add(newBlock)
      game.addVisual(newBlock)
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
    
    if(deltaY != 0 && self.verticalCollision(deltaY)) {
      self.settlePiece()
      return true
    }

    return false
  }

  // ---------- SETTLE AND CLEAR LINES ----------

  method settlePiece() {
    blocks.forEach({ block =>
      const relativePos = board.getRelativePosition(block.position())
      board.setValue(relativePos.y(), relativePos.x(), block)
    })
    settled = true
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

    blocks.forEach({ block => 
      dx = block.position().x() - pivot.position().x()
      dy = block.position().y() - pivot.position().y()

      block.position(game.at(pivot.position().x() + dy, pivot.position().y() - dx))
    })
  }
}

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

  method initialize() {
    height.times({i => bitmap.add(new Line(index = i-1, board = self, size = width))})
  }

  method getRelativePosition(position) = game.at(position.x() - downPin.x(), position.y() - downPin.y())

  method setValue(lineIndex, blockIndex, value) = bitmap.get(lineIndex).setValue(blockIndex, value)

  method checkLine(index) {
    const line = bitmap.get(index)

    if(line.isFull()) {
      line.clear(true)
      bitmap.forEach({ line => if(line.index() > index) { line.drop() }})
      return true
    }
    return false
  }

  method calculateScore(clearedLines) {
    if(clearedLines == 0 || clearedLines > 4) { return }
    linesCompleted += clearedLines
    points += constants.scoreValues.get(clearedLines - 1) * level
    if(linesCompleted / 10 > level) { level = level + 1 }
    return
  }
}

class UIPanel {
  
}

class Keys
{
  const property up = keyboard.w()
  const property down = keyboard.s()
  const property left = keyboard.a()
  const property right = keyboard.d()
  const property store = keyboard.q()
}

class Player
{
  const keys
  
  const property board
  var property piecePool = tetrominos.shuffle()

  var property activePiece = new Object()

  method initialize() {
    self.setControls()
    self.pullPiece()

    // game.onTick(500, "gravity", {
    //   activePiece.move(0,-1)
    //   if(activePiece.settled()) { self.pullPiece() }
    // })
  }

  method onGravity() {
    activePiece.move(0,-1)
    if(activePiece.settled()) {
      activePiece.checkAffectedLines()
      self.pullPiece()
    }
  }

  method pullPiece() {
    const shape = piecePool.first()
    piecePool.drop(1)

    if (piecePool.isEmpty()) piecePool = tetrominos.shuffle()

    activePiece = new Tetromino (
      position = game.at((board.downPin().x() + board.upPin().x()).div(2) - 1, board.upPin().y()),
      data = shape,
      board = self.board()
    )
  }

  method setControls() {
    keys.left().onPressDo({activePiece.move(-1,0)})
    keys.right().onPressDo({activePiece.move(1,0)})
    keys.down().onPressDo({self.onGravity()})
    keys.up().onPressDo({activePiece.rotate()})

    //keys.store().onPressDo({self.store()})
  }
}