
namespace :update_store do
  desc "Update kyc all stores"
  task :kyc => :environment do
      Store.all.each do |s|
      if s.docs.count >= 4
       s.update(kyc: false)
      end
    end
  end
end
