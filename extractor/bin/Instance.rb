#!/usr/bin/env ruby
#
class Instance
  def initialize(txt,stem,pos,tf_idf,fo,tf_sub,len,kp_freq,prob)
    @txt = txt
    @stem = stem
    @pos  = pos
    @tf_idf = tf_idf
    @fo = fo
    @tf_sub = tf_sub
    @len = len
    @kp_freq = kp_freq
    @prob = prob
  end
  def txt
    @txt
  end
  def txt=(txt)
    @txt = txt
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
    @content = pos
  end

  def tf_idf
    @tf_idf
  end
  def tf_idf=(tf_idf)
    @tf_idf= tf_idf
  end

  def fo
    @fo
  end

  def fo=(fo)
    @fo = fo
  end

  def tf_sub
    @tf_sub
  end

  def tf_sub=(tf_sub)
    @tf_sub=tf_sub
  end
  def len
    @len
  end
  def len=(len)
    @len=len
  end
  def kp_freq
    @kp_freq
  end
  def kp_freq=(kp_freq)
    @kp_freq=kp_freq
  end
  def prob
    @prob
  end
  def prob=(prob)
    @prob=prob
  end
end
