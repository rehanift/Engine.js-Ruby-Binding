require 'json'
require './enginejs-client'

describe Engine::Client do
  before(:each) do
    @intake_socket = double(Engine::Socket)
    @client = Engine::Client.make(:intake_socket => @intake_socket)
  end

  it "creates a new Engine::Task" do
    task = @client.create_task
    task.should be_an(Engine::Task)
  end
  
  it "sends a task to the client's intake socket" do
    task = @client.create_task
    @intake_socket.should_receive(:send_message)
    @client.run_task(task)
  end
end

def proc_as_block(&block)
  yield
end

describe Engine::Task do
  before(:each) do
    @client = double(Engine::Client)
    @task = Engine::Task.make(:id => 1, :client => @client)
  end

  it "has a context" do
    @task.context = "some context"
    @task.context.should match("some context")
  end

  it "has locals" do
    @task.locals = "some locals"
    @task.locals.should match("some locals")
  end

  it "has code" do
    @task.code = "some code"
    @task.code.should match("some code")
  end

  it "is run through its originating Task::Client" do
    serialized_task = {
      :context => "some context",
      :locals => {:foo => "bar"},
      :code => "some code",
      :task_id => @task.task_id
    }
    json_task = serialized_task.to_json

    @task.context = serialized_task[:context]
    @task.locals = serialized_task[:locals]
    @task.code = serialized_task[:code]
    @client.should_receive(:run_task).with(json_task)
    @task.run
  end

  it "calls its eval callback when the eval message is received" do
    callback = Proc.new {}
    callback.should_receive(:yield)
    proc_as_block(&callback)
  end

end
