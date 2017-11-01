require_relative '../Clases/Modelo/ObjectLockedError'

module Lockeable


  def volverLockeable
    setterLockeado
    getterLockeado
    definirSettersLockeables
    definirLockMethod
    definirUnlockMethod
  end


  def setterLockeado
    define_method "lockeado=".to_sym  do  |parametro|
                                          self.instance_variable_set("@lockeado".to_sym, parametro)
                                      end
  end


  def getterLockeado
    define_method "lockeado".to_sym do
                                      self.instance_variable_get("@lockeado".to_sym)
                                    end
  end

  def definirSettersLockeables
    variables = self.instance_variables.select{|var| (var.to_s!="@cambios") && (var.to_s!="@cambiosTemporales") && (var.to_s!="@lockeado")}
    variables.each{ |variable| crearSetterLockeable "#{variable}".delete("@") }
  end

  def crearSetterLockeable variableACrear

    alias_method "#{variableACrear}Lockeable=".to_sym, "#{variableACrear}=".to_sym

    define_method "#{variableACrear}=".to_sym do  |parametro|
        if self.instance_variable_get("@lockeado".to_sym)==true
          ObjectLockedError.lanzar "Objeto Lockeado: No se pudo modificar la variable #{variableACrear} del objeto #{self}"
        else
          self.send("#{variableACrear}Lockeable=".to_sym, parametro)
        end
      end

  end


  def definirLockMethod
    define_method :lock do
      if !self.instance_variable_get("@lockeado".to_sym) && !self.send(:currentTransaction).nil?
        self.instance_variable_set("@lockeado".to_sym, true)
      end
    end
  end


  def definirUnlockMethod
    define_method :unlock do
      if self.instance_variable_get("@lockeado".to_sym) && !self.send(:currentTransaction).nil?
        self.instance_variable_set("@lockeado".to_sym, false)
      end
    end
  end

end