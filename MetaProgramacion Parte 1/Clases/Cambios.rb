class Cambios
  attr_accessor :idObjeto, :variable, :valorAnterior, :valorNuevo

  def initialize(idDelObjeto, nombreVariable, unValorAnterior, unValorNuevo)
    @idObjeto     = idDelObjeto
    @variable     = nombreVariable
    @valorAnterior= unValorAnterior
    @valorNuevo   = unValorNuevo
  end

end