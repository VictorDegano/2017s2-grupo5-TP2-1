require_relative '../Clases/CambiosObjeto'

class CambiosTransaccion < CambiosObjeto
  attr_accessor :idObjeto

  def initialize(idDelObjeto, nombreVariable, unValorAnterior, unValorNuevo)
    super nombreVariable, unValorAnterior, unValorNuevo
    @idObjeto     = idDelObjeto
  end

end