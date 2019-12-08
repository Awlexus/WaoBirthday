defmodule WaoBirthday.Commands.Birthday do
  use Alchemy.Cogs

  alias Alchemy.{Client, Embed}
  alias WaoBirthday.Birthday

  import WaoBirthday.Utils

  require Logger
  require Embed

  Cogs.def birthday "help" do
    Cogs.say """
    ```
    birthday me - Displays your birthday.
    birthday <userid> - Displays this users birthday.
    birthday me day month - Sets your birthday. Only you can overwrite this.
    birthday <userid> day month- Sets this users birthday.
    ```
    """
  end

  Cogs.def birthday "me" do
    case send_embed(message, message.author.id) do
      {:error, :not_found, _} -> Cogs.say "Nobody knows about your birthday yet"
      {:ok, _} -> {:ok, :boomer}
      error -> handle_error(message, error)
    end
  end

  Cogs.def birthday id do
    case send_embed(message, id) do
      {:error, :not_found, user} -> Cogs.say "#{maybe_s user.username} is unknown."
      {:ok, _} -> {:ok, :boomer}
      error -> handle_error(message, error)
    end
  end

  Cogs.def birthday "me", day, month do
    result =
      Memento.transaction fn -> Birthday.write_birthday(message.author.id, day, month, true) end

    case result do
      {:ok, birthday} -> Cogs.say "Your Birthday was set to the #{to_string birthday}"
      {:error, error} when is_binary(error) -> Cogs.say error
      error ->
        Logger.error "Could not set birthday: #{inspect error}"
        Cogs.say "Could not set your birthday"
    end
  end

  Cogs.def birthday id, day, month do
    with {:ok, %{username: username}} <- Client.get_user(id) do
      Memento.transaction fn ->
        case Memento.Query.read(Birthday, id, lock: :write) do
          %{owner: true} ->
            Cogs.say "#{maybe_s username}} can't be overwritten, because it was set by #{username}"

          _ ->
            case Birthday.write_birthday(id, day, month, false) do
              {:ok, birthday} ->
                Cogs.say "#{maybe_s username} has been set to #{to_string birthday}"
              {:error, error} when is_binary(error) ->
                Cogs.say error

              _ ->
                Cogs.say "Could not set #{maybe_s username} birthday"
            end
        end
      end
    else
      error ->
        handle_error(message, error)
    end
  end

  defp send_embed(message, id) do
    case Client.get_user(id) do
      {:ok, user} ->
        case Birthday.read_birthday(id) do
          {:ok, birthday} ->
            birthday
            |> Birthday.embed(user)
            |> Embed.send()

          {:error, :not_found} ->
            {:error, :not_found, user}
        end

      {:error, error} when is_binary(error) ->
        case Poison.decode(error) do
          {:ok, error_json} -> {:error, error_json}
          {:error, _} -> {:error, error}
        end

      {:error, error} ->
        {:error, error}
    end
  end
end
