require File.dirname(__FILE__) + '/task'

module RestScheduler
  class Server < Sinatra::Base
    helpers Sinatra::UrlForHelper

    set :root, File.dirname(__FILE__)

    configure [:development, :production] do
      appconfig = YAML.load_file( File.join(APP_ROOT, "config", "application.yml") )
      use Rack::Auth::Basic do |username, password|
        [username, password] == [appconfig['username'], appconfig['password']]
      end
    end

    dbconfig = YAML.load_file( File.join(APP_ROOT, "config", "database.yml") )
    ActiveRecord::Base.establish_connection(
      :adapter => dbconfig['adapter'],
      :database => File.join( APP_ROOT, dbconfig['database'] )
    )

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
          :shell_command => task_hash["shell_command"] && task_hash["shell_command"].first,
          :postback_uri => task_hash["postback_uri"] && task_hash["postback_uri"].first
        )

        if @task.save
          status 201
          headers(
            "Location" => url_for("/tasks/#{@task.id}", :full),
            "Content-Location" => url_for("/tasks/#{@task.id}", :full)
          )
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
