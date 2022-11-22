class UserRepository
  class << self

    def index
      User.all
    end
    
    def new
      User.new
    end
    
    def create(user)
      User.create(user)
    end

    def save(user)
      user.save
    end

    def find_id(id)
      User.find_by(id: id)
    end

    def update(user, params)
      user.update(params)
    end

    def delete(user)
      user.destroy
    end

  end
end
