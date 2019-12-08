defmodule WaoBirthday.Commands.Remind do
  use Alchemy.Cogs

  alias Alchemy.Client
  alias WaoBirthday.{Birthday, Interest}
  alias Memento.Query

  import WaoBirthday.Utils

  Cogs.def reminders do
    Memento.transaction fn ->
      case Interest.interests(message.author.id) do
        [] ->
          Cogs.say "You haven't set any reminders"
        reminders ->
          Cogs.say """
          You want to be reminded for these birthdays
          #{table(reminders)}
          """
      end
    end
  end

  Cogs.def remind "help" do
    Cogs.say """
    remind <user_id>
    ---
    Sends you a reminder when this person it's that user's birthday.
    """
  end

  Cogs.def remind id do
    case Client.get_user(id) do
      {:ok, user} ->
        Memento.transaction fn ->
          case Query.read(Birthday, id) do
            nil ->
              Cogs.say "#{maybe_s(user.username)} birthday is unknown"
            _birthday ->
              Query.write(%Interest{from: message.author.id, to: id})
              Cogs.say "Reminder for #{maybe_s(user.username)} set!"
          end
        end
      error -> handle_error(message, error)
    end
  end

  defp table reminders do
    birthdays =
      reminders
      |> Stream.map(fn %{to: to} ->
        Memento.Query.read(Birthday, to)
      end)
      |> Enum.sort_by(&Birthday.until/1)
      |> Enum.map(fn birthday ->
        case Client.get_user(birthday.uid) do
          {:ok, user} -> {"#{user.username}##{user.discriminator}", to_string(birthday)}
          {:error, _} -> {birthday.uid, to_string(birthday)}
        end
      end)

    longest_name_length =
      [ {"Username", ""} | birthdays ]
      |> Stream.map(fn {name, _} -> String.length name end)
      |> Enum.max()

    longest_birthday_length =
      [ {"", "birthday"} | birthdays ]
      |> Stream.map(fn {_, birthday} -> String.length birthday end)
      |> Enum.max()

    table =
      birthdays
      |> Enum.map(fn {name, birthday} ->
        "| #{center(name, longest_birthday_length)} | #{center(birthday, longest_birthday_length)} |"
      end)
      |> Enum.join("\n")

    """
    ```md
    | #{center("Username", longest_name_length)} | #{center("Birthday", longest_birthday_length)} |
    #{divider(longest_name_length, longest_birthday_length)}
    #{table}
    ```
    """
  end

  defp divider(col_a_length, col_b_length) do
    "| #{String.duplicate("-", col_a_length)} | #{String.duplicate("-", col_b_length)} |"
  end

  defp center(string, length) do
    str_len = String.length string
    median = div str_len + length, 2

    string
    |> String.pad_leading(median)
    |> String.pad_trailing(length)
  end
end
