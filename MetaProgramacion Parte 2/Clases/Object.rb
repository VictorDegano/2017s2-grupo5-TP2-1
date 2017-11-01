require_relative '../Clases/Transactor'

class Object

  def queCumpla()
    Transactor.perform(){ |p| p.cumplirAnios }
  end

  def queExploteAlCumplirAnios()
    Transactor.perform() { |p| p.cumplirAnios
                                        raise 'Kabooom!'
                                  }
  end

  def queCumplan()
    Transactor.perform(){ |p, s|
                                    p.cumplirAnios
                                    s.cumplirAnios}
  end

  def queExplotenAlCumplirAnios()
    Transactor.perform() { |p,a|
                                  p.cumplirAnios
                                  a.cumplirAnios
                                  raise 'Kabooom!'
                                 }
  end

end