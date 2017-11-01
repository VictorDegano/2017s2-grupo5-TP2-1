require_relative '../Clases/Transaccion'

class Transactor

  attr_accessor :objetos, :transaccionActual
  @objetos          = []
  @transaccionActual= nil

  def self.cargarObjetoTransaccional unObjeto
    @objetos<<unObjeto
  end

  def self.perform &blockDeAlgo
    var = Transaccion.new( @objetos)
    @transaccionActual= var
    @transaccionActual.realizarTransaccion &blockDeAlgo
    @transaccionActual= nil
    var
  end

  def self.limpiarObjetosTransaccionales
    @objetos.clear
  end

  def self.transaccionActual
    @transaccionActual
  end

end