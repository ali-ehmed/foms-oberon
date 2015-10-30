class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable


  validates :username,
	  :presence => true,
	  :uniqueness => {
	    :case_sensitive => false
	  } # etc.

  # validates_format_of :username, with: /^[a-zA-Z0-9_\.]*$/
  
  attr_accessor :login

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions.to_hash).where(conditions).where(["username = :value", { :value => login }]).first
    else
      where(conditions.to_hash).first
    end
  end
end
