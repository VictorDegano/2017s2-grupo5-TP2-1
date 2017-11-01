require_relative '../Clases/Cambios'
require_relative '../Clases/Snapshot'

class Transaccion

  attr_accessor :objetos, :variables, :estadosUndo, :estadosRedo, :listaDeCambios

  def initialize(*unObjeto)
    @objetos        = []
    @variables      = []
    @estadosUndo    = nil
    @estadosRedo    = nil
    @listaDeCambios = []
    cargarObjetos unObjeto
    self
  end


  #Guarda los objetos, sus variables y su estado actual para el inicio de la transaccion
  def cargarObjetos (variosObjetos)
    if variosObjetos.size == 1
      @objetos  = variosObjetos.first
      @variables= @objetos.instance_variables
    else
      @objetos  = variosObjetos
      #A cada objeto le pedira las variables y su estado actual para guardarlo
      @objetos.each  {|objeto|
        variablesDelObjeto = objeto.instance_variables
        #Se guarda los simbolos de las variables del objeto
        @variables.push(variablesDelObjeto)
        }
    end
    @estadosUndo  = Snapshot.new @objetos
    #guardarEstados "estadosUndo"
  end


  def realizarTransaccion(&blockDeAlgo)
    #Se trata hacer un catch de la excepcion
    begin
      @objetos.instance_eval &blockDeAlgo
      registrarCambios "@estadosUndo"
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
    instance_variable_set(estadoDeGuardado, (Snapshot.new @objetos) )
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


  def registrarCambios( estadoAnterior)
    if @objetos.class != Array
      tomarSnapshotsYGuardar @objetos, @variables, instance_variable_get(estadoAnterior).estados
    else
      x=0
      @objetos.each{|objeto|
                    tomarSnapshotsYGuardar objeto, @variables[x], instance_variable_get(estadoAnterior).estados[x]
                    x+=1}
    end
  end

  def tomarSnapshotsYGuardar( objeto, variables, estadoViejo)
    x=0
    variables.each{|variable|
                    estadoActual    = objeto.instance_variable_get variable
                    estadoAnterior  = estadoViejo[x]
                    x+=1
                    if estadoActual != estadoAnterior
                      @listaDeCambios << Cambios.new(objeto.object_id,variable,estadoAnterior,estadoActual)
                    end
                  }
  end


  def changes
    @listaDeCambios
  end
end