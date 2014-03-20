class Product < ActiveRecord::Base
  @@units = %w(piece ml cl dl litre)
  @@groups = %w(beer long_drink cider shot other)
  cattr_reader :units, :groups

  validates :name, presence: true, uniqueness: true
  validates :price, numericality: {only_integer: false}, inclusion: {in: 0..99}
  validates :stock, numericality: {only_integer: true}, inclusion: {in: 0..9999}
  validates :group, inclusion: {in: groups}
  validates :unit, inclusion: {in: @@units}

  def buy(amount)
    self.stock -= amount
    self.save
  end

  #Placeholder methods for now, to be replaced with a real column
  def available; stock > 0; end
  def available=(avl); self.stock = (avl ? 1 : 0); end
end
