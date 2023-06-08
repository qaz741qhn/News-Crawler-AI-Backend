# 在 app/controllers/users/registrations_controller.rb 文件中
class Users::RegistrationsController < Devise::RegistrationsController
  def create
    super do |resource|
      if resource.errors.any?
        puts "============== User Creation Error: #{resource.errors.full_messages.join("\n")} =============="
      end
    end
  end
end
