defmodule QuestApiV21Web.HostJSON do
  alias QuestApiV21.Hosts.Host
  alias QuestApiV21.Businesses.Business

  @doc """
  Renders a list of hosts.
  """
  def index(%{hosts: hosts}) do
    %{data: for(host <- hosts, do: data(host))}
  end

  @doc """
  Renders a single host.
  """
  def show(%{host: host}) do
    %{data: data(host)}
  end

  defp data(%Host{businesses: businesses} = host) do
    %{
      id: host.id,
      name: host.name,
      email: host.email,
      hashed_password: host.hashed_password,
      businesses: businesses_data(businesses)
    }
  end

  defp businesses_data(businesses) do
    Enum.map(businesses, fn %Business{id: id, name: name} ->
      %{
        id: id,
        name: name
      }
    end)
  end
end
