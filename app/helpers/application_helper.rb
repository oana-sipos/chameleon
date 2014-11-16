module ApplicationHelper

	# This method is called for any ActiveRecord object, and if there are validations
	# errors in the specified field, it returns an HTML snippet of those errors.
	# It's meant to be used in forms, when the user might be turned back to a form with errors.
	def errors_for obj, field
    unless obj.errors[field].empty?
       "<span style='color: red;'>#{obj.errors[field].join('. ')}</span>".html_safe
    end
  end

end
