
class ObjectLockedError < StandardError

  def self.lanzar(mensajeOpcional="Objeto Bloqueado: No se puede modificar al objeto")
    raise ObjectLockedError.new(mensajeOpcional)
  end

end