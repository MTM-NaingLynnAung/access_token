class UserService
  class << self
    def index
      UserRepository.index
    end
    
    def new
      UserRepository.new
    end
    
    def create(user)
      UserRepository.create(user)
    end

    def save(user)
      user.save
    end

    def update(user, params)
      UserRepository.update(user, params)
    end
    
    def delete(id)
      user = UserRepository.find_id(id)
      UserRepository.delete(user)
    end

    def set_user(id)
      user = UserRepository.find_id(id)
    end
  end
end
