defmodule WaoBirthday.Interest do
  use Memento.Table,
    attributes: [:from, :to],
    type: :bag,
    index: [:to]

  alias Memento.Query

  def interests_for(id) do
    Query.select(__MODULE__, {:==, :to, id})
  end

  def interests(id) do
    Query.select(__MODULE__, {:==, :from, id})
  end

  def mutually_interested?(a, b) do
    results = [
      Query.select(__MODULE__, [{:==, :from, a}, {:==, :to, b}]),
      Query.select(__MODULE__, [{:==, :from, b}, {:==, :to, a}])
    ]

    Enum.all?(results, &length(&1) > 0)
  end
end
