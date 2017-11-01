require_relative '../Clases/CambiosTransaccion'
require_relative '../Clases/Snapshot'
require_relative '../Clases/CambiosObjeto'
require_relative '../Clases/MutableDummyObject'

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
    @objetos  = variosObjetos
    #A cada objeto le pedira las variables y su estado actual para guardarlo
    @objetos.each  {|objeto|
      variablesDelObjeto = objeto.instance_variables.select{|var| !["@cambios","@cambiosTemporales","@lockeado"].include? var.to_s}
      #Se guarda los simbolos de las variables del objeto
      @variables.push(variablesDelObjeto)
      }
    @estadosUndo  = Snapshot.new @objetos, @variables
  end

  # recibe un bloque y ejecuta el bloque sobre los objetos guardados
  def realizarTransaccion(&blockDeAlgo)
    #Se trata hacer un catch de las excepciones
    begin
      beginTransaction
      (@objetos.size==1) ? (@objetos.first.instance_eval &blockDeAlgo) : (@objetos.instance_eval &blockDeAlgo)
    rescue StandardError, ObjectLockedError => excepcion
      unlock
      undo
      raise excepcion
    else
      commitTransaction
      registrarCambios
      unlock
    end
    self
  end

######Threads######
  #Crea un objeto "MutableDummyObject" por cada objeto de la transaccion y lo guarda en el Thread actual.
  def beginTransaction
    @objetos.each{ |objeto| Thread.current["#{objeto.object_id}".to_sym] = MutableDummyObject.new(objeto)}
  end

  #Importa los cambios realizados en los "MutableDummyObject" al objeto correspondiente
  def commitTransaction
    @objetos.each{ |objeto| Thread.current["#{objeto.object_id}".to_sym].commitearCambios}
  end

######Undo/Redo######
  #Le devuelve a todos los objetos su estado contenido en estadosUndo
  def undo
    aplicarEstadoYGuardarActual( "@estadosUndo", "@estadosRedo")
    self
  end

  #Le devuelve a todos los objetos su estado contenido en estadosRedo
  def redo
    if !@estadosRedo.nil?
      aplicarEstadoYGuardarActual( "@estadosRedo", "@estadosUndo")
    end
    self
  end

  #Aplica el estado de los objetos el cual se recibe atravez de "estadoAAplicar", el estado antes de esta modificacion se guarda en "estadoDeGuardado"
  def aplicarEstadoYGuardarActual( estadoAAplicar, estadoDeGuardado)
    #Guarda el snapshot del estado de los objetos en el estadoDeGuardado
    instance_variable_set(estadoDeGuardado, (Snapshot.new @objetos, @variables) )
    snapshotAAplicar = instance_variable_get(estadoAAplicar)
    x=0
    @objetos.each{|objeto|
                  asignarEstado objeto, snapshotAAplicar.variables[x], snapshotAAplicar.estados[x]
                  x+=1
                 }
    instance_variable_set(estadoAAplicar, nil )
  end

  #Aplica el valor a una variable de un objeto
  def asignarEstado( objeto, variables, estadosAAsignar)
    x=0
    variables.each{ |variable|
                    objeto.instance_variable_set(variable, estadosAAsignar[x])
                    x+=1}
  end

######Lock/Unlock######
  #Desbloquea a todos los objetos
  def unlock
    modificarLockeabilidadDeObjetos( "unlock")
  end

  #Bloquea a todos los objetos
  def lock
    modificarLockeabilidadDeObjetos( "lock")
  end

  #Modifica la bloqueabilidad de los objetos segun el simbolo del metodo pasado por parametro
  def modificarLockeabilidadDeObjetos(metodo)
   @objetos.each{  |objeto| objeto.send("#{metodo}".to_sym)}
  end

######Iteraccion sobre MutableDummyObject y lista de cambios######
  #Setea el estado de la variable del objeto (todos estos pasados por parametros) y guarda el cambio de estado en una lista de cambios temporal del objeto y en una lista de cambios temporal de la transaccion
  def guardarCambioDelObjeto(unObjeto, variable, valorViejo, valorNuevo)
    guardarCambioEnSuObjetoMutado unObjeto, variable, valorNuevo
    unObjeto.guadarCambioTemporal CambiosObjeto.new(variable, valorViejo, valorNuevo)
    @listaDeCambiosTemporales << CambiosTransaccion.new(unObjeto.object_id, variable, valorViejo, valorNuevo)
  end

  #Retorna el valor de la variable que posee el objeto "MutableDummyObject" correspondiente al objeto pasado como parametro
  def obtenerValorDelObjeto(unObjeto, variable)
    Thread.current["#{unObjeto.object_id}".to_sym].gettear variable
  end

  #Retorna el valor de la variable que posee el objeto "MutableDummyObject" correspondiente al objeto pasado como parametro
  def guardarCambioEnSuObjetoMutado(unObjeto, variable, valorNuevo)
    Thread.current["#{unObjeto.object_id}".to_sym].settear variable, valorNuevo
  end

  #Pasa los cambios de las listas de cambios temporales a las permanentes
  def registrarCambios
    @listaDeCambios.concat @listaDeCambiosTemporales
    @objetos.each{|objeto| objeto.registrarCambiosComoDefinitivos}
  end

######Getters && Setters######
  def changes
    @listaDeCambios
  end

end