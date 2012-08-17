class NP
  def initialize(stem,pos,txt)
    @stem = stem
    @pos  = pos
    @txt  = txt
  end
  def stem
    @stem
  end
  def stem=(stem)
    @stem = stem
  end

  def pos
    @pos
  end
  def pos=(pos)
    @pos = pos
  end

  def txt
    @txt
  end
  def txt=(txt)
    @txt=txt
  end
end
