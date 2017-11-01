require_relative '../Clases/Transaccion'

class Transactor

  attr_accessor :objetos, :transaccionActual
  @objetos          = []
  @transaccionActual= nil

  def self.cargarObjetoTransaccional(unObjeto)
    @objetos<<unObjeto
  end

  def self.perform( &blockDeAlgo)
    var = Transaccion.new( @objetos)
    Thread.current[:transaccionActual] = var
    begin
      Thread.current[:transaccionActual]
            .realizarTransaccion &blockDeAlgo
    ensure
      Thread.current[:transaccionActual]= nil
    end
    var
  end

  def self.limpiarObjetosTransaccionales
    @objetos.clear
  end

end