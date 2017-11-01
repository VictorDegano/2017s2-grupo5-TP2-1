require_relative '../Transactional'

class Persona

  attr_accessor :nombre, :edad
  @nombre = ""
  @edad   = 0

  include Transactional

  def cumplirAnios
    self.edad = self.edad + 1
  end

end