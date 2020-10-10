class DocsWorker
	include Sidekiq::Worker

	def self.upload(store, file)
		store = Store.find(store)
		store.docs.create!(document: file)
	end

	def remote_upload(store, file)
		self.class.post('/secureCard/post/UploadDocuments/index.php') #params go here )
	end
end
