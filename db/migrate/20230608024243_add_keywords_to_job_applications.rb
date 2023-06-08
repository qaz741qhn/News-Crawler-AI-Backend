class AddKeywordsToJobApplications < ActiveRecord::Migration[7.0]
  def up
    add_column :job_applications, :abilities, :text
    add_column :job_applications, :professional_values_interests, :text
    add_column :job_applications, :soft_skills, :text
  end
  
  def down
    remove_column :job_applications, :abilities
    remove_column :job_applications, :professional_values_interests
    remove_column :job_applications, :soft_skills
  end
end
