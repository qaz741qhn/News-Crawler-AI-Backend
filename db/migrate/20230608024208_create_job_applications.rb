class CreateJobApplications < ActiveRecord::Migration[7.0]
  def change
    create_table :job_applications do |t|
      t.string :education
      t.text :experience
      t.string :interested_role
      t.text :company_info

      t.timestamps
    end
  end
end
