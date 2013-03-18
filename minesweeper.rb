class Square
  attr_accessor :flagged, :revealed
  attr_reader :bomb, :number

  def initialize(bomb = false, number = 0)
    @number = number #nil, 0, 1, 2, or 3
    @bomb = bomb #true or false

    @flagged = false
    @revealed = false
  end

end





class Board

  XADD = [-1,0,1,1,1,0,-1,-1]
  YADD = [1,1,1,0,-1,-1,-1,0]

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


  def click(coord)
    x, y = coord[0], coord[1]
    if @board[x][y].flagged == false
      @board[x][y].flagged = true
    else
        if @board[x][y].bomb
          return "bomb"
        elsif @board[x][y].number == 0
          reveal(coord)
        else
          @board[x][y].revealed = true
        end
    end
  end

  def reveal(coord)
    #call reveal on all the neighbors
    #
    square = @board[coord[0]][coord[1]]

    if square.number > 0
      square.revealed = true
    elsif square.bomb || square.flagged
      return
    else #if number == 0       ##refactor , same as count_bombs
      square.revealed = true
      get_neighbors(coord).each {|neighbor| reveal(neighbor)}
    end

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

  def get_neighbors (coord) ## Returns coordinates of inbound nieghbors
    neighbors = []
    XADD.length.times do |i|
      check = [coord[0]+YADD[i], coord[1]+XADD[i]]
      neighbors << check if in_bounds?(check)
    end
    neighbors
  end

  #return number of surrounding bombs
  def count_bombs(coord)  ##refactor
    num_bombs = 0
    get_neighbors(coord).each { |neighbor| num_bombs += 1 if @board[neighbor[0]][neighbor[1]].bomb }
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