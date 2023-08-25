defmodule QuestApiV21Web.CollectorJSON do
  alias QuestApiV21.Collectors.Collector
  alias QuestApiV21.Collection_Points.Collection_Point

  @doc """
  Renders a list of collectors.
  """
  def index(%{collectors: collectors}) do
    %{data: for(collector <- collectors, do: data(collector))}
  end

  @doc """
  Renders a single collector.
  """
  def show(%{collector: collector}) do
    %{data: data(collector)}
  end

  defp data(%Collector{collection_points: collection_points} = collector) do
    %{
      id: collector.id,
      name: collector.name,
      coordinates: collector.coordinates,
      height: collector.height,
      collection_points: collection_points_data(collection_points)
    }
  end

  defp collection_points_data(collection_points) do
    Enum.map(collection_points, fn %Collection_Point{id: id, name: name} ->
      %{
        id: id,
        name: name
      }
    end)
  end
end
