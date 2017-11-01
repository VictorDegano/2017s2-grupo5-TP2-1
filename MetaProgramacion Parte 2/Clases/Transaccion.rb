require_relative '../Clases/CambiosTransaccion'
require_relative '../Clases/Snapshot'
require_relative '../Clases/CambiosObjeto'

class Transaccion

  attr_accessor :objetos, :variables, :estadosUndo, :estadosRedo, :listaDeCambios, :listaDeCambiosTemporales

  def initialize(unObjeto)
    @objetos                  = []
    @variables                = []
    @estadosUndo              = nil
    @estadosRedo              = nil
    @listaDeCambios           = []
    @listaDeCambiosTemporales = []
    cargarObjetos unObjeto
    self
  end


  #Guarda los objetos, sus variables y su estado actual para el inicio de la transaccion
  def cargarObjetos (variosObjetos)
    if variosObjetos.size == 1
      @objetos  = variosObjetos.first
      @variables= @objetos.instance_variables.select{|var| var.to_s!="@cambios" || var.to_s!="@cambiosTemporales"}
    else
      @objetos  = variosObjetos
      #A cada objeto le pedira las variables y su estado actual para guardarlo
      @objetos.each  {|objeto|
        variablesDelObjeto = objeto.instance_variables.select{|var| var.to_s!="@cambios" || var.to_s!="@cambiosTemporales"}
        #Se guarda los simbolos de las variables del objeto
        @variables.push(variablesDelObjeto)
        }
    end
    @estadosUndo  = Snapshot.new @objetos, @variables
  end


  def realizarTransaccion(&blockDeAlgo)
    #Se trata hacer un catch de la excepcion
    begin
      @objetos.instance_eval &blockDeAlgo
      registrarCambios
    rescue => excepcion #Si hay excepcion se guarda la excepcion
      undo
      raise excepcion
    end
    self
  end


  #le devuelve a todos los objetos su estado contenido en estadosUndo
  def undo
    aplicarEstadoYGuardarActual "@estadosUndo", "@estadosRedo"
    self
  end


  #le devuelve a todos los objetos su estado contenido en estadosRedo
  def redo
    if !@estadosRedo.nil?
      aplicarEstadoYGuardarActual "@estadosRedo", "@estadosUndo"
    end
    self
  end


  def aplicarEstadoYGuardarActual( estadoAAplicar, estadoDeGuardado)
    instance_variable_set(estadoDeGuardado, (Snapshot.new @objetos, @variables) )
    snapshotAAplicar = instance_variable_get(estadoAAplicar)
    if @objetos.class != Array
      asignarEstado @objetos, snapshotAAplicar.variables, snapshotAAplicar.estados
    else
      x=0
      @objetos.each{|objeto|
        asignarEstado objeto, snapshotAAplicar.variables[x], snapshotAAplicar.estados[x]
        x+=1 }
    end
    instance_variable_set(estadoAAplicar, nil )
  end


  def asignarEstado( objeto, variables, estadosAAsignar)
    x=0
    variables.each{ |variable|
                    objeto.instance_variable_set(variable, estadosAAsignar[x])
                    x+=1}
  end


  def guardarCambioDelObjeto unObjeto, variable, valorViejo, valorNuevo
    unObjeto.guadarCambioTemporal CambiosObjeto.new(variable, valorViejo, valorNuevo)
    @listaDeCambiosTemporales << CambiosTransaccion.new(unObjeto.object_id, variable, valorViejo, valorNuevo)
  end


  def changes
    @listaDeCambios
  end


  def registrarCambios
    @listaDeCambios.concat @listaDeCambiosTemporales
    @objetos.class == Array ?
                              @objetos.each{|objeto| objeto.registrarCambiosComoDefinitivos}
                            :
                              @objetos.registrarCambiosComoDefinitivos

  end
end