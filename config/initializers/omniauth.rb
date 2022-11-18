Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, "504046601667582", "2c3f001e9f7b1b254b3d9c44ab484744"
end
