require_relative '../Clases/Transactor'
require_relative '../Clases/Lockeable'

module Transactional

  def self.included(claseBase)
    claseBase.extend(Transaccionable)
    claseBase.extend(RepositorioDeCambios)
    claseBase.extend(Lockeable)
    claseBase.send(:define_method, :initialize) {
                                                  Transactor.send(:cargarObjetoTransaccional, self)
                                                  instance_variable_set("@cambios".to_sym, Array.new)
                                                  instance_variable_set("@cambiosTemporales".to_sym, Array.new)
                                                  instance_variable_set("@lockeado", false)
                                                }
    claseBase.crearSettersTransaccionales
    claseBase.iniciarRegistroDeCambios
    claseBase.volverLockeable
  end

  module RepositorioDeCambios

    def iniciarRegistroDeCambios
      crearSetter"cambios"
      crearGetter"cambios"
      crearSetter"cambiosTemporales"
      crearGetter"cambiosTemporales"
      definirGuardarCambio
      definirGuardarCambioTemporal
      definirRegistroDeCambiosDefinitivos
      definirChanges
      definirCurrentTransaction
    end

    def crearSetter(nombre)
      define_method "#{nombre}=".to_sym do  |parametro|
                                            self.instance_variable_set("@#{nombre}".to_sym, parametro)
                                        end
    end

    def crearGetter(nombre)
      define_method "#{nombre}".to_sym do
                                          self.instance_variable_get("@#{nombre}".to_sym)
                                       end
    end

    def definirGuardarCambioTemporal
      define_method "guadarCambioTemporal".to_sym do  |unCambio|
                                                      self.instance_variable_get("@cambiosTemporales".to_sym) << unCambio
                                                  end
    end

    def definirGuardarCambio
      define_method "guadarCambio".to_sym do  |unCambio|
                                              self.instance_variable_get("@cambios".to_sym) << unCambio
                                          end
    end

    def definirChanges
      define_method (:changes) {
                                  if self.instance_variable_get("@cambiosTemporales".to_sym).empty?
                                    self.instance_variable_get("@cambios".to_sym)
                                  else
                                    self.instance_variable_get("@cambiosTemporales".to_sym)
                                  end
                                }
    end

    def definirRegistroDeCambiosDefinitivos
      define_method :registrarCambiosComoDefinitivos  do
                                self.instance_variable_get("@cambios".to_sym).concat(self.instance_variable_get("@cambiosTemporales".to_sym))
                                self.instance_variable_set("@cambiosTemporales".to_sym, Array.new)
                              end
    end

  end


  module Transaccionable

    def crearSettersTransaccionales
      variables = self.instance_variables
      variables.each{ |variable|
                      crearSetterTransaccional "#{variable}".delete("@")
                      crearGetterTransaccional "#{variable}".delete("@")
                    }
    end

    def crearSetterTransaccional(variableACrear)
      define_method "#{variableACrear}=".to_sym do  |parametro|
                              begin
                                valorViejo = Thread .current[:transaccionActual]
                                                    .obtenerValorDelObjeto self, "@#{variableACrear}".to_sym
                                Thread.current[:transaccionActual]
                                      .guardarCambioDelObjeto self, "@#{variableACrear}".to_sym, valorViejo, parametro
                              rescue
                                self.instance_variable_set("@#{variableACrear}".to_sym, parametro)
                              end
                            end
    end

    def crearGetterTransaccional(variableACrear)
      define_method "#{variableACrear}".to_sym do
                                        begin
                                          Thread.current[:transaccionActual]
                                                .obtenerValorDelObjeto self, "@#{variableACrear}".to_sym
                                        rescue
                                          self.instance_variable_get("@#{variableACrear}".to_sym)
                                        end
                                    end
    end

    def definirCurrentTransaction
      define_method :currentTransaction do
                                            Thread.current[:transaccionActual]
                                        end
    end

  end

end