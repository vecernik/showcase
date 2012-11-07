class EditableEntryProperty < ActiveRecord::Base

  belongs_to :editable_entry,
             #foreign_key: 'entry_id',
             inverse_of: :editable_properties

  belongs_to :editable_property,
             foreign_key: 'name'


  attr_accessible :content, :entry_id, :name, :editable_entry, :editable_property


  def get_value
    case cached_prop_type
      when 'markdown'
        RDiscount.new(content, :safelink, :no_pseudo_protocols).to_html.html_safe
      when 'number'
        content.to_i
      when 'float'
        content.to_f
      else
        content.html_safe
    end
  end

  def set_value(raw_value)
    value = case cached_prop_type
      when 'markdown'
        " #{raw_value} ".gsub(/([^(])(https?:\/\/.+\.(png|gif|jpg|jpeg))([^)])/i) {|m| "#{$1}![text for #{$3}](#{$2.strip})#{$4}" }.strip
      else
        raw_value
    end
    self.update_attribute(:content, value)
  end

  def cached_prop_type
    @cached_prop_type ||= editable_property.prop_type
  end

end
