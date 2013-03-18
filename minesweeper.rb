class Square
  attr_accessor :flagged, :clicked
  attr_reader :bomb, :number

  def initialize(bomb = false, number = 0)
    @number = number #nil, 0, 1, 2, or 3
    @bomb = bomb #true or false

    @flagged = false
    @clicked = false
  end

end

class Board

  def initialize(size = 9, number_of_bombs = 10)

    @size = size
    # [[sq,b,sq],
    #  [sq,sq,sq],
    #  [sq,sq,sq]]
    @board = Array.new(9) {[Square.new(false, 0)]*9}
    bomb_coords = create_bombs(number_of_bombs)
    make_board(bomb_coords)
    show
  end

  def make_board(bomb_coords)
    ## add bombs
    bomb_coords.each { |bomb| @board[bomb[0]][bomb[1]] = Square.new(true) }
    ## add squares, based on bombs
    @board.each_with_index do |row, i|
      row.each_with_index do |square, j|
        @board[i][j] = Square.new(false, count_bombs([i,j])) unless @board[i][j].bomb
      end
    end
  end

  #return number of surrounding bombs
  def count_bombs(coord)

    xadd = [-1,0,1,1,1,0,-1,-1]
    yadd = [1,1,1,0,-1,-1,-1,0]
    num_bombs = 0

    xadd.length.times do |i|
      check = [coord[0]+yadd[i], coord[1]+xadd[i]]
      if in_bounds?(check) && @board[check[0]][check[1]].bomb
        num_bombs += 1
      end
    end
    num_bombs
  end

  def in_bounds?(coord)
    coord[0] < @size && coord[0] >= 0 && coord[1] < @size && coord[1] >= 0
  end

  def create_bombs(num_bombs)
    bomb_array = [ ]
    until bomb_array.length == num_bombs
      new_bomb = [ rand(@size), rand(@size) ]
      bomb_array << new_bomb unless bomb_array.include?(new_bomb)
    end
    bomb_array
  end

  def show
    @board.each do |row|
      row.each do |square|
        if square.bomb
          print "b "
        elsif square.number > 0
          print "#{square.number} "
        else
          print "* "
        end
      end
      puts "\n"
    end
  end

end

a = Board.new(9,10)