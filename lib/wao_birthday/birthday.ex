defmodule WaoBirthday.Birthday do
  use Memento.Table, attributes: [:uid, :day, :month, :by_owner]

  alias Memento.Query
  alias Alchemy.Embed

  require Embed

  def read_birthday(id) do
    result = Memento.transaction fn ->
      Query.read __MODULE__, id
    end

    case result do
      {:ok, nil} -> {:error, :not_found}
      {:ok, birthday} -> {:ok, birthday}
      other ->
        IO.inspect other
    end
  end

  def write_birthday(id, day_str, month_str, owner) do
    with {month, _} when is_integer(month) <- Integer.parse(month_str),
         {day, _} when is_integer(day) <- Integer.parse(day_str),
         {:ok, _date} <- Date.new(2000, month, day) do
      Query.write(%__MODULE__{
        uid: id,
        day: day,
        month: month,
        by_owner: owner
      })
    else
      :error -> {:error, "Invalid Date"}
      {:error, _} -> {:error, "Invalid Date"}
    end
  end

  def for_day(%{day: day, month: month} \\ Date.utc_today()) do
    Query.select(__MODULE__, [
      {:==, :day, day},
      {:==, :month, month}
    ])
  end

  def until %{day: day, month: month} do
    now = Date.utc_today()
    {:ok, next} = Date.new(now.year, month, day)

    next = if Date.diff(next, now) < 0 do
      %{next | year: next.year + 1}
    else
      next
    end

    Date.diff(next, now)
  end

  def from_now birthday do
    case until birthday do
      0 ->
        "TODAY!"

      days ->
        days
        |> Timex.Duration.from_days()
        |> Timex.Format.Duration.Formatter.format(:humanized)
    end
  end

  def embed birthday, user do
    %Embed{}
    |> Embed.title("#{WaoBirthday.Utils.maybe_s(user.username)} is on the #{to_string(birthday)}")
    |> Embed.description("That's in #{from_now(birthday)}")
    |> Embed.color(0xc13621)
  end

  defimpl String.Chars do
    def to_string %{day: day, month: month} do
      suffix = case rem day, 10 do
        1 -> "st"
        2 -> "nd"
        3 -> "rd"
        _ -> "th"
      end
      "#{day}#{suffix} #{Timex.month_name(month)}"
    end
  end
end
