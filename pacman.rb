class Vector
  attr_reader :x,:y

  def initialize(x,y, direction)
    @x,@y,@direction = x,y,direction
  end

  def cursor
    case @direction
    when :up then "^"
    when :down then "V"
    when :left then "<"
    when :right then ">"
    else
      raise "invalid direction: #{@direction}"
    end
  end

  def move(direction)
    $log.puts "[move] #{direction}"
    case direction
    when :up
      new(@x, (@y - 1) % 3, :up)
    when :down
      new(@x, (@y + 1) % 3, :down)
    when :right
      new((@x + 1) % 3, @y, :right)
    when :left
      new((@x - 1) % 3, @y, :left)
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
    for i in 0..2
      for j in 0..2
        setpos(i,j)
        if history.current.at? j,i
          addstr history.current.cursor
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
    when "A" then history.move :up
    when "B" then history.move :down
    when "C" then history.move :right
    when "D" then history.move :left
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