require_relative '../Clases/Modelo/ObjectLockedError'

module Lockeable

  def volverLockeable
    setterLockeado
    getterLockeado
    definirSettersLockeables
    definirLockMethod
    definirUnlockMethod
  end

  #define el Setter para la variable "Lockeado"
  def setterLockeado
    define_method "lockeado=".to_sym  do  |parametro|
                                          self.instance_variable_set("@lockeado".to_sym, parametro)
                                      end
  end

  #define el Getter para la variable "Lockeado"
  def getterLockeado
    define_method "lockeado".to_sym do
                                      self.instance_variable_get("@lockeado".to_sym)
                                    end
  end

  #Redefine los setters del objeto para soportar sel ser un objeto Lockeable
  def definirSettersLockeables
    # Selecciona las variables del objeto que no son "cambios", "cambiosTemporales" ni "lockeado"
    variables = self.instance_variables.select{ |var| !["@cambios","@cambiosTemporales","@lockeado"].include? var.to_s  }
    variables.each{ |variable| crearSetterLockeable "#{variable}".delete("@") }
  end

  # Toma la variable del objeto y crea un nuevo setter para que soporte ser Lockeable
  def crearSetterLockeable(variableACrear)
    # Se define una alias para el viejo metodo setter
    alias_method "#{variableACrear}Lockeable=".to_sym, "#{variableACrear}=".to_sym

    # Se define el nuevo set, el cual chequea que el objeto no este bloqueado antes de intentar modificar la variable
    define_method "#{variableACrear}=".to_sym do  |parametro|
                                  if self.instance_variable_get("@lockeado".to_sym)
                                    ObjectLockedError.lanzar "Objeto Lockeado: No se pudo modificar la variable #{variableACrear} del objeto #{self}"
                                  else
                                    self.send("#{variableACrear}Lockeable=".to_sym, parametro)
                                  end
                              end
  end

  # Define el motodo LockMethod para poner al objeto en estado "Lockeado"
  def definirLockMethod
    define_method :lock do
      #Marca al objeto como Lockeado si no se encuentra lockeado y hay una transaccion actual
      if !self.instance_variable_get("@lockeado".to_sym) && !self.send(:currentTransaction).nil?
        self.instance_variable_set("@lockeado".to_sym, true)
      end
    end
  end

  # Define el motodo UnlockMethod para poner al objeto en estado "deslockeado"
  def definirUnlockMethod
    define_method :unlock do
      #Marca al objeto como deslockeado si se encuentra lockeado y hay una transaccion actual
      if self.instance_variable_get("@lockeado".to_sym) && !self.send(:currentTransaction).nil?
        self.instance_variable_set("@lockeado".to_sym, false)
      end
    end
  end

end