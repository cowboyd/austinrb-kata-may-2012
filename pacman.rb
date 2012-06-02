BOARD_SIZE=8

class Vector
  attr_reader :x,:y, :direction

  def initialize(x,y, direction)
    @x,@y,@direction = x,y,direction
  end

  def move(direction)
    $log.puts "[move] #{direction}"
    case direction
    when :up
      new(@x, (@y - 1) % BOARD_SIZE, :up)
    when :down
      new(@x, (@y + 1) % BOARD_SIZE, :down)
    when :right
      new((@x + 1) % BOARD_SIZE, @y, :right)
    when :left
      new((@x - 1) % BOARD_SIZE, @y, :left)
    else
      fail "what is this direction? #{direction}"
    end
  end

  def at?(x,y)
    @x == x && @y == y
  end

  def new(*args)
    self.class.new(*args)
  end

  def to_s
    "(#{x},#{y},#{@direction.to_sym})"
  end

end

class History
  def initialize
    @locations = [Vector.new(1,1,:up)]
  end

  def contains(x,y)
    @locations.detect {|l| l.at? x,y}
  end

  def current
    @locations.last
  end

  def move(direction)
    @locations << current.move(direction)
  end
end

require 'curses'
class Screen
  include Curses

  def initialize
    init_screen
    noecho
  end

  def getch
    super.tap do |c|
      $log.puts("[received character] #{c.class.name}:#{c.inspect}")
    end
  end

  def render(history)
    for i in 0..BOARD_SIZE-1
      for j in 0..BOARD_SIZE-1
        setpos(i,j)
        if history.current.at? j,i
          addstr case history.current.direction
                 when :up then "V"
                 when :down then "^"
                 when :left then ">"
                 when :right then "<"
                 else
                   raise "invalid direction: #{@direction}"
                 end
        elsif history.contains j,i
          addstr " "
        else
          addstr "."
        end
      end
    end
    refresh
  end

  def read(history)
    case getch
    when "A" then
      history.move :up if history.current.y != 0
    when "B" then
      history.move :down if history.current.y < BOARD_SIZE-1
    when "C" then
      history.move :right  if history.current.x < BOARD_SIZE-1
    when "D" then
      history.move :left  if history.current.x != 0
    else
      #not an arrow key.
    end
  end
end

screen = Screen.new
history = History.new

File.open('pacman.log', 'a') do |log|
  $log = log
  $log.sync = true
  $log.puts '[start]'
  loop do
    $log.puts "[position] #{history.current}"
    screen.render history
    screen.read history
  end
end
