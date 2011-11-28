require 'simple_uuid'

module Engine
  class Client

    def initialize(intake_socket)
      @intake_socket = intake_socket
    end

    def self.make(options = {})
      Client.new(options[:intake_socket])
    end

    def create_task
      @uuid = SimpleUUID::UUID.new
      Engine::Task.make(:id => @uuid.to_guid, :client => self)
    end

    def run_task(task)
      @intake_socket.send_message(task)
    end
  end

  class Task

    attr_accessor :context
    attr_accessor :locals
    attr_accessor :code

    def initialize(id, client)
      @id = id
      @client = client
    end

    def self.make(options = {})
      Engine::Task.new(options[:id],
                       options[:client])
    end

    def run
      serialized_task = {
        :context => self.context,
        :locals => self.locals,
        :code => self.code,
        :task_id => self.task_id
      }
      @client.run_task(serialized_task.to_json)
    end

    def task_id
      "task-#{@id}"
    end
  end

  class Socket
    def send_message(message)

    end
  end
end
