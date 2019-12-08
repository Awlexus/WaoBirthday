defmodule WaoBirthday do
  use Application

  alias Alchemy.Client
  alias Memento.Table
  alias WaoBirthday.{Birthday, Commands, Interest, SendReminder}

  require Logger

  def start(_, _) do
    children = [
      Supervisor.child_spec({Task, &create_tables/0}, id: :create_tables),
      Supervisor.child_spec(Client, start: {Client, :start, [read_token()]}),
      Supervisor.child_spec({Task, &load_cogs/0}, id: :load_cogs)
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  defp create_tables do
    nodes = [node()]

    Memento.stop()
    Memento.Schema.create(nodes)
    Memento.start()

    :ok = assert_created(Birthday, nodes)
    :ok = assert_created(Interest, nodes)

    :ok = Honeydew.start_queue({:global, :reminders}, queue: {Honeydew.Queue.Mnesia, [ram_copies: nodes] }, failure_mode: {Honeydew.FailureMode.Retry, times: 3})
    :ok = Honeydew.start_workers({:global, :reminders}, SendReminder)
    Logger.info "Tables created"
  end

  defp assert_created(table, nodes) do
    case Table.create(table, disc_copies: nodes) do
      {:ok, _} -> :ok
      {:error, {:already_exists, ^table}} -> :ok
    end

    Logger.debug("#{table} created")
  end

  defp load_cogs do
    use Commands.Birthday
    use Commands.Remind
  end

  defp read_token(), do: Application.fetch_env!(:wao_birthday, :token)

end
