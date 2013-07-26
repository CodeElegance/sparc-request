class Procedure < ActiveRecord::Base
  audited

  belongs_to :appointment
  belongs_to :visit
  belongs_to :line_item
  attr_accessible :appointment_id
  attr_accessible :visit_id
  attr_accessible :line_item_id
  attr_accessible :completed
  attr_accessible :quantity

  def required?
    self.visit.to_be_performed?
  end

  def core
    self.line_item.service.organization
  end

  def default_quantity
    default = self.quantity
    default ||= self.visit.research_billing_qty
    default
  end

  def total
    self.quantity * self.line_item.per_unit_cost
  end
end
