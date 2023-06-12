class Users::RegistrationsController < Devise::RegistrationsController
  def create
    super do |resource|
      if resource.errors.any?
        puts "============== User Creation Error: #{resource.errors.full_messages.join("\n")} =============="
      else
        puts "============== User Created! #{resource.inspect} =============="
      end
    end
  end

  private

  def set_flash_message!(*args)
    # Do nothing. We don't want to use flash in API mode.
  end
end
