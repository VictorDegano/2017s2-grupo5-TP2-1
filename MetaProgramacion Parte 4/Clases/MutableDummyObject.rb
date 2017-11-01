
class MutableDummyObject

attr_accessor :objeto, :hashVariablesEstados

  def initialize (objetoAGuardar)
    @objeto = objetoAGuardar
    @hashVariablesEstados = Hash.new
    # Se guarda todas las variables y sus valores en el hash
    objetoAGuardar.instance_variables.each{ |variable|
                                            @hashVariablesEstados.store(  variable,
                                                                          objetoAGuardar.instance_variable_get(variable))
                                          }
    self
  end

  # Copia los cambios realizados/guardados en la instancia de MutableDummyObject al objeto
  def commitearCambios
    @hashVariablesEstados.each{ |clave, valor|
                                @objeto.instance_variable_set(clave,valor)
                              } #Recorre el map seteando el valor guardado a la variable del objeto
    Thread.current["#{self.object_id}".to_sym] = nil #Setea la variable del Thread correspondiente al MDO en nil
    self
  end

  #Getters && Setters
  def idDelObjeto()
    @objeto.object_id
  end

  def settear( variable, valorNuevo)
    @hashVariablesEstados[variable] = valorNuevo
    self
  end

  def gettear(variable)
    @hashVariablesEstados[variable]
  end

end