defmodule QuestApiV21Web.BusinessJSON do
  alias QuestApiV21.Businesses.Business
  alias QuestApiV21.Hosts.Host

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

  defp data(%Business{hosts: hosts} = business) do
    %{
      id: business.id,
      name: business.name,
      hosts: hosts_data(hosts)
    }
  end

  defp hosts_data(hosts) do
    Enum.map(hosts, fn %Host{id: id, name: name, email: email} ->
      %{
        id: id,
        name: name,
        email: email
      }
    end)
  end
end
