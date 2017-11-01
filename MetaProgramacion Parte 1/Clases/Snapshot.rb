
class Snapshot

  attr_accessor :objetos, :variables, :estados

  def initialize unObjeto
    @objetos        = unObjeto
    @variables      = []
    @estados        = []
    self.cargarEstado
  end

  #Guarda los objetos, sus variables y su estado actual
  def cargarEstado
    if @objetos.class != Array
      @variables= @objetos.instance_variables
      @estados  = obtenerEstadoActual(@objetos, @variables)
    else
      #A cada objeto le pedira las variables y su estado actual para guardarlo
      @objetos.each  {|objeto|
                      variablesDelObjeto = objeto.instance_variables
                      #Se guarda los simbolos de las variables del objeto
                      @variables.push(variablesDelObjeto)
                      #Se guarda el estado del objeto
                      @estados.push(obtenerEstadoActual( objeto, variablesDelObjeto))
                    }
    end
  end

  #Retorna un array con los valores de estado del objeto actual
  def obtenerEstadoActual unObjeto, variables
    variables.collect{ |variable| unObjeto.instance_variable_get(variable)}
  end

end