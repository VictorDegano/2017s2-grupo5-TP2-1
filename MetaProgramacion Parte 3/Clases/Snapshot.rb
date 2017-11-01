
class Snapshot

  attr_accessor :objetos, :variables, :estados

  def initialize unObjeto, unasvariables
    @objetos        = unObjeto
    @variables      = unasvariables
    @estados        = []
    self.cargarEstado
  end

  #Guarda los objetos, sus variables y su estado actual
  def cargarEstado
  x=0
  #A cada objeto le pedira las variables y su estado actual para guardarlo
  @objetos.each {|objeto|
                  #Se guarda el estado del objeto
                  @estados.push(obtenerEstadoActual( objeto, @variables[x]))
                  x+=1
                }
  end

  #Retorna un array con los valores de estado del objeto actual
  def obtenerEstadoActual unObjeto, variables
    variables.collect{ |variable| unObjeto.instance_variable_get(variable)}
  end

end