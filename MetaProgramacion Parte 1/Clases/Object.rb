require_relative '../Clases/Transactor'

class Object

  def queCumpla(p)
    Transactor.perform(p){ |p| p.cumplirAnios }
  end

  def queExploteAlCumplirAnios(p)
    Transactor.perform(p) { |p| p.cumplirAnios
                                        raise 'Kabooom!'
                                  }
  end

  def queCumplan(*varios)
    Transactor.perform( *varios ){ |p, s|
                                    p.cumplirAnios
                                    s.cumplirAnios}
  end

  def queExplotenAlCumplirAnios(*varios )
    Transactor.perform(*varios ) { |p,a|
                                  p.cumplirAnios
                                  a.cumplirAnios
                                  raise 'Kabooom!'
                                 }
  end

end