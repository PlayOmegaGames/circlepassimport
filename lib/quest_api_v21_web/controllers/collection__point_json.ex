defmodule QuestApiV21Web.Collection_PointJSON do
  alias QuestApiV21.Collection_Points.Collection_Point

  @doc """
  Renders a list of collection_point.
  """
  def index(%{collection_point: collection_point}) do
    %{data: for(collection__point <- collection_point, do: data(collection__point))}
  end

  @doc """
  Renders a single collection__point.
  """
  def show(%{collection__point: collection__point}) do
    %{data: data(collection__point)}
  end

  defp data(%Collection_Point{} = collection__point) do
    %{
      id: collection__point.id,
      name: collection__point.name,
      image: collection__point.image,
      scans: collection__point.scans,
      redirect_url: collection__point.redirect_url,
      badge_description: collection__point.badge_description,
      business_id: collection__point.business_id,
      quest_id: collection__point.quest_id
    }
  end
end
