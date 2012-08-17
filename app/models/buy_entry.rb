class BuyEntry < ActiveRecord::Base
  belongs_to :buy
  belongs_to :product
  attr_accessible :amount

  validates_presence_of :buy_id, :product_id
  validates :amount, presence: true, numericality: {greater_than_or_equal_to: 1}
  validate :can_be_bought?

  def can_be_bought?
    product.stock > amount if product.present?
    false
  end
end
