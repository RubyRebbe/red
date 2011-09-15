#!/usr/bin/ruby
# Hidetoshi Nagai on using tags in Ruby Tk

require 'tk' 
class D
  def initialize(canvas, tag = TkcTag.new(canvas))
    @canvas = canvas
    @tag = tag
    TkcOval.new(@canvas, 20, 20, 40, 40, 'tag'=>tag)
    TkcRectangle.new(@canvas, 5, 5, 50, 50, 'tag'=>[@tag, 'rectangle'])
    TkcRectangle.new(@canvas, 10, 10, 60, 60, 'tag'=>[@tag, 'rectangle'])
    @tag_text = TkcTag.new(@canvas)
    TkcText.new(@canvas, 10, 10, 'text'=>'sample text', 'anchor'=>'nw',
                'tag'=>[@tag, @tag_text])
    TkcText.new(@canvas, 30, 30, 'text'=>'XXXXXXX', 'anchor'=>'nw',
                'tag'=>[@tag, @tag_text])
  end   

	def move(dx, dy)
    @tag.move(dx, dy)
  end   

	def move_text(dx, dy)
    @tag_text.move(dx, dy)  # or @canvas.move(@tag_text, dx, dy)
  end   

	def move_rectangle(dx, dy)
    @canvas.move('rectangle', dx, dy)
  end
end 

TkRoot.new.title('Tk fun with tags')
canvas = TkCanvas.new.pack
objs = D.new(canvas)
TkFrame.new {|f|
  TkButton.new(f, 'text'=>'move (+10,+10)',
               'command'=>proc{objs.move(10,10)}).pack('side'=>'left')
  TkButton.new(f, 'text'=>'move (-10,-10)',
               'command'=>proc{objs.move(-10,-10)}).pack('side'=>'right')
  pack
}

TkFrame.new {|f|
  TkButton.new(f, 'text'=>'move rectangle (+10,+10)',
               'command'=>proc{objs.move_rectangle(10,10)}) {
    pack('side'=>'left')
  }
  TkButton.new(f, 'text'=>'move rectangle (-10,-10)',
               'command'=>proc{objs.move_rectangle(-10,-10)}) {
    pack('side'=>'right')
  }
  pack
}

TkFrame.new {|f|
  TkButton.new(f, 'text'=>'move text (+10,+10)',
               'command'=>proc{objs.move_text(10,10)}).pack('side'=>'left')
  TkButton.new(f, 'text'=>'move text (-10,-10)',
               'command'=>proc{objs.move_text(-10,-10)}).pack('side'=>'right')
  pack
} 

Tk.mainloop
