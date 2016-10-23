require 'yaml'

class Square
  attr_accessor :flagged, :revealed
  attr_reader :bomb, :number

  def initialize(bomb = false, number = 0)
    @number = number #nil, 0, 1, 2, or 3
    @bomb = bomb #true or false

    @flagged = false
    @revealed = false
  end

  def render
    if revealed
      if bomb
        "b"
      elsif number > 0
        "#{number}"
      else
        "_"
      end
    elsif flagged
      "f"
    else
      "*"
    end
  end

end

class Minesweeper
  def play
    playing = true
    while playing == true
      round
      puts "would you like to play again?"
      playing = false unless gets.chomp.downcase == 'y'
    end
    puts "Game over."
  end

private

  def round
    @board = Board.new
    start_time = Time.now

    game_status = :go
    while game_status == :go
      show(start_time)
      input = get_input
      case input
      when :f
        puts "Enter coordinates:"
        game_status = @board.flag(get_coords(gets.chomp))
      when :s
        save
        puts "game-saved"
      when :l
        load
        puts "New Game Loaded."
      else
        game_status = @board.click(input)
      end
    end

    show(start_time)
    end_round(game_status)
  end

  def end_round(game_status)
    case game_status
    when :lost
      puts "you got blown up :("
    when :won
      puts "you won!"
    end
  end

  def get_coords(string_coord)
    string_coord.split(" ").map(&:to_i)
  end

  def valid_input?(input)
   inputs = [:f,:l,:s]
   (input =~ /\d\s\d/) == 0 && @board.in_bounds?(get_coords(input)) || inputs.include?(input[0..1].to_sym)
  end

  def get_input ## validity tests
    input = "Hello Kyle."
    until valid_input?(input)
      puts "What's next: s) save, l) load, f) flag, or enter a coordinate (ex: 0 0)"
      input = gets.chomp
      puts "oops, bad input" unless valid_input?(input)
    end

    if (input =~ /\d\s\d/) == 0
      return get_coords(input)
    else
      return input[0..1].to_sym
    end
  end

  def save
    serialized_board = @board.dup.to_yaml
    puts "save game as:"
    filename = gets.chomp
    File.open("#{filename}.txt", "w") { |f| f.print serialized_board }
  end

  def load
    puts "load game called:"
    filename = gets.chomp
    serialized_board = File.read("#{filename}.txt")
    @board = YAML::load(serialized_board)
  end

  def convert_seconds (seconds)
    minutes = seconds / 60
    seconds = seconds % 60

    minutes = "0#{minutes}" if minutes < 10
    seconds = "0#{seconds}" if seconds < 10

    "#{minutes}:#{seconds}"
  end

  def show(start)
    puts "number of mines: #{@board.bombs} | flags: #{@board.flags}"
    puts "    0 1 2 3 4 5 6 7 8"
    puts "    -----------------"
    @board.board_display.each_with_index do |row, i|
      print "#{i} | "
      row.each do |square|
        print "#{square} "
      end
      puts
    end
    current = Time.now
    puts "Time elapsed: #{convert_seconds((current - start).to_i)}"
  end
end

class Board

  attr_reader :flags

  XADD = [-1,0,1,1,1,0,-1,-1]
  YADD = [1,1,1,0,-1,-1,-1,0]

  def initialize(size = 9, number_of_bombs = 10)
    @size = size
    # [[sq,b,sq],
    #  [sq,sq,sq],
    #  [sq,sq,sq]]
    @board = Array.new(9) { [Square.new(false, 0)]*9 }
    @flags = 0
    @bomb_coords = create_bombs(number_of_bombs)
    make_board(@bomb_coords)
    puts "debug:"
    show_debug
    puts "the one"
  end

  def bombs
    @bomb_coords.size
  end

  def won?
    return false unless @bomb_coords.size == @flags
    @bomb_coords.all? { |coord| @board[coord[0]][coord[1]].flagged }
  end

  def flag(coord)
    square = @board[coord[0]][coord[1]]
    return :go if square.revealed
    if square.flagged
      @flags -= 1
    else
      @flags += 1
    end
    square.flagged = !square.flagged
    return :won if won?
    :go
  end

  def click(coord)
    square = @board[coord[0]][coord[1]]
    if square.flagged == true
      square.flagged = false
      @flags -= 1
      return :won if won?
    else
      if square.bomb
        square.revealed = true
        return :lost
      elsif square.number == 0
        reveal(coord)
      else
        square.revealed = true
      end
    end
    :go
  end

  def reveal(coord)
    #call reveal on all the neighbors
    square = @board[coord[0]][coord[1]]

    if square.flagged || square.revealed || square.bomb
      return
    elsif square.number > 0
       square.revealed = true
    else #if number == 0
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
      row.each_with_index { |square, j| board_display[i][j] = square.render }
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
