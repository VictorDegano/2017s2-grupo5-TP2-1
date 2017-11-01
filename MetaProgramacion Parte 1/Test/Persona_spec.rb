require 'rspec'
require_relative '../Clases/Modelo/Persona'
require_relative '../Clases/Object.rb'
require_relative '../Clases/Cambios'
require_relative '../Clases/Transactor'

describe 'Transaccion Exitosa' do

  it 'Se le dice que cumpla años, cumple años' do
    p = Persona.new
    p.edad = 22

    queCumpla(p)

    expect(p.edad).to eq(23)
  end

  it 'Se le dice a dos personas que cumplan años, cumplen años' do
    p = Persona.new
    p.edad =22
    s = Persona.new
    s.edad =20

    queCumplan(p, s)

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

    queCumplan(p, s, a)

    expect(p.edad).to eq(23)
    expect(s.edad).to eq(21)
    expect(a.edad).to eq(19)
  end

end

describe 'Roolback Automatico ante un error' do

  it 'Se le dice que cumpla años, cumple años, explota y no suma años' do
    p = Persona.new
    p.edad =22

    expect { queExploteAlCumplirAnios(p)}.to raise_error('Kabooom!')

    expect(p.edad).to eq(22)
  end

  it 'Se le dice a 2 personas que cumpla años y exploten, no suman años' do
    p = Persona.new
    p.edad =22
    a = Persona.new
    a.edad = 19

    expect { queExplotenAlCumplirAnios(p , a)}.to raise_error('Kabooom!')

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

    expect { queExplotenAlCumplirAnios(p, s)}.to raise_error('Kabooom!')

    expect(p.edad).to eq(22)
    expect(s.edad).to eq(23)
    expect(a.edad).to eq(19)
  end

end

describe 'Rollback Manual' do

  it 'Se le dice que cumpla años y luego quiere revertirse, se puede revertir y tambien volver a hacer' do
    p = Persona.new
    p.edad =22
    transaccion = Transactor.perform(p) { p.cumplirAnios }

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

    transaccion = Transactor.perform(p) { p.cumplirAnios }
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

    transaccion = Transactor.perform(p, s ) { s.cumplirAnios
                                                    p.cumplirAnios }
    expect(p.edad).to eq(23)
    expect(s.edad).to eq(24)

    cambios = transaccion.changes()
    expect(cambios.size).to eq(2)

    idObjetoS = s.object_id
    expect(cambios[1].idObjeto).to eq(idObjetoS)
    expect(cambios[1].variable.to_s).to eq("@edad")
    expect(cambios[1].valorAnterior).to eq(23)
    expect(cambios[1].valorNuevo).to eq(24)

    idObjetoP = p.object_id
    expect(cambios[0].idObjeto).to eq(idObjetoP)
    expect(cambios[0].variable.to_s).to eq("@edad")
    expect(cambios[0].valorAnterior).to eq(22)
    expect(cambios[0].valorNuevo).to eq(23)
  end
end