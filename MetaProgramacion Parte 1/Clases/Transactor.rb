require_relative '../Clases/Transaccion'

class Transactor

  def self.perform *algo, &blockDeAlgo
    Transaccion.new( *algo ).realizarTransaccion &blockDeAlgo
  end

end