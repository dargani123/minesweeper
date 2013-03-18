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

class Minesweeper
  def initialize
    @board = Board.new
  end


  def play
    ##loop
      ##get input
      ##valid input?

      ##call click on that square
    #repeat
    loop do
      show
      flag, coord = get_input
      if flag
        @board.flag( coord )
      else
        @board.click( coord )
      end
    end


  end

  def get_input  ##  doesn't test valid?
    flag = false
    puts "enter coordinate on the board to click, enter 'f' to flag"
    input = gets.chomp
    if input == "f"
      flag = true
      puts "enter coordinate on the board to flag"
      input = gets.chomp
       coord = input.split(" ").map(&:to_i) ## 1 1
    else
      coord = input.split(" ").map(&:to_i) ## 1 1
    end
    [flag, coord]
  end






  def show
    @board.board_display.each do |row|
      row.each do |square|
        print "#{square} "
      end
      puts
    end
  end


  # def show_cheat
#     @board.each do |row|
#       row.each do |square|
#         if square.bomb
#           print "b "
#         elsif square.number > 0
#           print "#{square.number} "
#         else
#           print "* "
#         end
#       end
#       puts "\n"
#     end
#   end

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
    puts "debug:"
    show_debug
    puts "the one"
  end

  def flag

  end

  def click(coord)
    square = @board[ coord[0] ][ coord[1] ]
    if square.flagged == true
      square.flagged = false
    else
        if square.bomb
          return "bomb"
        elsif square.number == 0
          reveal(coord)
        else
          square.revealed = true
        end
    end
  end

  def reveal(coord)
    #call reveal on all the neighbors
    #
    square = @board[coord[0]][coord[1]]

    if square.number > 0
      square.revealed = true
    elsif square.bomb || square.flagged || square.revealed
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

  def board_display
    board_display = Array.new(9) { [nil]*9 }
    @board.each_with_index do |row, i|
      row.each_with_index do |square, j|
        if square.revealed
          if @board[i][j].bomb
            board_display[i][j] =  "b"
          elsif @board[i][j].number > 0
            board_display[i][j] = "#{square.number}"
          else
            board_display[i][j] = "_"
          end
        else
          board_display[i][j] =  "*"
        end
      end
    end
    board_display
  end


  def show_debug
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

Minesweeper.new.play