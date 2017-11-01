require 'rspec'
require_relative '../Clases/Modelo/Persona'
require_relative '../Clases/Object.rb'
require_relative '../Clases/CambiosTransaccion'
require_relative '../Clases/Transactor'
require_relative '../Clases/Modelo/ObjectLockedError'

describe 'Test TP MetaProgramacion' do
  after(:example) do Transactor.limpiarObjetosTransaccionales end

  describe 'Transaccion Exitosa' do

    it 'Se le dice que cumpla años, cumple años' do
      p = Persona.new
      p.edad = 22
      queCumpla

      expect(p.edad).to eq(23)
    end

    it 'Se le dice a dos personas que cumplan años, cumplen años' do
      p = Persona.new
      p.edad =22
      s = Persona.new
      s.edad =20

      queCumplan

      expect(p.edad).to eq(23)
      expect(s.edad).to eq(21)
    end

    it 'Se tienen a 3 personas y se le dice a dos personas que cumplan años, solo dos cumplen años' do
      p = Persona.new
      p.edad =22
      s = Persona.new
      s.edad =20
      a = Persona.new
      a.edad =19

      queCumplan

      expect(p.edad).to eq(23)
      expect(s.edad).to eq(21)
      expect(a.edad).to eq(19)
    end

  end

  describe 'Roolback Automatico ante un error' do

    it 'Se le dice que cumpla años, cumple años, explota y no suma años' do
      p = Persona.new
      p.edad =22

      expect { queExploteAlCumplirAnios}.to raise_error('Kabooom!')

      expect(p.edad).to eq(22)
    end

    it 'Se le dice a 2 personas que cumpla años y exploten, no suman años' do
      p = Persona.new
      p.edad =22
      a = Persona.new
      a.edad = 19

      expect { queExplotenAlCumplirAnios}.to raise_error('Kabooom!')

      expect(p.edad).to eq(22)
      expect(a.edad).to eq(19)
    end

    it 'Se le dice a 2 personas que cumpla años y exploten, no suman años' do
      p = Persona.new
      p.edad =22
      s = Persona.new
      s.edad = 23
      a = Persona.new
      a.edad = 19

      expect { queExplotenAlCumplirAnios}.to raise_error('Kabooom!')

      expect(p.edad).to eq(22)
      expect(s.edad).to eq(23)
      expect(a.edad).to eq(19)
    end

  end

  describe 'Rollback Manual' do

    it 'Se le dice que cumpla años y luego quiere revertirse, se puede revertir y tambien volver a hacer' do
      p = Persona.new
      p.edad =22
      transaccion = Transactor.perform { p.cumplirAnios }

      expect(p.edad).to eq(23)

      transaccion.undo
      expect(p.edad).to eq(22)

      transaccion.redo
      expect(p.edad).to eq(23)
    end
  end

  describe 'Registrar Cambios' do

    it 'Al realizar una transaccion se registran los cambios sobre el objeto' do
      p = Persona.new
      p.edad =22

      transaccion = Transactor.perform { p.cumplirAnios }
      expect(p.edad).to eq(23)

      cambios = transaccion.changes()
      expect(cambios.size).to eq(1)

      idObjeto = p.object_id
      expect(cambios[0].idObjeto).to eq(idObjeto)
      expect(cambios[0].variable.to_s).to eq("@edad")
      expect(cambios[0].valorAnterior).to eq(22)
      expect(cambios[0].valorNuevo).to eq(23)
    end

    it 'Al realizar una transaccion sobre varios objetos se registran los cambios sobres los  objetos' do
      p = Persona.new
      p.edad =22
      s = Persona.new
      s.edad = 23

      transaccion = Transactor.perform {  p.cumplirAnios
                                          s.cumplirAnios
                                          }
      expect(p.edad).to eq(23)
      expect(s.edad).to eq(24)

      cambios = transaccion.changes()
      expect(cambios.size).to eq(2)

      idObjetoP = p.object_id
      expect(cambios[0].idObjeto).to eq(idObjetoP)
      expect(cambios[0].variable.to_s).to eq("@edad")
      expect(cambios[0].valorAnterior).to eq(22)
      expect(cambios[0].valorNuevo).to eq(23)

      idObjetoS = s.object_id
      expect(cambios[1].idObjeto).to eq(idObjetoS)
      expect(cambios[1].variable.to_s).to eq("@edad")
      expect(cambios[1].valorAnterior).to eq(23)
      expect(cambios[1].valorNuevo).to eq(24)
    end
  end

  describe 'Conocen sus cambios' do
    it 'Al realizar una transaccion se le puede preguntar al objeto sus cambios' do
      p       = Persona.new
      p.edad  = 22
      cambios1= []
      cambios2= []

      transaccion = Transactor.perform {  p.cumplirAnios
                                          cambios1.concat p.changes
                                          p.cumplirAnios
                                          cambios2.concat p.changes}

      expect(p.edad).to eq(24)
      expect(cambios1.size).to eq(1)
      expect(cambios2.size).to eq(2)
      expect(transaccion.changes.size).to eq(2)
    end
  end

  describe 'Se puede obtener la transaccion actual' do
    it 'Al realizar una transaccion se le puede preguntar al objeto su transaccion actual' do
      p1       = Persona.new
      p1.edad  = 22

      p2       = Persona.new
      p2.edad  = 10
      spyTransaction        = nil
      transactionChangesSpy = []

      Transactor.perform {
                            transaction = p1.currentTransaction
                            p1.cumplirAnios
                            p2.cumplirAnios

                            transactionChangesSpy = transaction.changes
                            spyTransaction = transaction
                          }

      expect(spyTransaction.class).to eq(Transaccion)
      expect(transactionChangesSpy.size).to eq(2)
      spyTransaction = p1.currentTransaction
      expect(spyTransaction.nil?).to eq(true)
    end
  end

  describe 'Se puede lockear/deslockear los objetos' do
    it 'Si se lockea el objeto actual, no se puede modificar' do
      p     = Persona.new
      p.edad= 10

      begin
        Transactor.perform{ p.lock
                            p.cumplirAnios
                          }
      rescue => error
        expect(error.class).to eq(ObjectLockedError)
      end

      expect(p.edad).to eq(10)
      expect(p.lockeado).to eq(false)

      p.cumplirAnios
      expect(p.edad).to eq(11)

      p.lock
      expect(p.lockeado).to eq(false)
      p.unlock
      expect(p.lockeado).to eq(false)
    end

    it 'Si se lockea todos los objetos, no se pueden modificar' do
      p = Persona.new
      p.edad = 10
      s = Persona.new
      s.edad = 35

      begin
        Transactor.perform{
                            p.currentTransaction.lock
                            s.cumplirAnios
                            p.cumplirAnios
                          }
      rescue => error
        expect(error.class).to eq(ObjectLockedError)
      end

      expect(p.edad).to eq(10)
      expect(p.lockeado).to eq(false)
      expect(s.edad).to eq(35)
      expect(s.lockeado).to eq(false)

      p.cumplirAnios
      s.cumplirAnios
      expect(p.edad).to eq(11)
      expect(s.edad).to eq(36)
    end

    it 'Si se lockea el objeto actual, y se lo deslockea durante la transaccion se puede modificar' do
      p     = Persona.new
      p.edad= 10

      Transactor.perform{
                          p.lock
                          begin
                            p.cumplirAnios
                          rescue
                            p.unlock
                            retry
                          end
                        }

      expect(p.edad).to eq(11)
      expect(p.lockeado).to eq(false)

      p.unlock
      expect(p.lockeado).to eq(false)
      p.lock
      expect(p.lockeado).to eq(false)
    end

    it 'Si se lockea la transaccion actual y luego se la deslockea, los objetos se pueden modificar' do
      p = Persona.new
      p.edad = 10
      s = Persona.new
      s.edad = 35

      Transactor.perform{
                          p.currentTransaction.lock
                          begin
                            s.cumplirAnios
                            p.cumplirAnios
                          rescue
                            p.currentTransaction.unlock
                            retry
                          end
                        }

      expect(p.edad).to eq(11)
      expect(p.lockeado).to eq(false)
      expect(s.edad).to eq(36)
      expect(s.lockeado).to eq(false)
    end

  end

end