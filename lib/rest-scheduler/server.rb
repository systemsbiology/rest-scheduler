require 'sinatra/base'

require File.dirname(__FILE__) + '/task'

APP_URL = "http://orkney:4567"

module RestScheduler
  class Server < Sinatra::Base
    set :root, File.dirname(__FILE__)

    get '/tasks' do
      @tasks = Task.all
      content_type 'application/xml', :charset => 'utf-8'  
      builder :index
    end

    get '/tasks/:id' do
      content_type 'application/xml', :charset => 'utf-8'  

      begin
        @task = Task.find(params[:id])
        builder :show
      rescue ActiveRecord::RecordNotFound
        status 404
      end
    end

    post '/tasks' do
      content_type 'application/xml', :charset => 'utf-8'  

      begin
        task_hash = XmlSimple.xml_in request.body.read
        @task = Task.new(
          :name => task_hash["name"] && task_hash["name"].first,
          :schedule_method => task_hash["schedule_method"] && task_hash["schedule_method"].first,
          :schedule_every => task_hash["schedule_every"] && task_hash["schedule_every"].first,
          :shell_command => task_hash["shell_command"] &&task_hash["shell_command"].first
        )

        if @task.save
          status 201
          headers("Location" => "#{APP_URL}/tasks/#{@task.id}",
            "Content-Location" => "#{APP_URL}/tasks/#{@task.id}")
          builder :show
        else
          status 422
          @task.errors.to_xml
        end
      rescue REXML::ParseException => e
        status 422
        @error = "Error parsing XML: #{e}"
        builder :error
      end
    end

    delete '/tasks/:id' do
      begin
        @task = Task.find(params[:id])
        @task.destroy
        status 200
      rescue ActiveRecord::RecordNotFound
        status 404
      end
    end

    not_found do
      status 404
      ""
    end
  end
end
