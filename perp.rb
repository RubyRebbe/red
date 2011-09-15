require 'uonObject.rb'

module VA
  # dot product of two arrays of numbers
  def VA.dot( u, v)
    r = 0
    for k in 0..(u.length - 1)
      r = r + u[k]*v[k]
    end
    r
  end # method dot

  # product of scalar alpha with vector v
  def VA.mul( alpha, v)
    r = []
    v.each { |e|  r.push alpha*e }
    r
  end

  def VA.add( u, v)
    r = []
    for k in 0..(u.length - 1)
      r.push( u[k] + v[k])
    end
    r
  end

  def VA.isZero( u)
    r = true
    u.each { |e| r = r && (e == 0) }
    r
  end
end # module VA

# given two vectors u,v of dim 2, constructs perp
# guaranteed to be perpendicular to u
# fix the dependency on dim = 2
class Perp
  def initialize( u, v)
    @uu, @uv = VA.dot( u, u), VA.dot( u, v)
    @perp = [
      @uu*v[0] - @uv*u[0],
      @uu*v[1] - @uv*u[1]
    ]
  end

  # assert dot( @perp, u) == 0
  def getPerp
    @perp
  end

  # assert:  v == alpha*u + beta*perp
  # pre-condition:  isZero( u) == false
  def getAlpha
    @uv.to_f/@uu.to_f
  end

  def getBeta
    1.0/@uu.to_f
  end
end # class Perp

class Line
  def initialize( bp, ep)
    @beginPoint, @endPoint = bp, ep
    @delta = VA.add( ep, VA.mul(-1, bp))
  end
    def getBegin
      @beginPoint
    end

    def getEnd
      @endPoint
    end

    def getDelta
      @delta
    end

    # inline:  returns true if the point is IN the line segment (includes end points)
    # requires implementation
    def isinline( p)
      r = false
      r
    end

    # precondition:  !self.isZero  && !aLine.isZero
    # is this implementationcorrect?
    def isParallel( aLine)
      perp = Perp.new( self.getDelta, aLine.getDelta)
     VA.isZero perp.getPerp
    end

    # detect collapsed line: begin and end point are identical
    def isZero
      # (@delta[0] == 0) && (@delta[1] == 0)
      VA.isZero @delta
    end

    # returns beginPoint + t*delta
    def getPoint( t)
      VA.add( @beginPoint, VA.mul( t, @delta))
    end

    def to_s #over-ride
      "b:[#{@beginPoint[0]}, #{@beginPoint[1]}], e:[ #{@endPoint[0]}, #{@endPoint[1]}]"
    end
end # class Line

# find the intersection of the lines, not restricted to the line segments
class IntersectLines
  def initialize( l0, l1)
    @line0, @line1 = l0, l1
    # this is the perp of the delta's of the lines
    @perp = Perp.new( @line0.getDelta, @line1.getDelta)
    @displace = 0.0 # displacement of self.getPoint along @line1
  end

  def existsIntersection
    !VA.isZero(@perp.getPerp)
  end

  # precondition:  existsIntersection
  def getIntersection
    pp = VA.dot( @perp.getPerp , @perp.getPerp )
    deltaBegin = VA.add( @line0.getBegin, VA.mul( -1, @line1.getBegin))
    dbp = VA.dot(deltaBegin, @perp.getPerp)
    beta = @perp.getBeta
    @displace = dbp.to_f/(beta*pp)
    
    @line1.getPoint(@displace)
  end

  # pre-condition:  getIntersection already invoked
  def getdisplace
    @displace
  end
end # class Intersect

class IntersectUONItem
  def initialize( it) # UONItem item
    self.setItem(it)
  end # method initialize

  def setItem( it) # UONItem item
    if it != nil then
      @item = it
      # coordinates
      @x0, @y0 = @item.coords[0], @item.coords[1]
      @x1, @y1 = @item.coords[2], @item.coords[3]
      # lambda
      @lambda = 1.0
    end
  end # method initialize

  def getItem
    @item
  end

  def width
    @x1 - @x0
  end

  def height
    @y1 - @y0
  end

  def isleftright( p)
    c = @item.getCenter
    # 10jun09:  yikes! had minus sign! needed <= . done!
    width*(p[1] - c[1]).abs <= height*(p[0] - c[0]).abs
  end

  def isright( p)
    c = @item.getCenter
    isleftright(p)  && ((p[0] - c[0]) >= 0)
  end

  def isleft( p)
    c = @item.getCenter
    isleftright(p)  && ((p[0] - c[0]) < 0)
  end

  def isbottom( p)
    c = @item.getCenter
    !isleftright(p)  && ((p[1] - c[1]) >= 0)
  end

  def istop( p)
    c = @item.getCenter
    !isleftright(p)  && ((p[1] - c[1]) < 0)
  end

  # returns nil if no intersection, else the intersection point
  def getIntersection( p)
    self.setItem @item # updates state in case @item has moved
    ip = [0, 0] # the intersection point
    c = @item.getCenter

    if isright p then
      #puts "isright"
      ip[0] = self.width/2.0 + c[0]
      @lambda = (self.width/2.0)/(p[0] - c[0])
      ip[1] = @lambda*(p[1] - c[1]) + c[1]
    elsif isleft p then
      #puts "isleft"
      ip[0] = -self.width/2.0 + c[0]
      @lambda = -(self.width/2.0)/(p[0] - c[0])
      ip[1] = @lambda*(p[1] - c[1]) + c[1]
    elsif istop p then
      #puts "istop"
      ip[1] = (-height/2.0) + c[1]
      @lambda = -(self.height/2.0)/(p[1] - c[1])
      ip[0] = @lambda*(p[0] - c[0]) + c[0]
    elsif isbottom p then
      #puts "isbottom"
      ip[1] = (height/2.0) + c[1]
      @lambda = (self.height/2.0)/(p[1] - c[1])
      ip[0] = @lambda*(p[0] - c[0]) + c[0]
    end # if ... side of bounding box
    ip
  end # method getIntersection
end # class IntersectUONItem