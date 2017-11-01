class Snapshot

  attr_accessor :objetos, :variables, :estados

  def initialize(unObjeto, unasVariables)
    @objetos        = unObjeto
    @variables      = unasVariables
    @estados        = []
    self.cargarEstado
  end

  #Guarda los objetos, sus variables y su estado actual
  def cargarEstado
  x=0
  #A cada objeto le pedira las variables y su estado actual para guardarlo
  @objetos.each {|objeto|
                  @estados.push(obtenerEstadoActual( objeto, @variables[x]) )
                  x+=1
                }
    self
  end

  #Retorna un array con los valores de estado del objeto actual
  def obtenerEstadoActual(unObjeto, variables)
    variables.collect{  |variable| unObjeto.instance_variable_get(variable) }
  end

end