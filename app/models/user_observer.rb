#saved in the file app/models/customer_observer.rb
class UserObserver < ActiveRecord::Observer
def after_save(record)
record.logger.info("####################")
record.logger.info("+++ CustomerObserver:
The customer #{record.user_name} was added with ID #{record.id}")
record.logger.info("####################")
end
end