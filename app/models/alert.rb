class Alert < ApplicationRecord
	validates_presence_of :valid_until, :content                       
end
