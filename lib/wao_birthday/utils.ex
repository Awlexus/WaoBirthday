defmodule WaoBirthday.Utils do
  alias Alchemy.Cogs

  require Cogs
  require Logger

  def maybe_s(username) do
    if String.ends_with? username, "s" do
      username <> "'"
    else
      username <> "'s"
    end
  end

  def handle_error(message, {:error, error}) when is_binary(error) do
    case Poison.decode(error) do
      {:ok, %{"message" => message}} -> Cogs.say message
      {:error, _error} -> handle_error message, error
    end
  end

  def handle_error(message, {:error, error}) when is_atom(error) do
    Cogs.say "Error: #{error}"
  end


  def handle_error(message, error) when is_binary(error) do
    Cogs.say error
  end

  def handle_error(message, error) do
    Logger.error "Unhandled errorcase: #{inspect error}"
    Cogs.say "Something went wrong. Please try again later"
  end
end
