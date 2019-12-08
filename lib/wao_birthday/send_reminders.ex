defmodule WaoBirthday.SendReminder do
  alias Alchemy.Client
  alias WaoBirthday.Birthday

  import WaoBirthday.Utils

  def init(_) do
    {:ok, :ok}
  end

  def send_reminder(birthday, %{from: from, to: to}, _) do
    with {:ok, user} <- Client.get_user(to),
         {:ok, channel} <- Client.create_DM(from) do
      embed = Birthday.embed(birthday, user)
      Client.send_message(channel.id, "It's #{maybe_s(user.username)} Birthday!", embed: embed)
    end
  end
end
