class CambiosObjeto

  attr_accessor :variable, :valorAnterior, :valorNuevo

  def initialize(nombreVariable, unValorAnterior, unValorNuevo)
    @variable     = nombreVariable
    @valorAnterior= unValorAnterior
    @valorNuevo   = unValorNuevo
  end

end