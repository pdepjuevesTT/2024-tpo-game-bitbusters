import constants.*

class GameObject
{
  var property position = game.at(0,0)

  var property frozen = false
  method move(deltaX, deltaY) {
    if(frozen) {return}
    position = game.at(position.x() + deltaX.coerceToInteger(), position.y() + deltaY.coerceToInteger())
    return
  }
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

  method initialize()

  method move(deltaX, deltaY) {
    if(self.outOfBounds(deltaX, deltaY)) { return }


    blocks.forEach({ elem =>
      elem.move(deltaX, deltaY)
    })
    return
  }

  method outOfBounds(deltaX, deltaY) {
    var newX
    var newY
    var outOfBounds = false

    blocks.forEach({ block =>
      if (!outOfBounds) {
        newX = block.position().x() + deltaX
        newY = block.position().y() + deltaY
        outOfBounds =
           newX < self.board().downPin().x()
        || newY < self.board().downPin().y()
        || newX > self.board().upPin().x() - 1
        || newY > self.board().upPin().y()
      }
    })
    return outOfBounds
  }

  var property blocks = []
}

class Tetromino inherits BlockSet
{
  const property data

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
}

class Line inherits BlockSet
{
  var property index
  const property size

  override method initialize() {
    size.times({i => blocks.add(0)})
  }

  method isFull() {
    return blocks.all({elem => elem != 0})
  }

  method clear() {
    blocks = []
    size.times(blocks.add(0))
  }
}

class Board
{
  const property downPin
  const property upPin
  var property width = upPin.x() - downPin.x()
  var property height = upPin.y() - downPin.y()

  const property bitmap = []

  method initialize() {
    height.times({i => bitmap.add(new Line(index = i-1, board = self, size = width))})
  }
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
  var property piecePool = tetrominos.debug_shuffle()

  var property activePiece = new Object()

  method initialize() {
    self.setControls()
    self.pullPiece()

    game.onTick(500, "gravity", {
      activePiece.move(0,-1)
    })
  }

  method pullPiece() {
    const shape = piecePool.first()
    piecePool.drop(1)

    if (piecePool.isEmpty()) piecePool = tetrominos.debug_shuffle()

    activePiece = new Tetromino (
      position = game.at(board.upPin().x().div(2), board.upPin().y()),
      data = shape,
      board = self.board()
    )
  }

  method setControls() {
    keys.left().onPressDo({activePiece.move(-1,0)})
    keys.right().onPressDo({activePiece.move(1,0)})
    keys.down().onPressDo({activePiece.move(0,-1)})

    //keys.up({activePiece.rotate()})
    //keys.store({self.store()})
  }
}