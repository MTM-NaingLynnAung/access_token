class LinkageService
  class << self
    def index
      LinkageRepository.index
    end

    def new(params)
      LinkageRepository.new(params)
    end
  end
end
