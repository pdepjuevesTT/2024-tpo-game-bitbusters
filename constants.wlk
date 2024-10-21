object utils {
  method random(min, max) = (min - 1).randomUpTo(max).roundUp()

  method vectorSum(v1, v2) = game.at(v1.x() + v2.x(), v1.y() + v2.y())

  method v2ToString(v) = "(" + v.x().toString() + ";" + v.y().toString() + ")"

  method xyToString(x,y) = self.v2ToString(game.at(x,y))

  method numberToArray(number) {
    const stringArray = number.toString().split("")
    const numberArray = []
    stringArray.forEach({ char => numberArray.add(self.charToInt(char)) })
    
    //console.println("Original Value: " + number + " | Parsed String Array: " + stringArray + " | Parsed Number Array: " + numberArray)
    
    return numberArray.reverse()
  }

  method charToInt(char) {
         if (char == "0") return 0
    else if (char == "1") return 1
    else if (char == "2") return 2
    else if (char == "3") return 3
    else if (char == "4") return 4
    else if (char == "5") return 5
    else if (char == "6") return 6
    else if (char == "7") return 7
    else if (char == "8") return 8
    else if (char == "9") return 9
    else throw new Exception(message = "Trying to convert to int non int character")
  }
}

object color {
  const property red = "FF0000FF"
  const property green = "00FF00FF"
}

object sounds {
  method playOnce(path, soundVolume) {
    const sound = game.sound(path)
    sound.volume(soundVolume)
    sound.play()
  }
}

object sprites {
  const property background = "tetris-background.png"
  const property borders = "tetris-borders.png"
  const property blue = "tetris-blue.png"
  const property cyan = "tetris-cyan.png"
  const property grey = "tetris-grey.png"
  const property green = "tetris-green.png"
  const property orange = "tetris-orange.png"
  const property purple = "tetris-purple.png"
  const property red = "tetris-red.png"
  const property yellow = "tetris-yellow.png"
  const property empty = "empty.png"

  method getNumber(value) {
    if(value < 0 || value > 10) { return "" }

    return "tetris-" + value.coerceToInteger().toString() + ".png"
  }
}

object tetrominos {
  const property t = object
  {
    const property shape = [game.at(0,0), game.at(-1,0), game.at(1,0), game.at(0,-1)]
    const property displayShape = [game.at(0,1), game.at(1,1), game.at(1,0), game.at(2,1)]
    const property sprite = sprites.purple()
  }
  const property o = object
  {
    const property shape = [game.at(0,0), game.at(0,-1), game.at(1,0), game.at(1,-1)]
    const property displayShape = [game.at(0,0), game.at(0,1), game.at(1,0), game.at(1,1)]
    const property sprite = sprites.yellow()
  }
  const property j = object
  {
    const property shape = [game.at(0,0), game.at(0,-1), game.at(0,1), game.at(1,1)]
    const property displayShape = [game.at(0,0), game.at(0,1), game.at(1,0), game.at(2,0)]
    const property sprite = sprites.blue()
  }
  const property l = object
  {
    const property shape = [game.at(0,0), game.at(0,-1), game.at(0,1), game.at(-1,1)]
    const property displayShape = [game.at(0,0), game.at(1,0), game.at(2,0), game.at(2,1)]
    const property sprite = sprites.orange()
  }
  const property i = object
  {
    const property shape = [game.at(0,0), game.at(0,-1), game.at(0,-2), game.at(0,1)]
    const property displayShape = [game.at(0,0), game.at(1,0), game.at(2,0), game.at(3,0)]
    const property sprite = sprites.cyan()
  }
  const property s = object
  {
    const property shape = [game.at(0,0), game.at(-1,0), game.at(0,-1), game.at(1,-1)]
    const property displayShape = [game.at(0,1), game.at(1,1), game.at(1,0), game.at(2,0)]
    const property sprite = sprites.green()
  }
  const property z = object
  {
    const property shape = [game.at(0,0), game.at(1,0), game.at(0,-1), game.at(-1,-1)]
    const property displayShape = [game.at(0,0), game.at(1,0), game.at(1,1), game.at(2,1)]
    const property sprite = sprites.red()
  }

  method shuffle() {return [self.t(),self.o(),self.j(),self.l(),self.i(),self.s(),self.z()].randomized()}

  method debug_shuffle() {return [self.o(),self.o(),self.o(),self.o(),self.o(),self.o(),self.o()]}
 
}

const scoreValues = [2, 5, 15, 60]

object keybinds {
  const property wasd = object
  {
    const property up = keyboard.w()
    const property down = keyboard.s()
    const property left = keyboard.a()
    const property right = keyboard.d()
  }

  const property arrows = object
  {
    const property up = keyboard.up()
    const property down = keyboard.down()
    const property left = keyboard.left()
    const property right = keyboard.right()
  }
}