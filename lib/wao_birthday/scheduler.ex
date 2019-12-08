defmodule WaoBirthday.Scheduler do
  use Quantum.Scheduler,
    otp_app: :wao_birthday

  alias Memento.Query
  alias WaoBirthday.{Birthday, Interest}

  def enqueue_reminders(day \\ Date.utc_today()) do
    Memento.transaction fn ->
      Enum.each(Birthday.for_day(day), &enqueue/1)
    end
  end

  defp enqueue birthday do
    birthday.uid
    |> Interest.interests_for()
    |> Enum.each(fn interest ->
      Honeydew.async({:send_reminder, [birthday, interest]}, {:global, :reminders})
    end)
  end

end

