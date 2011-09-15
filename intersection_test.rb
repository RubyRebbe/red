# Tests module intersection
require 'tk'
require 'uonObject.rb'
require 'perp.rb'

class UONEditorTest
  def initialize( ed)
    @w, @h = 75, 50
    x0, y0 = 100, 100
    x1, y1 = x0 + @w, y0 + @h
    @uonEditor = ed
    @action = UONAction.new( ed.getModelCanvas, x0, y0, x1, y1, ed)
    @outsidePoint = @action.getCenter
    @outsidePoint[0] = @outsidePoint[0] + @w
  end

  def testWidth
   puts "test width = #{@action.width}, actual width = #{@w}"
  end

  def testHeight
    puts "test height = #{@action.height}, actual width = #{@h}"
  end

  def testOutsidePoint
    terminus =
      UONAssociator.new( @uonEditor.getModelCanvas, @outsidePoint[0], @outsidePoint[1],
      @outsidePoint[0] + 5, @outsidePoint[1] + 5, @uonEditor)
    puts "test outside Point = #{@outsidePoint[0]}, #{@outsidePoint[1]}"
    puts "actual outside Point = 212, 125"
  end

  def testisIntersectSides
    puts "line intersects side is true:  #{@action.isIntersectSides(@outsidePoint)}"
  end

  def testIntersection
    ip = @action.intersection( @outsidePoint)
    puts "test intersection point rel center: #{ip[0]}, #{ip[1]}"
    puts "expected intersection point:  37.5, 0.0"
    n = 6; f = n.to_f
    puts "float 6: #{f}"
  end

  def testPerpClass
    u, v = [1,1], [3, 4]
    perpItem = Perp.new( u, v)
    puts "BEGIN test Perp class"
    perp = perpItem.getPerp
    puts "the perpendicular:  #{perp[0]}, #{perp[1]}"
    dt = VA.dot( u, perp)
    puts "dot product u . perp = #{dt}"
    puts "assert:  v == alpha*u + beta*perp"
    puts "u = #{u[0]}, #{u[1]}"
    puts "v = #{v[0]}, #{v[1]}"
    sumvec = VA.add(
      VA.mul(perpItem.getAlpha, u),
      VA.mul(perpItem.getBeta, perp)
    )
    puts "sum vector (compared to v:  #{sumvec[0]}, #{sumvec[1]}"
    puts "alpha = #{perpItem.getAlpha}, beta = #{perpItem.getBeta}"
    puts "END test Perp class"
  end

  def testLineClass
    u, v = [1,1], [3, 4]
    puts "u = #{u[0]}, #{u[1]}"
    puts "v = #{v[0]}, #{v[1]}"
    aLine = Line.new( u, v)
    b = aLine.getPoint( 0)
    e = aLine.getPoint(1)
    puts "begin = #{b[0]}, #{b[1]}"
    puts "end = #{e[0]}, #{e[1]}"
    # create a parallel line, dx = 1
    dx = 1
    pu, pv = VA.add( u, [dx, 0]), VA.add( v, [dx,0])
    pLine = Line.new( pu, pv)
    b = aLine.isParallel(pLine)
    puts "pLine is parallel to aLine: #{b}"
   end

  def testIntersectLines
    line0 = Line.new [0,0], [0,1]
    line1 = Line.new [0,0], [1,1]
    puts "BEGIN test intersect lines"
    puts "line0:  #{line0}"
    puts "line1:  #{line1}"
    puts "line0 is parallel to line1:  #{line0.isParallel(line1)}"
    i = IntersectLines.new( line0, line1)
    p = i.getIntersection
    puts "intersection point: #{p[0]}, #{p[1]}"
    puts "displacement:  #{i.getdisplace}"

    line0 = Line.new [0, 1], [ 1, 0]
    line1 = Line.new [0, 0], [10, 10]
    puts "Second test"
    puts "line0:  #{line0}"
    puts "line1:  #{line1}"
    puts "line0 is parallel to line1:  #{line0.isParallel(line1)}"
    i = IntersectLines.new( line0, line1)
    p = i.getIntersection
    puts "intersection point: #{p[0]}, #{p[1]}"
    puts "displacement:  #{i.getdisplace}"
    puts "END test intersect lines"
  end

  def runTest
    self.testPerpClass
    self.testLineClass
    self.testIntersectLines
  end
end
