xml.task do
  xml.name @task.name
  xml.schedule_method @task.schedule_method
  xml.schedule_every @task.schedule_every
  xml.shell_command @task.shell_command
  xml.atom :link, {:rel => "show", :href => "#{APP_URL}/tasks/#{@task.id}",
    "xmlns:atom" => "http://www.w3.org/2005/Atom"}
  xml.atom :link, {:rel => "destroy", :href => "#{APP_URL}/tasks/#{@task.id}",
    "xmlns:atom" => "http://www.w3.org/2005/Atom"}
end