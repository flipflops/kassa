class ProductSerializer < ActiveModel::Serializer
  root :object
  attributes :id, :name, :description, :unit, :group, :created_at, :updated_at
  has_many :materials
end