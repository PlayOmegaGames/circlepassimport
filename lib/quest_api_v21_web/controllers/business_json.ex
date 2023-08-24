defmodule QuestApiV21Web.BusinessJSON do
  alias QuestApiV21.Businesses.Business

  @doc """
  Renders a list of businesses.
  """
  def index(%{businesses: businesses}) do
    %{data: for(business <- businesses, do: data(business))}
  end

  @doc """
  Renders a single business.
  """
  def show(%{business: business}) do
    %{data: data(business)}
  end

  defp data(%Business{} = business) do
    %{
      id: business.id,
      name: business.name
    }
  end
end
